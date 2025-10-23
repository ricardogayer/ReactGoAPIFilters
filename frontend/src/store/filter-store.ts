import { create } from "zustand";
import { type FilterSchema } from "@/schemas/filter-schema";

export interface PaginationState {
  pageIndex: number;
  pageSize: number;
}

interface FilterStore {
  filters: FilterSchema;
  isFetching: boolean;
  pagination: PaginationState;
  setFilters: (filters: FilterSchema) => void;
  setPagination: (pagination: PaginationState) => void;
  resetFilters: () => void;
  setFetching: (isFetching: boolean) => void;
}

const initialFilters: FilterSchema = {
  productName: "",
  category: "",
  minPrice: "",
  maxPrice: "",
};

const initialPagination: PaginationState = {
  pageIndex: 0,
  pageSize: 10,
};

export const useFilterStore = create<FilterStore>((set) => ({
  filters: initialFilters,
  pagination: initialPagination,
  isFetching: false,
  setFilters: (filters) =>
    set({
      filters,
      // Reset para primeira página quando filtros mudam
      pagination: { ...initialPagination },
    }),

  setFetching: (isFetching) => set({ isFetching }),

  setPagination: (pagination) => set({ pagination }),

  resetFilters: () =>
    set({
      filters: initialFilters,
      pagination: initialPagination,
    }),
}));
