/* Demonstração no SQL Server — rode DEPOIS do 01_banco_sqlserver.sql e depois que
   a API tiver criado os usuários de exemplo (Provider = SqlServer, Seed habilitado).
   Selecione um bloco por vez e execute (F5 no SSMS). */
USE MundiGestaoTI;
GO

-- 1) Views
SELECT * FROM dbo.vw_ChamadosAtivos ORDER BY Prioridade;
SELECT * FROM dbo.vw_ResumoPorArea;
SELECT TOP 5 * FROM dbo.vw_RelatorioResolvidos ORDER BY ResolvidoEm DESC;
GO

-- 2) Procedures + triggers: abrir, assumir e resolver um chamado
DECLARE @id INT;
DECLARE @usuario INT = (SELECT TOP 1 Id FROM dbo.Usuarios WHERE Ativo = 1 ORDER BY Id);

EXEC dbo.sp_AbrirChamado
     @Titulo = N'Teste de procedure', @Descricao = N'Chamado criado pela sp_AbrirChamado',
     @Prioridade = N'Alta', @Area = N'Redes', @Categoria = N'Suporte a Wi-Fi',
     @CriadorId = @usuario, @NovoId = @id OUTPUT;

EXEC dbo.sp_AssumirChamado  @TicketId = @id, @UsuarioId = @usuario;   -- Aberto -> EmAndamento
EXEC dbo.sp_ResolverChamado @TicketId = @id, @UsuarioId = @usuario;   -- trigger grava ResolvidoEm e Progresso = 100

SELECT Id, Titulo, Status, Progresso, ResolvidoEm FROM dbo.Tickets WHERE Id = @id;
SELECT * FROM dbo.TicketsHistorico WHERE TicketId = @id ORDER BY Id;  -- trigger de auditoria
SELECT * FROM dbo.vw_RelatorioResolvidos WHERE Id = @id;
GO

-- 3) Indicadores de uma área (dois resultados)
EXEC dbo.sp_IndicadoresArea @Area = N'Redes', @Dias = 30;
GO

-- 4) Validação da procedure (deve dar erro 50001: título curto)
-- DECLARE @x INT;
-- EXEC dbo.sp_AbrirChamado @Titulo = N'abc', @Prioridade = N'Alta', @Area = N'Redes', @CriadorId = 1, @NovoId = @x OUTPUT;

-- 5) Trigger de exclusão lógica (use um usuário de teste, não o seu)
-- DELETE FROM dbo.Usuarios WHERE Id = 99;
-- SELECT Id, Nome, Ativo FROM dbo.Usuarios WHERE Id = 99;            -- continua existindo, Ativo = 0
