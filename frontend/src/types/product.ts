export interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  description?: string;
  stock: number;
}

export interface ProductsResponse {
  data: Product[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface ProductsQueryParams {
  productName?: string;
  category?: string;
  minPrice?: number | string;
  maxPrice?: number | string;
  page: number;
  pageSize: number;
}
