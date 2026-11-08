/* =============================================================================
   Mundi Gestão TI — Views e Triggers (SQLite)
   Rode no DB Browser for SQLite: aba "Executar SQL" -> colar/abrir -> executar
   (Ctrl+Enter) -> "Gravar alterações" (Ctrl+S). Pode rodar mais de uma vez.

   Obs.: o SQLite NÃO possui stored procedures. As procedures estão no script
   do SQL Server (01_banco_sqlserver.sql).
   ============================================================================= */

-- ---------------------------------------------------------------------------
-- TABELA DE HISTÓRICO (preenchida pelo trigger)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS TicketsHistorico (
    Id             INTEGER PRIMARY KEY AUTOINCREMENT,
    TicketId       INTEGER NOT NULL,
    StatusAnterior TEXT    NOT NULL,
    StatusNovo     TEXT    NOT NULL,
    AlteradoEm     TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%d %H:%M:%f', 'now'))
);
CREATE INDEX IF NOT EXISTS IX_TicketsHistorico_TicketId ON TicketsHistorico (TicketId);

-- ---------------------------------------------------------------------------
-- VIEWS
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_ChamadosAtivos;
CREATE VIEW vw_ChamadosAtivos AS
SELECT t.Id, t.Titulo, t.Prioridade, t.Status, t.Area, t.Progresso, t.CriadoEm,
       c.Nome AS Criador,
       r.Nome AS Responsavel
FROM Tickets t
JOIN Usuarios c      ON c.Id = t.CriadorId
LEFT JOIN Usuarios r ON r.Id = t.ResponsavelId
WHERE t.Status NOT IN ('Resolvido', 'Fechado');

DROP VIEW IF EXISTS vw_ResumoPorArea;
CREATE VIEW vw_ResumoPorArea AS
SELECT t.Area,
       COUNT(*)                                                         AS Total,
       SUM(CASE WHEN t.Status = 'Aberto'      THEN 1 ELSE 0 END)        AS Abertos,
       SUM(CASE WHEN t.Status = 'EmAndamento' THEN 1 ELSE 0 END)        AS EmAndamento,
       SUM(CASE WHEN t.Status = 'Agendado'    THEN 1 ELSE 0 END)        AS Agendados,
       SUM(CASE WHEN t.Status IN ('Resolvido','Fechado') THEN 1 ELSE 0 END) AS Concluidos,
       CAST(ROUND(100.0 * SUM(CASE WHEN t.Status IN ('Resolvido','Fechado') THEN 1 ELSE 0 END)
                  / COUNT(*)) AS INTEGER)                               AS TaxaResolucao,
       ROUND(AVG(CASE WHEN t.ResolvidoEm IS NOT NULL
                      THEN (julianday(t.ResolvidoEm) - julianday(t.CriadoEm)) * 24 END), 1)
                                                                        AS TempoMedioHoras
FROM Tickets t
GROUP BY t.Area;

DROP VIEW IF EXISTS vw_RelatorioResolvidos;
CREATE VIEW vw_RelatorioResolvidos AS
SELECT t.Id, t.Titulo, t.Area,
       r.Nome AS Tecnico,
       t.ResolvidoEm,
       CAST(ROUND((julianday(t.ResolvidoEm) - julianday(t.CriadoEm)) * 1440) AS INTEGER)
           AS DuracaoMinutos
FROM Tickets t
LEFT JOIN Usuarios r ON r.Id = t.ResponsavelId
WHERE t.ResolvidoEm IS NOT NULL;

-- ---------------------------------------------------------------------------
-- TRIGGERS
-- ---------------------------------------------------------------------------

-- 1) Auditoria: toda mudança de status gera uma linha no histórico
DROP TRIGGER IF EXISTS trg_Tickets_Historico;
CREATE TRIGGER trg_Tickets_Historico
AFTER UPDATE OF Status ON Tickets
WHEN OLD.Status <> NEW.Status
BEGIN
    INSERT INTO TicketsHistorico (TicketId, StatusAnterior, StatusNovo)
    VALUES (NEW.Id, OLD.Status, NEW.Status);
END;

-- 2) Ao resolver: grava a data de resolução e leva o progresso a 100%
DROP TRIGGER IF EXISTS trg_Tickets_Resolucao;
CREATE TRIGGER trg_Tickets_Resolucao
AFTER UPDATE OF Status ON Tickets
WHEN NEW.Status = 'Resolvido' AND OLD.Status <> 'Resolvido'
BEGIN
    UPDATE Tickets
       SET ResolvidoEm = COALESCE(ResolvidoEm, strftime('%Y-%m-%d %H:%M:%f', 'now')),
           Progresso   = 100
     WHERE Id = NEW.Id;
END;

-- 3) Usuários não são apagados: o DELETE vira desativação (preserva histórico e vínculos)
DROP TRIGGER IF EXISTS trg_Usuarios_ExclusaoLogica;
CREATE TRIGGER trg_Usuarios_ExclusaoLogica
BEFORE DELETE ON Usuarios
BEGIN
    UPDATE Usuarios SET Ativo = 0 WHERE Id = OLD.Id;
    SELECT RAISE(IGNORE);
END;
