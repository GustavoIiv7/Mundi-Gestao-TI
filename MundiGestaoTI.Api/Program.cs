using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using MundiGestaoTI.Data;
using MundiGestaoTI.Services;

var builder = WebApplication.CreateBuilder(args);

// ── BANCO DE DADOS ────────────────────────────────────────────────────────────
// "Database:Provider" no appsettings: "Sqlite" (padrão, não exige instalação) ou "SqlServer".
var provedor = builder.Configuration["Database:Provider"] ?? "Sqlite";

builder.Services.AddDbContext<AppDbContext>(options =>
{
    if (provedor.Equals("SqlServer", StringComparison.OrdinalIgnoreCase))
        options.UseSqlServer(builder.Configuration.GetConnectionString("SqlServer"));
    else
        options.UseSqlite(builder.Configuration.GetConnectionString("Sqlite") ?? "Data Source=mundi.db");
});

// ── AUTENTICAÇÃO JWT ──────────────────────────────────────────────────────────
// A chave NÃO deve ficar no repositório: em produção use variável de ambiente (Jwt__Key)
// ou user-secrets (dotnet user-secrets set "Jwt:Key" "...").
var jwtKey = builder.Configuration["Jwt:Key"];
if (string.IsNullOrWhiteSpace(jwtKey) || jwtKey.Length < 32)
    throw new InvalidOperationException(
        "Jwt:Key não configurado (mínimo de 32 caracteres). " +
        "Use user-secrets ou a variável de ambiente Jwt__Key.");

var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "MundiGestaoTI";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        // Mantém os nomes dos claims como estão no token ("sub", "name", "role")
        options.MapInboundClaims = false;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtIssuer,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            NameClaimType = "name",
            RoleClaimType = "role",
            ClockSkew = TimeSpan.FromMinutes(1)
        };
    });

builder.Services.AddAuthorization();

// ── INJEÇÃO DE DEPENDÊNCIA ────────────────────────────────────────────────────
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUsuarioService, UsuarioService>();
builder.Services.AddScoped<ITicketService, TicketService>();
builder.Services.AddScoped<IAreaService, AreaService>();
builder.Services.AddScoped<IMensagemService, MensagemService>();

// ── CORS ──────────────────────────────────────────────────────────────────────
// Em desenvolvimento libera qualquer porta de localhost (o "flutter run -d chrome"
// usa uma porta aleatória). Em produção, só as origens de "Cors:Origens".
var origensPermitidas = builder.Configuration.GetSection("Cors:Origens").Get<string[]>()
                        ?? Array.Empty<string>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontEnd", policy =>
    {
        policy.SetIsOriginAllowed(origem =>
            {
                if (!Uri.TryCreate(origem, UriKind.Absolute, out var uri)) return false;

                // Desenvolvimento: localhost e IPs de rede local (teste pelo celular na mesma rede Wi-Fi)
                if (builder.Environment.IsDevelopment() &&
                    (uri.Host == "localhost" || uri.Host == "127.0.0.1" ||
                     uri.Host.StartsWith("192.168.") || uri.Host.StartsWith("10.") ||
                     System.Text.RegularExpressions.Regex.IsMatch(uri.Host, @"^172\.(1[6-9]|2\d|3[01])\.")))
                    return true;

                return origensPermitidas.Contains(origem, StringComparer.OrdinalIgnoreCase);
            })
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddControllers();
builder.Services.AddProblemDetails();

// ── SWAGGER ───────────────────────────────────────────────────────────────────
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Mundi Gestão TI — API",
        Version = "v1",
        Description = "API REST do portal interno de funcionários."
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Cole o token retornado por POST /api/auth/login."
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

// ── PIPELINE ──────────────────────────────────────────────────────────────────
var app = builder.Build();

// Cria o banco (se não existir) e popula os dados iniciais.
// Quando o banco definitivo for decidido, trocar por migrations (dotnet ef migrations add ...).
using (var escopo = app.Services.CreateScope())
{
    var db = escopo.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();

    if (app.Configuration.GetValue<bool>("Seed:Habilitar"))
        DbSeeder.Semear(db, app.Configuration.GetValue<bool>("Seed:DadosDemo"));
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "Mundi Gestão TI v1"));
    app.MapGet("/", () => Results.Redirect("/swagger"));
}
else
{
    app.UseExceptionHandler();
    app.UseHttpsRedirection();
}

app.UseCors("FrontEnd");
app.UseAuthentication(); // JWT vem ANTES de Authorization
app.UseAuthorization();
app.MapControllers();

app.Run();
