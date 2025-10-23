package models

import (
	"time"

	"github.com/google/uuid"
)

// Product representa um produto no sistema
type Product struct {
	ID          uuid.UUID `json:"id"`
	Name        string    `json:"name"`
	Category    string    `json:"category"`
	Price       float64   `json:"price"`
	Description *string   `json:"description,omitempty"`
	Stock       int32     `json:"stock"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// ProductsResponse representa a resposta paginada de produtos
type ProductsResponse struct {
	Data       []Product `json:"data"`
	Total      int64     `json:"total"`
	Page       int       `json:"page"`
	PageSize   int       `json:"pageSize"`
	TotalPages int       `json:"totalPages"`
}

// ProductFilters representa os filtros de busca de produtos
type ProductFilters struct {
	ProductName string  `form:"productName"`
	Category    string  `form:"category"`
	MinPrice    float64 `form:"minPrice"`
	MaxPrice    float64 `form:"maxPrice"`
	Page        int     `form:"page" binding:"min=1"`
	PageSize    int     `form:"pageSize" binding:"min=1,max=100"`
}

// HealthCheckResponse representa a resposta do health check
type HealthCheckResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Database  string    `json:"database"`
}

// ErrorResponse representa uma resposta de erro
type ErrorResponse struct {
	Error   string    `json:"error"`
	Message string    `json:"message,omitempty"`
	Time    time.Time `json:"timestamp"`
}

// ProductStats representa estatísticas dos produtos
type ProductStats struct {
	TotalProducts    int64   `json:"total_products"`
	TotalCategories  int64   `json:"total_categories"`
	AveragePrice     float64 `json:"average_price"`
	MinPrice         float64 `json:"min_price"`
	MaxPrice         float64 `json:"max_price"`
	TotalStock       int64   `json:"total_stock"`
}

// SetDefaults define valores padrão para ProductFilters
func (f *ProductFilters) SetDefaults() {
	if f.Page < 1 {
		f.Page = 1
	}
	if f.PageSize < 1 {
		f.PageSize = 10
	}
	if f.PageSize > 100 {
		f.PageSize = 100
	}
	if f.MinPrice < 0 {
		f.MinPrice = 0
	}
	if f.MaxPrice < 0 {
		f.MaxPrice = 0
	}
}

// GetOffset calcula o offset para paginação
func (f *ProductFilters) GetOffset() int {
	return (f.Page - 1) * f.PageSize
}

// GetLimit retorna o limite de itens por página
func (f *ProductFilters) GetLimit() int {
	return f.PageSize
}

// CalculateTotalPages calcula o número total de páginas
func CalculateTotalPages(total int64, pageSize int) int {
	if pageSize == 0 {
		return 0
	}
	pages := int(total) / pageSize
	if int(total)%pageSize > 0 {
		pages++
	}
	return pages
}