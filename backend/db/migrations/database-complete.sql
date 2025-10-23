-- ============================================================================
-- Script DDL Completo - Sistema de Produtos E-commerce
-- ============================================================================
-- Descrição: Script completo para criação de banco de dados, tabelas,
--            índices, triggers e dados de exemplo
-- Versão: 1.0.0
-- Data: 2025-01-15
-- Banco: PostgreSQL 14+
-- ============================================================================

-- ============================================================================
-- SECTION 1: CRIAR BANCO DE DADOS
-- ============================================================================

-- Descomente as linhas abaixo se quiser criar o banco a partir deste script
-- DROP DATABASE IF EXISTS ecommerce_products;
-- CREATE DATABASE ecommerce_products;
-- \c ecommerce_products;

-- ============================================================================
-- SECTION 2: EXTENSÕES
-- ============================================================================

-- Extensão para geração de UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Extensão para busca full-text em português
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- ============================================================================
-- SECTION 3: TIPOS CUSTOMIZADOS (ENUMS)
-- ============================================================================

-- Enum para categorias de produtos
DROP TYPE IF EXISTS product_category CASCADE;
CREATE TYPE product_category AS ENUM (
    'Eletrônicos',
    'Roupas',
    'Livros',
    'Esportes',
    'Casa e Decoração'
);

-- ============================================================================
-- SECTION 4: TABELAS
-- ============================================================================

-- Tabela principal de produtos
DROP TABLE IF EXISTS products CASCADE;
CREATE TABLE products (
    -- Chave primária
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Dados do produto
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    description TEXT,
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT name_not_empty CHECK (LENGTH(TRIM(name)) > 0),
    CONSTRAINT category_not_empty CHECK (LENGTH(TRIM(category)) > 0)
);

-- ============================================================================
-- SECTION 5: ÍNDICES
-- ============================================================================

-- Índice para busca full-text no nome do produto (com suporte a português)
CREATE INDEX idx_products_name_fts ON products 
USING gin(to_tsvector('portuguese', name));

-- Índice para busca case-insensitive no nome
CREATE INDEX idx_products_name_lower ON products (LOWER(name));

-- Índice para filtro por categoria
CREATE INDEX idx_products_category ON products(category);

-- Índice para filtro por faixa de preço
CREATE INDEX idx_products_price ON products(price);

-- Índice para filtro por estoque
CREATE INDEX idx_products_stock ON products(stock);

-- Índice composto para queries mais complexas
CREATE INDEX idx_products_category_price ON products(category, price);

-- Índice para ordenação por data de criação (descendente)
CREATE INDEX idx_products_created_at_desc ON products(created_at DESC);

-- Índice para ordenação por data de atualização (descendente)
CREATE INDEX idx_products_updated_at_desc ON products(updated_at DESC);

-- ============================================================================
-- SECTION 6: FUNÇÕES E TRIGGERS
-- ============================================================================

-- Função para atualizar o campo updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para chamar a função antes de UPDATE
DROP TRIGGER IF EXISTS trigger_update_products_updated_at ON products;
CREATE TRIGGER trigger_update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Função para validar categoria
CREATE OR REPLACE FUNCTION validate_product_category()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.category NOT IN ('Eletrônicos', 'Roupas', 'Livros', 'Esportes', 'Casa e Decoração') THEN
        RAISE EXCEPTION 'Categoria inválida: %. Categorias válidas: Eletrônicos, Roupas, Livros, Esportes, Casa e Decoração', NEW.category;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar categoria
DROP TRIGGER IF EXISTS trigger_validate_category ON products;
CREATE TRIGGER trigger_validate_category
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION validate_product_category();

-- ============================================================================
-- SECTION 7: VIEWS
-- ============================================================================

-- View com estatísticas dos produtos
CREATE OR REPLACE VIEW vw_product_stats AS
SELECT 
    category,
    COUNT(*) as total_produtos,
    MIN(price) as preco_minimo,
    MAX(price) as preco_maximo,
    AVG(price)::DECIMAL(10,2) as preco_medio,
    SUM(stock) as estoque_total
FROM products
GROUP BY category
ORDER BY category;

-- View com produtos em baixo estoque
CREATE OR REPLACE VIEW vw_low_stock_products AS
SELECT 
    id,
    name,
    category,
    price,
    stock,
    CASE 
        WHEN stock = 0 THEN 'Esgotado'
        WHEN stock <= 5 THEN 'Crítico'
        WHEN stock <= 10 THEN 'Baixo'
    END as status_estoque
FROM products
WHERE stock <= 10
ORDER BY stock ASC, name;

-- View com produtos mais caros por categoria
CREATE OR REPLACE VIEW vw_expensive_products_by_category AS
SELECT DISTINCT ON (category)
    category,
    name,
    price,
    stock
FROM products
ORDER BY category, price DESC;

-- ============================================================================
-- SECTION 8: COMENTÁRIOS
-- ============================================================================

-- Comentários na tabela
COMMENT ON TABLE products IS 'Tabela principal de produtos do e-commerce';

-- Comentários nas colunas
COMMENT ON COLUMN products.id IS 'Identificador único do produto (UUID v4)';
COMMENT ON COLUMN products.name IS 'Nome comercial do produto';
COMMENT ON COLUMN products.category IS 'Categoria do produto (Eletrônicos, Roupas, Livros, Esportes, Casa e Decoração)';
COMMENT ON COLUMN products.price IS 'Preço unitário do produto em reais (BRL)';
COMMENT ON COLUMN products.description IS 'Descrição detalhada do produto';
COMMENT ON COLUMN products.stock IS 'Quantidade disponível em estoque';
COMMENT ON COLUMN products.created_at IS 'Data e hora de criação do registro';
COMMENT ON COLUMN products.updated_at IS 'Data e hora da última atualização do registro';

-- ============================================================================
-- SECTION 9: DADOS DE EXEMPLO
-- ============================================================================

-- Inserir 25 produtos de exemplo
INSERT INTO products (name, category, price, description, stock) VALUES
-- ELETRÔNICOS (7 produtos)
('Notebook Dell Inspiron 15', 'Eletrônicos', 3499.90, 'Intel Core i7, 16GB RAM, SSD 512GB', 15),
('Mouse Logitech MX Master 3', 'Eletrônicos', 549.90, 'Mouse ergonômico sem fio', 45),
('Teclado Mecânico Keychron K2', 'Eletrônicos', 799.00, 'Switches Blue, Wireless', 8),
('iPhone 15 Pro', 'Eletrônicos', 7999.00, '256GB, Titanium Blue', 12),
('Samsung Galaxy Watch 6', 'Eletrônicos', 1899.00, 'Smartwatch com GPS', 18),
('Fone Sony WH-1000XM5', 'Eletrônicos', 2299.00, 'Cancelamento de ruído ativo', 11),
('Monitor LG 27" 4K', 'Eletrônicos', 1899.00, 'IPS, HDR10, 60Hz', 14),

-- ROUPAS (6 produtos)
('Camiseta Nike Dri-FIT', 'Roupas', 129.90, 'Tecnologia de secagem rápida', 120),
('Calça Jeans Levi''s 501', 'Roupas', 399.90, 'Corte reto clássico', 67),
('Jaqueta de Couro', 'Roupas', 899.00, 'Couro genuíno, cor preta', 9),
('Sapato Social Masculino', 'Roupas', 349.00, 'Couro legítimo', 31),
('Vestido Floral Verão', 'Roupas', 189.90, 'Tecido leve e confortável', 38),
('Moletom Nike Sportswear', 'Roupas', 299.00, 'Com capuz, algodão', 52),

-- LIVROS (4 produtos)
('Clean Code - Robert Martin', 'Livros', 89.90, 'Habilidades Práticas do Agile Software', 34),
('O Hobbit - J.R.R. Tolkien', 'Livros', 45.00, 'Edição ilustrada', 28),
('Harry Potter - Box Completo', 'Livros', 259.90, '7 livros em caixa especial', 15),
('Sapiens - Yuval Harari', 'Livros', 54.90, 'Uma breve história da humanidade', 48),

-- ESPORTES (4 produtos)
('Bola de Futebol Nike', 'Esportes', 149.90, 'Bola oficial size 5', 55),
('Tênis Adidas Ultraboost', 'Esportes', 899.00, 'Tecnologia Boost de amortecimento', 22),
('Halteres 10kg (Par)', 'Esportes', 299.00, 'Revestimento emborrachado', 27),
('Tapete de Yoga Premium', 'Esportes', 159.90, 'Material antiderrapante, 6mm', 62),

-- CASA E DECORAÇÃO (4 produtos)
('Sofá 3 Lugares Cinza', 'Casa e Decoração', 2499.00, 'Tecido premium, design moderno', 5),
('Luminária de Mesa LED', 'Casa e Decoração', 179.90, 'Regulagem de intensidade', 41),
('Mesa de Jantar 6 Lugares', 'Casa e Decoração', 1899.00, 'Madeira maciça, acabamento natural', 3),
('Quadro Decorativo Abstrato', 'Casa e Decoração', 249.00, '80x60cm, moldura inclusa', 19);

-- ============================================================================
-- SECTION 10: VERIFICAÇÃO E ESTATÍSTICAS
-- ============================================================================

-- Contar total de produtos
SELECT 
    'Total de Produtos' as metrica,
    COUNT(*) as valor
FROM products;

-- Estatísticas por categoria
SELECT * FROM vw_product_stats;

-- Produtos em baixo estoque
SELECT * FROM vw_low_stock_products;

-- Produtos mais caros por categoria
SELECT * FROM vw_expensive_products_by_category;

-- ============================================================================
-- SECTION 11: GRANTS (PERMISSÕES)
-- ============================================================================

-- Criar usuário da aplicação (opcional)
-- DROP USER IF EXISTS products_api_user;
-- CREATE USER products_api_user WITH PASSWORD 'senha_segura_aqui';

-- Conceder permissões
-- GRANT CONNECT ON DATABASE ecommerce_products TO products_api_user;
-- GRANT USAGE ON SCHEMA public TO products_api_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON products TO products_api_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO products_api_user;

-- ============================================================================
-- SECTION 12: QUERIES DE EXEMPLO
-- ============================================================================

-- Buscar produtos por nome
-- SELECT * FROM products WHERE name ILIKE '%notebook%';

-- Buscar produtos por categoria
-- SELECT * FROM products WHERE category = 'Eletrônicos';

-- Buscar produtos por faixa de preço
-- SELECT * FROM products WHERE price BETWEEN 100 AND 500;

-- Buscar produtos com paginação
-- SELECT * FROM products ORDER BY created_at DESC LIMIT 10 OFFSET 0;

-- Buscar com múltiplos filtros
-- SELECT * FROM products 
-- WHERE category = 'Eletrônicos' 
--   AND price >= 1000 
--   AND stock > 0
-- ORDER BY price DESC
-- LIMIT 10;

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE NOTICE '✅ Script DDL executado com sucesso!';
    RAISE NOTICE '📊 Total de produtos inseridos: %', (SELECT COUNT(*) FROM products);
    RAISE NOTICE '📁 Total de categorias: %', (SELECT COUNT(DISTINCT category) FROM products);
END $$;


-- ============================================================================
-- Script de Inserção de 50 Novos Produtos
-- ============================================================================
-- Descrição: Adiciona 50 produtos diversos ao catálogo do e-commerce
-- Categorias: Eletrônicos, Roupas, Livros, Esportes, Casa e Decoração
-- ============================================================================

INSERT INTO products (name, category, price, description, stock) VALUES

-- ============================================================================
-- ELETRÔNICOS (15 produtos)
-- ============================================================================
('Tablet Samsung Galaxy Tab S9', 'Eletrônicos', 2899.00, 'Tela 11", 128GB, S Pen inclusa', 23),
('Câmera Canon EOS R50', 'Eletrônicos', 4299.00, 'Mirrorless 24.2MP, 4K Video', 8),
('SSD Kingston 1TB NVMe', 'Eletrônicos', 449.00, 'Velocidade 7000MB/s leitura', 67),
('Roteador TP-Link AX5400', 'Eletrônicos', 699.00, 'Wi-Fi 6, Dual Band, 6 antenas', 34),
('Webcam Logitech C920', 'Eletrônicos', 459.00, 'Full HD 1080p, Microfone Estéreo', 42),
('HD Externo Seagate 2TB', 'Eletrônicos', 389.00, 'USB 3.0, Portátil', 56),
('Smart TV LG 55" OLED', 'Eletrônicos', 5499.00, '4K, WebOS, ThinQ AI', 9),
('Alexa Echo Dot 5ª Geração', 'Eletrônicos', 349.00, 'Smart Speaker, Bluetooth', 78),
('Impressora HP DeskJet', 'Eletrônicos', 449.00, 'Multifuncional, Wi-Fi, Scanner', 29),
('Carregador Anker 65W', 'Eletrônicos', 189.00, 'GaN, 3 portas USB-C', 95),
('PlayStation 5 Slim', 'Eletrônicos', 4499.00, '1TB, Controle DualSense', 6),
('Nintendo Switch OLED', 'Eletrônicos', 2399.00, 'Tela OLED 7", 64GB', 18),
('Kindle Paperwhite', 'Eletrônicos', 649.00, '8GB, Tela 6.8", À prova d\'água', 41),
('Apple AirPods Pro 2', 'Eletrônicos', 2199.00, 'Cancelamento de ruído, USB-C', 14),
('GoPro Hero 12 Black', 'Eletrônicos', 2899.00, '5.3K Video, HyperSmooth 6.0', 11),

-- ============================================================================
-- ROUPAS (12 produtos)
-- ============================================================================
('Tênis Nike Air Max 270', 'Roupas', 699.00, 'Amortecimento Air, Casual', 47),
('Camisa Polo Lacoste', 'Roupas', 449.00, 'Algodão Piqué, Logo Bordado', 63),
('Shorts Adidas Treino', 'Roupas', 159.90, 'Tecido Respirável, Climalite', 89),
('Jaqueta Corta-Vento Puma', 'Roupas', 329.00, 'À prova d\'água, Leve', 34),
('Calça Legging Lupo', 'Roupas', 129.00, 'Fitness, Cintura Alta', 72),
('Blusa de Frio Hering', 'Roupas', 189.00, 'Moletom 80% Algodão', 55),
('Bermuda Jeans Masculina', 'Roupas', 159.00, 'Lavagem Clara, Bolsos', 41),
('Saia Midi Floral', 'Roupas', 149.00, 'Tecido Fluido, Elástico', 38),
('Blazer Feminino Social', 'Roupas', 349.00, 'Corte Alfaiataria, Preto', 22),
('Meia Lupo Kit 6 Pares', 'Roupas', 49.90, 'Cano Curto, Algodão', 156),
('Boné New Era 9FIFTY', 'Roupas', 189.00, 'Aba Reta, Ajustável', 68),
('Óculos de Sol Ray-Ban', 'Roupas', 599.00, 'Proteção UV400, Wayfarer', 25),

-- ============================================================================
-- LIVROS (8 produtos)
-- ============================================================================
('1984 - George Orwell', 'Livros', 39.90, 'Clássico da literatura distópica', 67),
('Código Limpo - Robert Martin', 'Livros', 89.90, 'Guia de boas práticas', 43),
('A Sutil Arte de Ligar o F*da-se', 'Livros', 44.90, 'Mark Manson, Autoajuda', 82),
('O Poder do Hábito', 'Livros', 49.90, 'Charles Duhigg, Desenvolvimento Pessoal', 54),
('Rápido e Devagar', 'Livros', 69.90, 'Daniel Kahneman, Psicologia', 36),
('As Crônicas de Gelo e Fogo Vol.1', 'Livros', 59.90, 'George R.R. Martin, Fantasy', 41),
('O Senhor dos Anéis - Caixa', 'Livros', 189.00, 'Trilogia Completa, J.R.R. Tolkien', 19),
('Atomic Habits', 'Livros', 54.90, 'James Clear, Hábitos', 71),

-- ============================================================================
-- ESPORTES (8 produtos)
-- ============================================================================
('Bicicleta Mountain Bike Caloi', 'Esportes', 1899.00, 'Aro 29, 21 Marchas, Freio a Disco', 12),
('Esteira Ergométrica Dream', 'Esportes', 2499.00, '12 Programas, Vel. Max 16km/h', 7),
('Kit Elásticos Exercício', 'Esportes', 79.90, '5 Níveis Resistência, Fitness', 94),
('Luvas Boxe Everlast', 'Esportes', 189.00, '12oz, Couro Sintético', 38),
('Mochila Térmica Coleman', 'Esportes', 159.00, '24 Litros, Camping', 45),
('Barraca Camping 4 Pessoas', 'Esportes', 449.00, 'Impermeável, Ventilação', 16),
('Corda Pular Profissional', 'Esportes', 49.90, 'Rolamento Duplo, Ajustável', 127),
('Suporte para Barra Fixa', 'Esportes', 189.00, 'Montagem em Porta, Até 150kg', 31),

-- ============================================================================
-- CASA E DECORAÇÃO (7 produtos)
-- ============================================================================
('Aspirador Robô Xiaomi', 'Casa e Decoração', 1299.00, 'Mapeamento Laser, Wi-Fi', 18),
('Jogo de Panelas Tramontina', 'Casa e Decoração', 599.00, 'Antiaderente, 5 Peças', 42),
('Colchão Ortobom King Size', 'Casa e Decoração', 2199.00, 'Molas Ensacadas, 158x198cm', 8),
('Rack para TV Madesa', 'Casa e Decoração', 449.00, 'Até 55", MDF, 2 Portas', 24),
('Cortina Blackout 3 Metros', 'Casa e Decoração', 189.00, 'Bloqueia 99% Luz, Ilhós', 56),
('Ventilador de Teto Spirit', 'Casa e Decoração', 379.00, 'Com Controle Remoto, 3 Pás', 33),
('Organizador Multiúso Plástico', 'Casa e Decoração', 89.90, 'Empilhável, 10 Litros', 87);