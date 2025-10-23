import { ProductFilters } from "@/components/product-filters";
import { DataTable } from "@/components/data-table";
import { Pagination } from "@/components/pagination";
import { productColumns } from "@/components/product-columns";
import { useProducts } from "@/hooks/use-products";
import { Package } from "lucide-react";
import { useFilterStore } from "@/store/filter-store";
import { useEffect } from "react";

export function ProductsPage() {
  const { products, total, totalPages, isLoading, isFetching, isError, error } =
    useProducts();

  const setFetching = useFilterStore((state) => state.setFetching);

  useEffect(() => {
    setFetching(isFetching);
  }, [isFetching]);

  return (
    <div className="container mx-auto py-8 space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <Package className="h-8 w-8 text-primary" />
        <div>
          <h1 className="text-3xl font-bold tracking-tight">
            Catálogo de Produtos
          </h1>
          <p className="text-muted-foreground">
            Gerencie e visualize todos os produtos do seu e-commerce
          </p>
        </div>
      </div>

      {/* Filtros */}
      <ProductFilters />

      {/* Mensagem de erro */}
      {isError && (
        <div className="rounded-lg border border-destructive/50 bg-destructive/10 p-4">
          <div className="flex items-center gap-2">
            <svg
              className="h-5 w-5 text-destructive"
              fill="none"
              strokeWidth="2"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
              />
            </svg>
            <h3 className="font-semibold text-destructive">
              Erro ao carregar produtos
            </h3>
          </div>
          <p className="mt-2 text-sm text-destructive/80">
            {error instanceof Error
              ? error.message
              : "Ocorreu um erro desconhecido"}
          </p>
        </div>
      )}

      {/* Tabela de Produtos */}
      <div className="space-y-4">
        <DataTable
          data={products}
          columns={productColumns}
          isLoading={isLoading}
        />

        {/* Paginação */}
        {!isError && <Pagination totalPages={totalPages} totalItems={total} />}
      </div>
    </div>
  );
}
