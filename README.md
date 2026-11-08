# Mundi Gestão TI — PIM IV (UNIP, ADS)

Sistema de gerenciamento de chamados de suporte de TI, com quatro áreas (Redes, Banco de Dados, Acessos e Sistemas).

| Pasta | Conteúdo |
|---|---|
| `MundiGestaoTI.Api/` | API REST em ASP.NET Core (net10.0), Entity Framework Core, JWT, SQL Server (ou SQLite para testes) |
| `mundi_gestao_app/` | Aplicativo Flutter (web, desktop e mobile) que consome a API |
| `MundiGestaoTI.Api/Database/` | Scripts SQL (tabelas, views, procedures e triggers) |

## Como rodar a API

A chave do token JWT **não está no repositório**. Configure-a uma vez no seu computador (User Secrets):

```bash
cd MundiGestaoTI.Api
dotnet user-secrets init
dotnet user-secrets set "Jwt:Key" "escolha-uma-chave-com-32-ou-mais-caracteres"
```

Sem SQL Server instalado, use SQLite (o banco é criado sozinho, com dados fictícios de demonstração):

```bash
export Database__Provider=Sqlite      # Windows (PowerShell): $env:Database__Provider="Sqlite"
dotnet run
```

Documentação interativa: http://localhost:5157/swagger

Com SQL Server, rode antes `MundiGestaoTI.Api/Database/01_banco_sqlserver.sql` e confira `ConnectionStrings:SqlServer` em `appsettings.json`.

Usuários fictícios de demonstração (criados pela API em Development): `rafael.souza`, `anderson.souza`, `isabela.aparecida` (Analistas) e `gustavo.de` (Admin). A senha de demonstração está na seção de dados de teste do `README.md` da API.

## Como rodar o aplicativo

```bash
cd mundi_gestao_app
flutter pub get
flutter run -d chrome
```

Para apontar para outra API: `--dart-define=API_URL=http://IP:5157`.

## Equipe

Anderson Souza da Silva, Gustavo de Oliveira.
