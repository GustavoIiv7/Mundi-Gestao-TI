# Mundi Gestão TI — API (PIM IV)

API REST em ASP.NET Core (net10.0) + Entity Framework Core + JWT. Serve o app Flutter e o portal web.

## Como rodar

A chave JWT não fica no repositório. Configure-a uma vez (User Secrets):

```bash
cd MundiGestaoTI.Api
dotnet user-secrets init
dotnet user-secrets set "Jwt:Key" "escolha-uma-chave-com-32-ou-mais-caracteres"
dotnet run
```

Abra http://localhost:5157/swagger (em Development, a raiz já redireciona).

Em Development o banco `mundi.db` (SQLite) é criado sozinho e populado com dados fictícios de demonstração.

### Usuários de demonstração (senha: `senha123`)

| Login | Área | Perfil |
|---|---|---|
| rafael.souza | Redes | Analista |
| anderson.souza | Banco de Dados | Analista |
| isabela.aparecida | Acessos | Analista |
| gustavo.de | Sistemas | Admin |

### Testando no Swagger
1. `POST /api/auth/login` com `{"login":"gustavo.de","senha":"senha123"}`.
2. Copie o `token`, clique em **Authorize** e cole o token.

## Banco de dados (SQL Server)

O projeto usa **SQL Server**. O script completo (tabelas, views, procedures e triggers) está em `Database/01_banco_sqlserver.sql`.

1. Instale o SQL Server (Express ou Developer) e o SSMS.
2. No SSMS, abra `Database/01_banco_sqlserver.sql` e execute (F5). Isso cria o banco `MundiGestaoTI`.
3. Confira a conexão em `appsettings.json` (`ConnectionStrings:SqlServer`). O padrão é a instância `localhost\SQLEXPRESS` com autenticação do Windows.
4. `dotnet run`. Na primeira vez, em Development, a API cria os usuários e dados de demonstração.

### Docker (Linux ou sem instalação)
```bash
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Mundi@2026Forte" -p 1433:1433 --name mundi-sql -d mcr.microsoft.com/mssql/server:2022-latest
export ConnectionStrings__SqlServer="Server=localhost,1433;Database=MundiGestaoTI;User Id=sa;Password=Mundi@2026Forte;TrustServerCertificate=True"
dotnet run
```
Rode o script `Database/01_banco_sqlserver.sql` no banco (extensão "SQL Server (mssql)" do VS Code ou `sqlcmd`).

### Voltar ao SQLite (sem instalar nada)
Em `appsettings.json`, troque `Database:Provider` para `Sqlite`. As views e triggers dessa versão estão em `Database/03_views_triggers_sqlite.sql`.

## Segurança

- A chave JWT **não** fica no repositório. Em produção: `Jwt__Key` (variável de ambiente) ou `dotnet user-secrets set "Jwt:Key" "<32+ caracteres>"`.
- Senhas com BCrypt. Perfil `Admin` necessário para `POST /api/auth/cadastrar` e `DELETE /api/tickets/{id}`.
- CORS: em Development, qualquer porta de localhost; em produção, apenas `Cors:Origens`.
- `Seed:Habilitar` e `Seed:DadosDemo` ficam `false` fora de Development.

## Endpoints (todos exigem token, exceto login)

| Método | Rota | Uso |
|---|---|---|
| POST | /api/auth/login | Login, devolve JWT |
| POST | /api/auth/cadastrar | Cria usuário (Admin) |
| GET | /api/usuarios?area= | Lista usuários |
| GET | /api/usuarios/contato/{area} | Contato do chat da área |
| GET | /api/tickets?area=&prioridade=&status=&responsavelId=&ativos= | Lista chamados (ordenados por prioridade e data) |
| GET/PUT | /api/tickets/{id} | Detalhe / atualização |
| POST | /api/tickets | Novo chamado |
| DELETE | /api/tickets/{id} | Remove (Admin) |
| GET | /api/areas/{area}/dashboard | Indicadores dos últimos 30 dias |
| GET | /api/areas/{area}/monitoramento | Abertos/em andamento com progresso |
| GET | /api/areas/{area}/relatorio?limite=5 | Últimos concluídos |
| GET | /api/mensagens/conversa/{id} | Histórico do chat |
| POST | /api/mensagens | Envia mensagem |
| PATCH | /api/mensagens/{id}/lida | Marca como lida |

`{area}` aceita: `redes`, `banco`, `acessos`, `sistemas`.

## Integração com o Flutter

- Web/desktop: `http://localhost:5157`. Emulador Android: `http://10.0.2.2:5157`.
- No app, `bancoDados` corresponde a `banco` na API.
- Datas vêm em UTC (com `Z`); no app use `DateTime.parse(...).toLocal()`.
