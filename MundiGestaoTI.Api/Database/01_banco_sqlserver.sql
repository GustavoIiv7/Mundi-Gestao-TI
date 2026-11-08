/* =============================================================================
   Mundi Gestão TI — Banco de dados (SQL Server)
   Contém: tabelas, restrições, índices, views, stored procedures e triggers.
   Pode ser executado mais de uma vez (idempotente).
   Os usuários de exemplo são criados pela própria API (senha com hash BCrypt),
   por isso este script não insere usuários.
   ============================================================================= */

IF DB_ID(N'MundiGestaoTI') IS NULL
    CREATE DATABASE MundiGestaoTI;
GO

USE MundiGestaoTI;
GO

/* =============================================================================
   1. TABELAS
   ============================================================================= */

IF OBJECT_ID(N'dbo.Usuarios', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Usuarios
    (
        Id        INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Usuarios PRIMARY KEY,
        Login     NVARCHAR(50)  NOT NULL,
        SenhaHash NVARCHAR(MAX) NOT NULL,
        Nome      NVARCHAR(100) NOT NULL,
        Area      NVARCHAR(20)  NOT NULL,
        Perfil    NVARCHAR(20)  NOT NULL,
        Ativo     BIT           NOT NULL CONSTRAINT DF_Usuarios_Ativo    DEFAULT 1,
        CriadoEm  DATETIME2     NOT NULL CONSTRAINT DF_Usuarios_CriadoEm DEFAULT SYSUTCDATETIME(),
        CONSTRAINT CK_Usuarios_Area   CHECK (Area   IN (N'Redes', N'Banco', N'Acessos', N'Sistemas')),
        CONSTRAINT CK_Usuarios_Perfil CHECK (Perfil IN (N'Analista', N'Admin'))
    );
    CREATE UNIQUE INDEX IX_Usuarios_Login ON dbo.Usuarios (Login);
END
GO

IF OBJECT_ID(N'dbo.Tickets', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tickets
    (
        Id            INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Tickets PRIMARY KEY,
        Titulo        NVARCHAR(200)  NOT NULL,
        Descricao     NVARCHAR(2000) NOT NULL CONSTRAINT DF_Tickets_Descricao DEFAULT N'',
        Prioridade    NVARCHAR(20)   NOT NULL CONSTRAINT DF_Tickets_Prioridade DEFAULT N'Normal',
        Status        NVARCHAR(20)   NOT NULL CONSTRAINT DF_Tickets_Status     DEFAULT N'Aberto',
        Area          NVARCHAR(20)   NOT NULL,
        Categoria     NVARCHAR(100)  NULL,
        Progresso     INT            NOT NULL CONSTRAINT DF_Tickets_Progresso  DEFAULT 0,
        CriadoEm      DATETIME2      NOT NULL CONSTRAINT DF_Tickets_CriadoEm   DEFAULT SYSUTCDATETIME(),
        AtualizadoEm  DATETIME2      NULL,
        ResolvidoEm   DATETIME2      NULL,
        CriadorId     INT            NOT NULL,
        ResponsavelId INT            NULL,
        CONSTRAINT FK_Tickets_Criador     FOREIGN KEY (CriadorId)     REFERENCES dbo.Usuarios (Id),
        CONSTRAINT FK_Tickets_Responsavel FOREIGN KEY (ResponsavelId) REFERENCES dbo.Usuarios (Id),
        CONSTRAINT CK_Tickets_Prioridade CHECK (Prioridade IN (N'Baixa', N'Normal', N'Alta', N'Urgente')),
        CONSTRAINT CK_Tickets_Status     CHECK (Status IN (N'Aberto', N'EmAndamento', N'Agendado', N'Resolvido', N'Fechado')),
        CONSTRAINT CK_Tickets_Area       CHECK (Area   IN (N'Redes', N'Banco', N'Acessos', N'Sistemas')),
        CONSTRAINT CK_Tickets_Progresso  CHECK (Progresso BETWEEN 0 AND 100)
    );
    CREATE INDEX IX_Tickets_Status        ON dbo.Tickets (Status);
    CREATE INDEX IX_Tickets_Prioridade    ON dbo.Tickets (Prioridade);
    CREATE INDEX IX_Tickets_CriadoEm      ON dbo.Tickets (CriadoEm);
    CREATE INDEX IX_Tickets_Area_Status   ON dbo.Tickets (Area, Status);
    CREATE INDEX IX_Tickets_CriadorId     ON dbo.Tickets (CriadorId);
    CREATE INDEX IX_Tickets_ResponsavelId ON dbo.Tickets (ResponsavelId);
END
GO

IF OBJECT_ID(N'dbo.Mensagens', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Mensagens
    (
        Id             INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Mensagens PRIMARY KEY,
        Conteudo       NVARCHAR(1000) NOT NULL,
        EnviadaEm      DATETIME2      NOT NULL CONSTRAINT DF_Mensagens_EnviadaEm DEFAULT SYSUTCDATETIME(),
        Lida           BIT            NOT NULL CONSTRAINT DF_Mensagens_Lida DEFAULT 0,
        RemetenteId    INT            NOT NULL,
        DestinatarioId INT            NOT NULL,
        TicketId       INT            NULL,
        CONSTRAINT FK_Mensagens_Remetente    FOREIGN KEY (RemetenteId)    REFERENCES dbo.Usuarios (Id),
        CONSTRAINT FK_Mensagens_Destinatario FOREIGN KEY (DestinatarioId) REFERENCES dbo.Usuarios (Id),
        CONSTRAINT FK_Mensagens_Ticket       FOREIGN KEY (TicketId)       REFERENCES dbo.Tickets (Id)
    );
    CREATE INDEX IX_Mensagens_EnviadaEm    ON dbo.Mensagens (EnviadaEm);
    CREATE INDEX IX_Mensagens_Conversa     ON dbo.Mensagens (RemetenteId, DestinatarioId);
    CREATE INDEX IX_Mensagens_DestinatarioId ON dbo.Mensagens (DestinatarioId);
    CREATE INDEX IX_Mensagens_TicketId     ON dbo.Mensagens (TicketId);
END
GO

-- Histórico de status (preenchido pelo trigger trg_Tickets_Historico)
IF OBJECT_ID(N'dbo.TicketsHistorico', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TicketsHistorico
    (
        Id             INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TicketsHistorico PRIMARY KEY,
        TicketId       INT          NOT NULL,
        StatusAnterior NVARCHAR(20) NOT NULL,
        StatusNovo     NVARCHAR(20) NOT NULL,
        AlteradoEm     DATETIME2    NOT NULL CONSTRAINT DF_TicketsHistorico_AlteradoEm DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_TicketsHistorico_Ticket FOREIGN KEY (TicketId) REFERENCES dbo.Tickets (Id) ON DELETE CASCADE
    );
    CREATE INDEX IX_TicketsHistorico_TicketId ON dbo.TicketsHistorico (TicketId);
END
GO

/* =============================================================================
   2. VIEWS
   ============================================================================= */

-- Chamados em aberto/andamento/agendados, já com os nomes de criador e responsável
CREATE OR ALTER VIEW dbo.vw_ChamadosAtivos
AS
SELECT t.Id, t.Titulo, t.Prioridade, t.Status, t.Area, t.Progresso, t.CriadoEm,
       c.Nome AS Criador,
       r.Nome AS Responsavel
FROM dbo.Tickets t
JOIN dbo.Usuarios c      ON c.Id = t.CriadorId
LEFT JOIN dbo.Usuarios r ON r.Id = t.ResponsavelId
WHERE t.Status NOT IN (N'Resolvido', N'Fechado');
GO

-- Indicadores por área (base do Dashboard)
CREATE OR ALTER VIEW dbo.vw_ResumoPorArea
AS
SELECT t.Area,
       COUNT(*)                                                            AS Total,
       SUM(CASE WHEN t.Status = N'Aberto'      THEN 1 ELSE 0 END)          AS Abertos,
       SUM(CASE WHEN t.Status = N'EmAndamento' THEN 1 ELSE 0 END)          AS EmAndamento,
       SUM(CASE WHEN t.Status = N'Agendado'    THEN 1 ELSE 0 END)          AS Agendados,
       SUM(CASE WHEN t.Status IN (N'Resolvido', N'Fechado') THEN 1 ELSE 0 END) AS Concluidos,
       CAST(ROUND(100.0 * SUM(CASE WHEN t.Status IN (N'Resolvido', N'Fechado') THEN 1 ELSE 0 END)
                  / COUNT(*), 0) AS INT)                                   AS TaxaResolucao,
       CAST(ROUND(AVG(CASE WHEN t.ResolvidoEm IS NOT NULL
                           THEN DATEDIFF(MINUTE, t.CriadoEm, t.ResolvidoEm) / 60.0 END), 1)
            AS DECIMAL(10,1))                                              AS TempoMedioHoras
FROM dbo.Tickets t
GROUP BY t.Area;
GO

-- Últimos chamados concluídos (base do Relatório)
CREATE OR ALTER VIEW dbo.vw_RelatorioResolvidos
AS
SELECT t.Id, t.Titulo, t.Area,
       r.Nome AS Tecnico,
       t.ResolvidoEm,
       DATEDIFF(MINUTE, t.CriadoEm, t.ResolvidoEm) AS DuracaoMinutos
FROM dbo.Tickets t
LEFT JOIN dbo.Usuarios r ON r.Id = t.ResponsavelId
WHERE t.ResolvidoEm IS NOT NULL;
GO

/* =============================================================================
   3. STORED PROCEDURES
   ============================================================================= */

-- Abre um chamado validando os dados; devolve o Id em @NovoId
CREATE OR ALTER PROCEDURE dbo.sp_AbrirChamado
    @Titulo     NVARCHAR(200),
    @Descricao  NVARCHAR(2000) = N'',
    @Prioridade NVARCHAR(20),
    @Area       NVARCHAR(20),
    @Categoria  NVARCHAR(100)  = NULL,
    @CriadorId  INT,
    @NovoId     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(LTRIM(RTRIM(ISNULL(@Titulo, N'')))) < 5
        THROW 50001, N'O título deve ter pelo menos 5 caracteres.', 1;
    IF @Prioridade NOT IN (N'Baixa', N'Normal', N'Alta', N'Urgente')
        THROW 50002, N'Prioridade inválida. Use Baixa, Normal, Alta ou Urgente.', 1;
    IF @Area NOT IN (N'Redes', N'Banco', N'Acessos', N'Sistemas')
        THROW 50003, N'Área inválida. Use Redes, Banco, Acessos ou Sistemas.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE Id = @CriadorId AND Ativo = 1)
        THROW 50004, N'Usuário criador não encontrado ou inativo.', 1;

    INSERT INTO dbo.Tickets (Titulo, Descricao, Prioridade, Status, Area, Categoria, Progresso, CriadoEm, CriadorId)
    VALUES (LTRIM(RTRIM(@Titulo)),
            LTRIM(RTRIM(ISNULL(@Descricao, N''))),
            @Prioridade, N'Aberto', @Area,
            NULLIF(LTRIM(RTRIM(ISNULL(@Categoria, N''))), N''),
            0, SYSUTCDATETIME(), @CriadorId);

    SET @NovoId = SCOPE_IDENTITY();
END
GO

-- O usuário assume o chamado; se estava aberto, passa para "EmAndamento"
CREATE OR ALTER PROCEDURE dbo.sp_AssumirChamado
    @TicketId  INT,
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Tickets WHERE Id = @TicketId)
        THROW 50005, N'Chamado não encontrado.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE Id = @UsuarioId AND Ativo = 1)
        THROW 50004, N'Usuário não encontrado ou inativo.', 1;

    UPDATE dbo.Tickets
       SET ResponsavelId = @UsuarioId,
           Status        = CASE WHEN Status = N'Aberto' THEN N'EmAndamento' ELSE Status END,
           AtualizadoEm  = SYSUTCDATETIME()
     WHERE Id = @TicketId;
END
GO

-- Resolve o chamado. A data de resolução e o progresso 100% são gravados pelo
-- trigger trg_Tickets_Resolucao, e a mudança de status pelo trg_Tickets_Historico.
CREATE OR ALTER PROCEDURE dbo.sp_ResolverChamado
    @TicketId  INT,
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Tickets WHERE Id = @TicketId)
        THROW 50005, N'Chamado não encontrado.', 1;
    IF EXISTS (SELECT 1 FROM dbo.Tickets WHERE Id = @TicketId AND Status IN (N'Resolvido', N'Fechado'))
        THROW 50006, N'Este chamado já foi concluído.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE Id = @UsuarioId AND Ativo = 1)
        THROW 50004, N'Usuário não encontrado ou inativo.', 1;

    UPDATE dbo.Tickets
       SET Status        = N'Resolvido',
           ResponsavelId = COALESCE(ResponsavelId, @UsuarioId),
           AtualizadoEm  = SYSUTCDATETIME()
     WHERE Id = @TicketId;
END
GO

-- Indicadores de uma área nos últimos N dias (2 resultados: resumo e por serviço)
CREATE OR ALTER PROCEDURE dbo.sp_IndicadoresArea
    @Area NVARCHAR(20),
    @Dias INT = 30
AS
BEGIN
    SET NOCOUNT ON;

    IF @Area NOT IN (N'Redes', N'Banco', N'Acessos', N'Sistemas')
        THROW 50003, N'Área inválida. Use Redes, Banco, Acessos ou Sistemas.', 1;

    DECLARE @Desde DATETIME2 = DATEADD(DAY, -@Dias, SYSUTCDATETIME());

    -- Resultado 1: resumo
    SELECT @Area AS Area,
           COUNT(*) AS Total,
           SUM(CASE WHEN Status IN (N'Resolvido', N'Fechado') THEN 1 ELSE 0 END) AS Concluidos,
           ISNULL(CAST(ROUND(100.0 * SUM(CASE WHEN Status IN (N'Resolvido', N'Fechado') THEN 1 ELSE 0 END)
                      / NULLIF(COUNT(*), 0), 0) AS INT), 0) AS TaxaResolucao,
           CAST(ROUND(AVG(CASE WHEN ResolvidoEm IS NOT NULL
                               THEN DATEDIFF(MINUTE, CriadoEm, ResolvidoEm) / 60.0 END), 1)
                AS DECIMAL(10,1)) AS TempoMedioHoras
      FROM dbo.Tickets
     WHERE Area = @Area AND CriadoEm >= @Desde;

    -- Resultado 2: por tipo de serviço
    SELECT ISNULL(Categoria, N'Outros') AS Servico,
           COUNT(*) AS Requisicoes,
           CAST(ROUND(AVG(CASE WHEN ResolvidoEm IS NOT NULL
                               THEN DATEDIFF(MINUTE, CriadoEm, ResolvidoEm) / 60.0 END), 1)
                AS DECIMAL(10,1)) AS TempoMedioHoras
      FROM dbo.Tickets
     WHERE Area = @Area AND CriadoEm >= @Desde
     GROUP BY ISNULL(Categoria, N'Outros')
     ORDER BY COUNT(*) DESC;
END
GO

/* =============================================================================
   4. TRIGGERS
   ============================================================================= */

-- 1) Auditoria: toda mudança de status gera uma linha em TicketsHistorico
CREATE OR ALTER TRIGGER dbo.trg_Tickets_Historico
ON dbo.Tickets
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(Status) RETURN;

    INSERT INTO dbo.TicketsHistorico (TicketId, StatusAnterior, StatusNovo)
    SELECT i.Id, d.Status, i.Status
      FROM inserted i
      JOIN deleted  d ON d.Id = i.Id
     WHERE i.Status <> d.Status;
END
GO

-- 2) Ao resolver: grava a data de resolução e leva o progresso a 100%
CREATE OR ALTER TRIGGER dbo.trg_Tickets_Resolucao
ON dbo.Tickets
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(Status) RETURN;

    UPDATE t
       SET t.ResolvidoEm = COALESCE(t.ResolvidoEm, SYSUTCDATETIME()),
           t.Progresso   = 100
      FROM dbo.Tickets t
      JOIN inserted i ON i.Id = t.Id
      JOIN deleted  d ON d.Id = t.Id
     WHERE i.Status = N'Resolvido' AND d.Status <> N'Resolvido';
END
GO

-- 3) Usuários não são apagados: o DELETE vira desativação (preserva histórico e vínculos)
CREATE OR ALTER TRIGGER dbo.trg_Usuarios_ExclusaoLogica
ON dbo.Usuarios
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE u
       SET u.Ativo = 0
      FROM dbo.Usuarios u
      JOIN deleted d ON d.Id = u.Id;
END
GO
