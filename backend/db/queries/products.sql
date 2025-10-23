-- name: GetProducts :many
SELECT 
    id,
    name,
    category,
    price,
    description,
    stock,
    created_at,
    updated_at
FROM products
WHERE 
    (CASE WHEN sqlc.arg(product_name)::text != '' THEN 
        name ILIKE '%' || sqlc.arg(product_name)::text || '%' 
    ELSE TRUE END)
    AND (CASE WHEN sqlc.arg(category)::text != '' THEN 
        category = sqlc.arg(category)::text 
    ELSE TRUE END)
    AND (CASE WHEN sqlc.arg(min_price) > 0 THEN 
        price >= sqlc.arg(min_price) 
    ELSE TRUE END)
    AND (CASE WHEN sqlc.arg(max_price) > 0 THEN 
        price <= sqlc.arg(max_price) 
    ELSE TRUE END)
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: CountProducts :one
SELECT COUNT(*)
FROM products
WHERE 
    (CASE WHEN sqlc.arg(product_name)::text != '' THEN 
        name ILIKE '%' || sqlc.arg(product_name)::text || '%' 
    ELSE TRUE END)
    AND (CASE WHEN sqlc.arg(category)::text != '' THEN 
        category = sqlc.arg(category)::text 
    ELSE TRUE END)
    AND (CASE WHEN sqlc.arg(min_price) > 0 THEN 
        price >= sqlc.arg(min_price) 
    ELSE TRUE END)
    AND (CASE WHEN sqlc.arg(max_price) > 0 THEN 
        price <= sqlc.arg(max_price) 
    ELSE TRUE END);

-- name: GetProductByID :one
SELECT 
    id,
    name,
    category,
    price,
    description,
    stock,
    created_at,
    updated_at
FROM products
WHERE id = $1;

-- name: CreateProduct :one
INSERT INTO products (
    name,
    category,
    price,
    description,
    stock
) VALUES (
    $1, $2, $3, $4, $5
)
RETURNING id, name, category, price, description, stock, created_at, updated_at;

-- name: UpdateProduct :one
UPDATE products
SET 
    name = COALESCE(NULLIF($2, ''), name),
    category = COALESCE(NULLIF($3, ''), category),
    price = COALESCE(NULLIF($4, 0), price),
    description = COALESCE(NULLIF($5, ''), description),
    stock = COALESCE(NULLIF($6, -1), stock)
WHERE id = $1
RETURNING id, name, category, price, description, stock, created_at, updated_at;

-- name: DeleteProduct :exec
DELETE FROM products
WHERE id = $1;

-- name: GetCategories :many
SELECT DISTINCT category
FROM products
ORDER BY category;

-- name: GetProductStats :one
SELECT 
    COUNT(*) as total_products,
    COUNT(DISTINCT category) as total_categories,
    COALESCE(AVG(price), 0) as average_price,
    COALESCE(MIN(price), 0) as min_price,
    COALESCE(MAX(price), 0) as max_price,
    COALESCE(SUM(stock), 0) as total_stock
FROM products;