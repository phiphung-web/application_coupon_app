import { Expose } from "class-transformer";

// DTO này định nghĩa cấu trúc của một Badge
// Sẽ được tái sử dụng trong Product và Coupon
export class BadgeDto {
  @Expose()
  key: string;

  @Expose()
  label: string;

  @Expose()
  color?: string;

  @Expose()
  bgColor?: string;

  @Expose()
  icon?: string;

  // Không expose 'priority' trừ khi FE thực sự cần
}
