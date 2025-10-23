package handlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"backend/db/sqlc"
	"backend/models"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

// ProductHandler gerencia as requisições de produtos
type ProductHandler struct {
	queries *sqlc.Queries
	pool    *pgxpool.Pool
}

// NewProductHandler cria uma nova instância do handler
func NewProductHandler(pool *pgxpool.Pool) *ProductHandler {
	return &ProductHandler{
		queries: sqlc.New(pool),
		pool:    pool,
	}
}

// GetProducts retorna produtos com filtros e paginação
// @Summary Lista produtos
// @Description Retorna lista de produtos com filtros e paginação
// @Tags products
// @Accept json
// @Produce json
// @Param productName query string false "Nome do produto"
// @Param category query string false "Categoria"
// @Param minPrice query number false "Preço mínimo"
// @Param maxPrice query number false "Preço máximo"
// @Param page query int false "Número da página" default(1)
// @Param pageSize query int false "Itens por página" default(10)
// @Success 200 {object} models.ProductsResponse
// @Failure 400 {object} models.ErrorResponse
// @Failure 500 {object} models.ErrorResponse
// @Router /api/products [get]
func (h *ProductHandler) GetProducts(c *gin.Context) {
	// Parse query parameters
	var filters models.ProductFilters
	if err := c.ShouldBindQuery(&filters); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Error:   "Parâmetros inválidos",
			Message: err.Error(),
			Time:    time.Now(),
		})
		return
	}

	// Set defaults
	filters.SetDefaults()

	// Log da requisição
	log.Printf("🔥 GET /api/products - Filtros: name=%s, category=%s, minPrice=%.2f, maxPrice=%.2f, page=%d, pageSize=%d",
		filters.ProductName, filters.Category, filters.MinPrice, filters.MaxPrice, filters.Page, filters.PageSize)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()

	time.Sleep(10 * time.Second) // Simula processamento demorado

	// Buscar produtos
	products, err := h.queries.GetProducts(ctx, sqlc.GetProductsParams{
		ProductName: filters.ProductName,
		Category:    filters.Category,
		MinPrice:    filters.MinPrice,
		MaxPrice:    filters.MaxPrice,
		Limit:       int32(filters.GetLimit()),
		Offset:      int32(filters.GetOffset()),
	})

	if err != nil {
		log.Printf("❌ Erro ao buscar produtos: %v", err)
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Error:   "Erro ao buscar produtos",
			Message: err.Error(),
			Time:    time.Now(),
		})
		return
	}

	// Contar total de produtos
	total, err := h.queries.CountProducts(ctx, sqlc.CountProductsParams{
		ProductName: filters.ProductName,
		Category:    filters.Category,
		MinPrice:    filters.MinPrice,
		MaxPrice:    filters.MaxPrice,
	})

	if err != nil {
		log.Printf("❌ Erro ao contar produtos: %v", err)
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Error:   "Erro ao contar produtos",
			Message: err.Error(),
			Time:    time.Now(),
		})
		return
	}

	// Converter para modelo de resposta
	responseData := make([]models.Product, len(products))
	for i, p := range products {
		// Converter pgtype.Text para *string
		var description *string
		if p.Description.Valid {
			description = &p.Description.String
		}
		
		responseData[i] = models.Product{
			ID:          p.ID,
			Name:        p.Name,
			Category:    p.Category,
			Price:       p.Price,
			Description: description,
			Stock:       p.Stock,
			CreatedAt:   p.CreatedAt.Time,
			UpdatedAt:   p.UpdatedAt.Time,
		}
	}

	// Calcular total de páginas
	totalPages := models.CalculateTotalPages(total, filters.PageSize)

	response := models.ProductsResponse{
		Data:       responseData,
		Total:      total,
		Page:       filters.Page,
		PageSize:   filters.PageSize,
		TotalPages: totalPages,
	}

	log.Printf("✅ Retornando %d de %d produtos (página %d de %d)",
		len(products), total, filters.Page, totalPages)

	c.JSON(http.StatusOK, response)
}

// HealthCheck verifica o status da API e do banco de dados
// @Summary Health check
// @Description Verifica o status da API e da conexão com o banco
// @Tags health
// @Accept json
// @Produce json
// @Success 200 {object} models.HealthCheckResponse
// @Failure 503 {object} models.ErrorResponse
// @Router /api/health [get]
func (h *ProductHandler) HealthCheck(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	dbStatus := "connected"
	if err := h.pool.Ping(ctx); err != nil {
		log.Printf("❌ Health check falhou: %v", err)
		dbStatus = "disconnected"
		c.JSON(http.StatusServiceUnavailable, models.ErrorResponse{
			Error:   "Banco de dados não disponível",
			Message: err.Error(),
			Time:    time.Now(),
		})
		return
	}

	response := models.HealthCheckResponse{
		Status:    "ok",
		Timestamp: time.Now(),
		Database:  dbStatus,
	}

	c.JSON(http.StatusOK, response)
}

// GetCategories retorna todas as categorias disponíveis
// @Summary Lista categorias
// @Description Retorna lista de todas as categorias únicas
// @Tags products
// @Accept json
// @Produce json
// @Success 200 {array} string
// @Failure 500 {object} models.ErrorResponse
// @Router /api/categories [get]
func (h *ProductHandler) GetCategories(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	categories, err := h.queries.GetCategories(ctx)
	if err != nil {
		log.Printf("❌ Erro ao buscar categorias: %v", err)
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Error:   "Erro ao buscar categorias",
			Message: err.Error(),
			Time:    time.Now(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"categories": categories,
		"total":      len(categories),
	})
}

// GetStats retorna estatísticas dos produtos
// @Summary Estatísticas
// @Description Retorna estatísticas gerais dos produtos
// @Tags products
// @Accept json
// @Produce json
// @Success 200 {object} models.ProductStats
// @Failure 500 {object} models.ErrorResponse
// @Router /api/stats [get]
func (h *ProductHandler) GetStats(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	stats, err := h.queries.GetProductStats(ctx)
	if err != nil {
		log.Printf("❌ Erro ao buscar estatísticas: %v", err)
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Error:   "Erro ao buscar estatísticas",
			Message: err.Error(),
			Time:    time.Now(),
		})
		return
	}

	// Type assertions seguras com valores padrão
	averagePrice := float64(0)
	if val, ok := stats.AveragePrice.(float64); ok {
		averagePrice = val
	}

	minPrice := float64(0)
	if val, ok := stats.MinPrice.(float64); ok {
		minPrice = val
	}

	maxPrice := float64(0)
	if val, ok := stats.MaxPrice.(float64); ok {
		maxPrice = val
	}

	totalStock := int64(0)
	if val, ok := stats.TotalStock.(int64); ok {
		totalStock = val
	}

	response := models.ProductStats{
		TotalProducts:   stats.TotalProducts,
		TotalCategories: stats.TotalCategories,
		AveragePrice:    averagePrice,
		MinPrice:        minPrice,
		MaxPrice:        maxPrice,
		TotalStock:      totalStock,
	}

	c.JSON(http.StatusOK, response)
}