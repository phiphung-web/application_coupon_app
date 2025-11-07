import { Expose } from "class-transformer";
import { SourceType } from "src/entities/source.entity"; // Import enum từ entity

// DTO này chỉ expose các trường FE cần
export class SourceResponseDto {
  @Expose()
  id: string;

  @Expose()
  name: string;

  @Expose()
  type: SourceType; // FE sẽ nhận 'ECOM', 'APP', v.v.

  @Expose()
  logoUrl?: string;
}
