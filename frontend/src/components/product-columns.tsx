import { type ColumnDef } from "@tanstack/react-table";
import { type Product } from "@/types/product";

export const productColumns: ColumnDef<Product>[] = [
  {
    accessorKey: "name",
    header: "Produto",
    cell: ({ row }) => {
      return (
        <div className="flex flex-col">
          <span className="font-medium">{row.original.name}</span>
          {row.original.description && (
            <span className="text-xs text-muted-foreground">
              {row.original.description}
            </span>
          )}
        </div>
      );
    },
  },
  {
    accessorKey: "category",
    header: "Categoria",
    cell: ({ row }) => {
      return (
        <span className="inline-flex items-center rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary">
          {row.original.category}
        </span>
      );
    },
  },
  {
    accessorKey: "price",
    header: "Preço",
    cell: ({ row }) => {
      const price = parseFloat(row.getValue("price"));
      const formatted = new Intl.NumberFormat("pt-BR", {
        style: "currency",
        currency: "BRL",
      }).format(price);

      return <span className="font-medium">{formatted}</span>;
    },
  },
  {
    accessorKey: "stock",
    header: "Estoque",
    cell: ({ row }) => {
      const stock = row.original.stock;
      const stockStatus =
        stock > 10 ? "Em estoque" : stock > 0 ? "Baixo estoque" : "Esgotado";
      const stockColor =
        stock > 10
          ? "text-green-600"
          : stock > 0
          ? "text-yellow-600"
          : "text-destructive";

      return (
        <div className="flex flex-col">
          <span className={`text-sm font-medium ${stockColor}`}>
            {stockStatus}
          </span>
          <span className="text-xs text-muted-foreground">
            {stock} unidades
          </span>
        </div>
      );
    },
  },
];
