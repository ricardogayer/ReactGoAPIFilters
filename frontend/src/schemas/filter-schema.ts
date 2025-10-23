import { z } from "zod";

export const filterSchema = z
  .object({
    productName: z.string().optional(),
    category: z.string().optional(),
    minPrice: z.string().optional(),
    maxPrice: z.string().optional(),
  })
  .refine(
    (data) => {
      if (data.minPrice && data.maxPrice) {
        return Number(data.minPrice) <= Number(data.maxPrice);
      }
      return true;
    },
    {
      message: "O preço mínimo deve ser menor ou igual ao preço máximo",
      path: ["maxPrice"],
    }
  );

export type FilterSchema = z.infer<typeof filterSchema>;
