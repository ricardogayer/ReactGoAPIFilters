package main

import (
	"backend/database"
	"backend/handlers"
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Carregar variáveis de ambiente
	if err := godotenv.Load(); err != nil {
		log.Println("⚠️  Arquivo .env não encontrado, usando variáveis de ambiente do sistema")
	}

	// Configurar Gin
	ginMode := os.Getenv("GIN_MODE")
	if ginMode == "" {
		ginMode = "debug"
	}
	gin.SetMode(ginMode)

	// Conectar ao banco de dados
	dbConfig := database.LoadConfig()
	pool, err := database.NewConnection(dbConfig)
	if err != nil {
		log.Fatalf("❌ Erro ao conectar ao banco de dados: %v", err)
	}
	defer database.Close(pool)

	// Criar router
	router := gin.Default()

	// Configurar CORS
	allowedOrigins := strings.Split(os.Getenv("CORS_ALLOWED_ORIGINS"), ",")
	if len(allowedOrigins) == 0 || allowedOrigins[0] == "" {
		allowedOrigins = []string{"http://localhost:5173"}
	}

	router.Use(cors.New(cors.Config{
		AllowOrigins:     allowedOrigins,
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))
	// Logger middleware customizado
	router.Use(gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		return fmt.Sprintf("[%s] %s %s %d %s %s\n",
			param.TimeStamp.Format("2006-01-02 15:04:05"),
			param.Method,
			param.Path,
			param.StatusCode,
			param.Latency,
			param.ClientIP,
		)
	}))

	// Recovery middleware
	router.Use(gin.Recovery())

	// Criar handlers
	productHandler := handlers.NewProductHandler(pool)

	// Rotas da API
	api := router.Group("/api")
	{
		// Health check
		api.GET("/health", productHandler.HealthCheck)

		// Produtos
		api.GET("/products", productHandler.GetProducts)
		api.GET("/categories", productHandler.GetCategories)
		api.GET("/stats", productHandler.GetStats)
	}

	// Rota raiz
	router.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "API de Produtos - E-commerce",
			"version": "1.0.0",
			"endpoints": gin.H{
				"health":     "/api/health",
				"products":   "/api/products",
				"categories": "/api/categories",
				"stats":      "/api/stats",
			},
		})
	})

	// Configurar servidor
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	srv := &http.Server{
		Addr:         ":" + port,
		Handler:      router,
		ReadTimeout:  10 * time.Minute,
		WriteTimeout: 10 * time.Minute,
		IdleTimeout:  120 * time.Minute,
	}

	// Iniciar servidor em goroutine
	go func() {
		log.Printf("\n🚀 Servidor iniciado em http://localhost:%s", port)
		log.Printf("📦 Total de produtos no banco: %s", getDatabaseStats(pool))
		log.Printf("🔗 API disponível em http://localhost:%s/api/products", port)
		log.Printf("❤️  Health check em http://localhost:%s/api/health", port)
		log.Println("\nPressione CTRL+C para encerrar...")

		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("❌ Erro ao iniciar servidor: %v", err)
		}
	}()

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("\n🛑 Encerrando servidor...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Printf("❌ Erro ao encerrar servidor: %v", err)
	}

	log.Println("✅ Servidor encerrado com sucesso")
}

// getDatabaseStats retorna estatísticas do banco
func getDatabaseStats(pool interface{}) string {
	// Implementação simplificada
	return "conectado"
}
