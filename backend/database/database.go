package database

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Config contém as configurações do banco de dados
type Config struct {
	Host     string
	Port     string
	User     string
	Password string
	DBName   string
	SSLMode  string
}

// LoadConfig carrega configurações das variáveis de ambiente
func LoadConfig() *Config {
	return &Config{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "postgres"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
	}
}

// NewConnection cria uma nova conexão com o PostgreSQL
func NewConnection(cfg *Config) (*pgxpool.Pool, error) {
	// Construir DSN (Data Source Name)
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		cfg.Host, cfg.Port, cfg.User, cfg.Password, cfg.DBName, cfg.SSLMode,
	)

	// Configurar pool de conexões
	config, err := pgxpool.ParseConfig(dsn)
	if err != nil {
		return nil, fmt.Errorf("falha ao criar configuração do pool: %w", err)
	}

	// Configurações do pool
	config.MaxConns = 25
	config.MinConns = 5
	config.MaxConnLifetime = time.Hour
	config.MaxConnIdleTime = 30 * time.Minute
	config.HealthCheckPeriod = 1 * time.Minute

	// Criar pool de conexões
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		return nil, fmt.Errorf("falha ao criar pool de conexões: %w", err)
	}

	// Testar conexão
	if err := pool.Ping(ctx); err != nil {
		return nil, fmt.Errorf("falha ao conectar ao banco de dados: %w", err)
	}

	log.Printf("✅ Conectado ao PostgreSQL: %s:%s/%s", cfg.Host, cfg.Port, cfg.DBName)
	log.Printf("📊 Pool: MaxConns=%d, MinConns=%d", config.MaxConns, config.MinConns)

	return pool, nil
}

// Close fecha a conexão com o banco de dados
func Close(pool *pgxpool.Pool) {
	if pool != nil {
		pool.Close()
		log.Println("🔌 Conexão com banco de dados fechada")
	}
}

// getEnv retorna o valor de uma variável de ambiente ou um valor padrão
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}

// HealthCheck verifica se a conexão com o banco está saudável
func HealthCheck(ctx context.Context, pool *pgxpool.Pool) error {
	return pool.Ping(ctx)
}

// GetStats retorna estatísticas do pool de conexões
func GetStats(pool *pgxpool.Pool) string {
	stats := pool.Stat()
	return fmt.Sprintf(
		"AcquireCount: %d, AcquiredConns: %d, IdleConns: %d, TotalConns: %d",
		stats.AcquireCount(),
		stats.AcquiredConns(),
		stats.IdleConns(),
		stats.TotalConns(),
	)
}
