import { useFilterStore } from "@/store/filter-store";
import { Button } from "@/components/ui/button";
import { Select } from "@/components/ui/select";
import {
  ChevronLeft,
  ChevronRight,
  ChevronsLeft,
  ChevronsRight,
} from "lucide-react";

interface PaginationProps {
  totalPages: number;
  totalItems: number;
}

export function Pagination({ totalPages, totalItems }: PaginationProps) {
  const pagination = useFilterStore((state) => state.pagination);
  const setPagination = useFilterStore((state) => state.setPagination);

  const currentPage = pagination.pageIndex + 1;
  const canGoBack = pagination.pageIndex > 0;
  const canGoForward = pagination.pageIndex < totalPages - 1;

  const handlePageChange = (newPageIndex: number) => {
    setPagination({
      ...pagination,
      pageIndex: newPageIndex,
    });
  };

  const handlePageSizeChange = (newPageSize: number) => {
    setPagination({
      pageIndex: 0, // Reset para primeira página ao mudar o tamanho
      pageSize: newPageSize,
    });
  };

  const startItem = pagination.pageIndex * pagination.pageSize + 1;
  const endItem = Math.min(
    (pagination.pageIndex + 1) * pagination.pageSize,
    totalItems
  );

  return (
    <div className="flex flex-col sm:flex-row items-center justify-between gap-4 px-2 py-4 bg-white border rounded-lg">
      {/* Informações de itens */}
      <div className="flex items-center gap-2 text-sm text-muted-foreground">
        <span>
          Mostrando {totalItems > 0 ? startItem : 0} a {endItem} de {totalItems}{" "}
          produtos
        </span>
      </div>

      {/* Controles de paginação */}
      <div className="flex items-center gap-6">
        {/* Seletor de itens por página */}
        <div className="flex items-center gap-2">
          <span className="text-sm text-muted-foreground">
            Itens por página:
          </span>
          <Select
            value={pagination.pageSize.toString()}
            onValueChange={(e) => handlePageSizeChange(Number(e))}
          >
            <option value="5">5</option>
            <option value="10">10</option>
            <option value="20">20</option>
            <option value="50">50</option>
            <option value="100">100</option>
          </Select>
        </div>

        {/* Botões de navegação */}
        <div className="flex items-center gap-2">
          <Button
            variant="outline"
            size="icon"
            onClick={() => handlePageChange(0)}
            disabled={!canGoBack}
            title="Primeira página"
          >
            <ChevronsLeft className="h-4 w-4" />
          </Button>

          <Button
            variant="outline"
            size="icon"
            onClick={() => handlePageChange(pagination.pageIndex - 1)}
            disabled={!canGoBack}
            title="Página anterior"
          >
            <ChevronLeft className="h-4 w-4" />
          </Button>

          <div className="flex items-center gap-1 px-2">
            <span className="text-sm font-medium">
              Página {totalPages > 0 ? currentPage : 0} de {totalPages}
            </span>
          </div>

          <Button
            variant="outline"
            size="icon"
            onClick={() => handlePageChange(pagination.pageIndex + 1)}
            disabled={!canGoForward}
            title="Próxima página"
          >
            <ChevronRight className="h-4 w-4" />
          </Button>

          <Button
            variant="outline"
            size="icon"
            onClick={() => handlePageChange(totalPages - 1)}
            disabled={!canGoForward}
            title="Última página"
          >
            <ChevronsRight className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>
  );
}
