// src/modules/coupons/dto.ts
export class PreviewDto {
  price: number;         // giá sp
  categoryId?: number;   // danh mục của sp
  type?: string;         // loại sp (nếu dùng)
  shopId?: number;       // shop của sp
  couponCode: string;
}
