export type SortKey = "endAtAsc" | "endAtDesc" | "createdDesc";
export interface CouponQuery {
  page?: number;
  limit?: number;
  q?: string;
  shopId?: number;
  categoryKey?: string;
  sort?: SortKey;
}
