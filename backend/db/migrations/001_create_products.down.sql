-- Migration: 001_create_products (DOWN)
-- Description: Remove a tabela de produtos
-- Author: System
-- Date: 2025-01-15

DROP TRIGGER IF EXISTS update_products_updated_at ON products;
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP INDEX IF EXISTS idx_products_created_at;
DROP INDEX IF EXISTS idx_products_stock;
DROP INDEX IF EXISTS idx_products_price;
DROP INDEX IF EXISTS idx_products_category;
DROP INDEX IF EXISTS idx_products_name;
DROP TABLE IF EXISTS products;
DROP TYPE IF EXISTS product_category;
