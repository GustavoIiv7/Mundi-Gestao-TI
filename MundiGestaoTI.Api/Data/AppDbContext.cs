using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using MundiGestaoTI.Models;

namespace MundiGestaoTI.Data
{
    public class DataUtcConverter : ValueConverter<DateTime, DateTime>
    {
        public DataUtcConverter()
            : base(
                v => v.ToUniversalTime(),
                v => DateTime.SpecifyKind(v, DateTimeKind.Utc))
        {
        }
    }

    public class DataUtcNulavelConverter : ValueConverter<DateTime?, DateTime?>
    {
        public DataUtcNulavelConverter()
            : base(
                v => v.HasValue ? v.Value.ToUniversalTime() : v,
                v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : v)
        {
        }
    }

    /// <summary>Contexto do Entity Framework: tabelas, relacionamentos e índices.</summary>
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Usuario> Usuarios { get; set; }
        public DbSet<Ticket> Tickets { get; set; }
        public DbSet<Mensagem> Mensagens { get; set; }

        // Todas as datas são gravadas em UTC e lidas como UTC (o JSON sai com "Z",
        // e o app converte para o fuso do aparelho).
        protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
        {
            configurationBuilder.Properties<DateTime>().HaveConversion<DataUtcConverter>();
            configurationBuilder.Properties<DateTime?>().HaveConversion<DataUtcNulavelConverter>();
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Usuario>(entity =>
            {
                entity.ToTable("Usuarios");
                entity.HasIndex(u => u.Login).IsUnique();

                // Enums guardados como texto (legíveis no banco)
                entity.Property(u => u.Area).HasConversion<string>().HasMaxLength(20);
                entity.Property(u => u.Perfil).HasConversion<string>().HasMaxLength(20);

                entity.HasMany(u => u.TicketsCriados)
                      .WithOne(t => t.Criador)
                      .HasForeignKey(t => t.CriadorId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasMany(u => u.TicketsAtribuidos)
                      .WithOne(t => t.Responsavel)
                      .HasForeignKey(t => t.ResponsavelId)
                      .OnDelete(DeleteBehavior.SetNull);
            });

            modelBuilder.Entity<Ticket>(entity =>
            {
                entity.ToTable("Tickets");

                entity.Property(t => t.Prioridade).HasConversion<string>().HasMaxLength(20);
                entity.Property(t => t.Status).HasConversion<string>().HasMaxLength(20);
                entity.Property(t => t.Area).HasConversion<string>().HasMaxLength(20);

                entity.HasIndex(t => t.Status);
                entity.HasIndex(t => t.Prioridade);
                entity.HasIndex(t => t.CriadoEm);
                entity.HasIndex(t => new { t.Area, t.Status });
            });

            modelBuilder.Entity<Mensagem>(entity =>
            {
                entity.ToTable("Mensagens");

                entity.HasOne(m => m.Remetente)
                      .WithMany(u => u.Mensagens)
                      .HasForeignKey(m => m.RemetenteId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(m => m.Destinatario)
                      .WithMany()
                      .HasForeignKey(m => m.DestinatarioId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasIndex(m => m.EnviadaEm);
                entity.HasIndex(m => new { m.RemetenteId, m.DestinatarioId });
            });
        }
    }
}
