/* Demonstração no SQLite — rode DEPOIS do 03_views_triggers_sqlite.sql.
   Execute um bloco por vez (selecione o trecho e Ctrl+Enter). */

-- 1) Views
SELECT * FROM vw_ChamadosAtivos;
SELECT * FROM vw_ResumoPorArea;
SELECT * FROM vw_RelatorioResolvidos ORDER BY ResolvidoEm DESC LIMIT 5;

-- 2) Trigger de histórico + resolução: pegue um chamado ativo e resolva-o
--    (troque o Id abaixo por um chamado da vw_ChamadosAtivos)
UPDATE Tickets SET Status = 'Resolvido' WHERE Id = 1;

SELECT Id, Status, Progresso, ResolvidoEm FROM Tickets WHERE Id = 1;  -- Progresso = 100 e ResolvidoEm preenchido
SELECT * FROM TicketsHistorico WHERE TicketId = 1;                    -- mudança registrada

-- 3) Trigger de exclusão lógica: o DELETE não apaga, desativa
--    (cuidado: troque o Id por um usuário de teste, não use o seu)
-- DELETE FROM Usuarios WHERE Id = 99;
-- SELECT Id, Nome, Ativo FROM Usuarios WHERE Id = 99;                -- continua existindo, Ativo = 0
