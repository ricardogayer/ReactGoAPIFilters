import axios from "axios";
import {
  type ProductsResponse,
  type ProductsQueryParams,
} from "@/types/product";

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || "http://localhost:8080/api",
  // timeout: 10000,
});

export const productsApi = {
  getProducts: async (
    params: ProductsQueryParams
  ): Promise<ProductsResponse> => {
    // Limpa parâmetros vazios antes de enviar
    const cleanParams = Object.entries(params).reduce((acc, [key, value]) => {
      if (value !== "" && value !== undefined && value !== null) {
        acc[key] = value;
      }
      return acc;
    }, {} as Record<string, any>);

    const response = await api.get<ProductsResponse>("/products", {
      params: cleanParams,
    });

    return response.data;
  },
};
