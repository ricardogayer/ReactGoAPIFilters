import { useQuery } from "@tanstack/react-query";
import { useFilterStore } from "@/store/filter-store";
import { productsApi } from "@/services/products-api";
import { type ProductsQueryParams } from "@/types/product";

export const useProducts = () => {
  const filters = useFilterStore((state) => state.filters);
  const pagination = useFilterStore((state) => state.pagination);

  const queryParams: ProductsQueryParams = {
    productName: filters.productName,
    category: filters.category,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
    page: pagination.pageIndex + 1, // API geralmente usa 1-based index
    pageSize: pagination.pageSize,
  };

  const query = useQuery({
    queryKey: ["products", queryParams],
    queryFn: () => productsApi.getProducts(queryParams),
    staleTime: 1000 * 60 * 5, // 5 minutos
    placeholderData: (previousData) => previousData, // Mantém dados anteriores enquanto carrega
  });

  return {
    products: query.data?.data ?? [],
    total: query.data?.total ?? 0,
    totalPages: query.data?.totalPages ?? 0,
    isLoading: query.isLoading,
    isFetching: query.isFetching,
    isError: query.isError,
    error: query.error,
    refetch: query.refetch,
  };
};
