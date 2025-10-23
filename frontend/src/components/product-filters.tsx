import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { type FilterSchema, filterSchema } from "@/schemas/filter-schema";
import { useFilterStore } from "@/store/filter-store";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Search, X } from "lucide-react";
import { Spinner } from "@/components/ui/spinner";
import { useEffect } from "react";

const categories = [
  { value: "Eletrônicos", label: "Eletrônicos" },
  { value: "Roupas", label: "Roupas" },
  { value: "Livros", label: "Livros" },
  { value: "Esportes", label: "Esportes" },
  { value: "Casa e Decoração", label: "Casa e Decoração" },
];

export function ProductFilters() {
  const setFilters = useFilterStore((state) => state.setFilters);
  const resetFilters = useFilterStore((state) => state.resetFilters);
  const currentFilters = useFilterStore((state) => state.filters);
  const isFetching = useFilterStore((state) => state.isFetching);

  const {
    handleSubmit,
    reset,
    control,
    formState: { errors },
  } = useForm<FilterSchema>({
    resolver: zodResolver(filterSchema),
    defaultValues: currentFilters,
  });

  // Sincronizar o formulário com os filtros da store quando forem resetados
  useEffect(() => {
    reset(currentFilters);
  }, [currentFilters]);

  const onSubmit = (data: FilterSchema) => {
    setFilters(data);
  };

  const handleReset = () => {
    // Reset direto do formulário com valores vazios
    const emptyFilters = {
      productName: "",
      category: "",
      minPrice: "",
      maxPrice: "",
    };
    reset(emptyFilters);
    // Resetar a store também
    resetFilters();
  };

  return (
    <form
      onSubmit={handleSubmit(onSubmit)}
      className="space-y-4 p-6 bg-card rounded-lg border"
    >
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold">Filtros de Pesquisa</h2>
      </div>

      <div className="w-full grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Nome do Produto */}
        <div className="space-y-2 w-full">
          <Label htmlFor="productName">Nome do Produto</Label>
          <Controller
            name="productName"
            control={control}
            render={({ field }) => (
              <Input
                id="productName"
                placeholder="Todos os produtos"
                {...field}
              />
            )}
          />
          {errors.productName && (
            <p className="text-xs text-destructive">
              {errors.productName.message}
            </p>
          )}
        </div>

        {/* Categoria */}
        <div className="space-y-2 w-full">
          <Label htmlFor="category">Categoria</Label>
          <Controller
            name="category"
            control={control}
            render={({ field }) => (
              <Select value={field.value} onValueChange={field.onChange}>
                <SelectTrigger id="category" className="w-full">
                  <SelectValue placeholder="Todas as categorias" />
                </SelectTrigger>
                <SelectContent>
                  {categories.map((cat) => (
                    <SelectItem key={cat.value} value={cat.value}>
                      {cat.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            )}
          />
          {errors.category && (
            <p className="text-xs text-destructive">
              {errors.category.message}
            </p>
          )}
        </div>

        {/* Preço Mínimo */}
        <div className="space-y-2 w-full">
          <Label htmlFor="minPrice">Preço Mínimo (R$)</Label>
          <Controller
            name="minPrice"
            control={control}
            render={({ field }) => (
              <Input
                id="minPrice"
                type="number"
                step="0.01"
                min="0"
                placeholder="Sem mínimo"
                {...field}
              />
            )}
          />
          {errors.minPrice && (
            <p className="text-xs text-destructive">
              {errors.minPrice.message}
            </p>
          )}
        </div>

        {/* Preço Máximo */}
        <div className="space-y-2 w-full">
          <Label htmlFor="maxPrice">Preço Máximo (R$)</Label>
          <Controller
            name="maxPrice"
            control={control}
            render={({ field }) => (
              <Input
                id="maxPrice"
                type="number"
                step="0.01"
                min="0"
                placeholder="Sem máximo"
                {...field}
              />
            )}
          />
          {errors.maxPrice && (
            <p className="text-xs text-destructive">
              {errors.maxPrice.message}
            </p>
          )}
        </div>
      </div>

      {/* Botões de Ação */}
      <div className="flex gap-3">
        <Button type="submit" className="gap-2" disabled={isFetching}>
          {isFetching ? <Spinner /> : <Search className="h-4 w-4" />}
          Buscar
        </Button>
        <Button
          type="button"
          variant="outline"
          onClick={handleReset}
          className="gap-2"
        >
          <X className="h-4 w-4" />
          Limpar Filtros
        </Button>
      </div>
    </form>
  );
}
