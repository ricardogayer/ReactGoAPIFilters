-- Migration: 001_create_products
-- Description: Cria a tabela de produtos do e-commerce
-- Author: System
-- Date: 2025-01-15

-- ==================================================
-- UP Migration
-- ==================================================

-- Criar extensão para UUID (se não existir)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Criar enum para categorias (opcional, mas recomendado)
CREATE TYPE product_category AS ENUM (
    'Eletrônicos',
    'Roupas',
    'Livros',
    'Esportes',
    'Casa e Decoração'
);

-- Criar tabela de produtos
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    description TEXT,
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Criar índices para melhorar performance de queries
CREATE INDEX idx_products_name ON products USING gin(to_tsvector('portuguese', name));
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_stock ON products(stock);
CREATE INDEX idx_products_created_at ON products(created_at DESC);

-- Criar função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Criar trigger para atualizar updated_at
CREATE TRIGGER update_products_updated_at 
    BEFORE UPDATE ON products 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Comentários na tabela e colunas
COMMENT ON TABLE products IS 'Tabela de produtos do e-commerce';
COMMENT ON COLUMN products.id IS 'Identificador único do produto (UUID)';
COMMENT ON COLUMN products.name IS 'Nome do produto';
COMMENT ON COLUMN products.category IS 'Categoria do produto';
COMMENT ON COLUMN products.price IS 'Preço do produto em reais';
COMMENT ON COLUMN products.description IS 'Descrição detalhada do produto';
COMMENT ON COLUMN products.stock IS 'Quantidade em estoque';
COMMENT ON COLUMN products.created_at IS 'Data e hora de criação';
COMMENT ON COLUMN products.updated_at IS 'Data e hora da última atualização';

-- ==================================================
-- DOWN Migration
-- ==================================================

-- Para reverter, execute:
-- DROP TRIGGER IF EXISTS update_products_updated_at ON products;
-- DROP FUNCTION IF EXISTS update_updated_at_column();
-- DROP INDEX IF EXISTS idx_products_created_at;
-- DROP INDEX IF EXISTS idx_products_stock;
-- DROP INDEX IF EXISTS idx_products_price;
-- DROP INDEX IF EXISTS idx_products_category;
-- DROP INDEX IF EXISTS idx_products_name;
-- DROP TABLE IF EXISTS products;
-- DROP TYPE IF EXISTS product_category;
