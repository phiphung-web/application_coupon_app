import { IsInt, IsOptional, IsString, Min } from "class-validator";

export class PaginationDto {
  @IsInt() @Min(1) page = 1;
  @IsInt() @Min(1) limit = 20;

  @IsOptional() @IsString() q?: string;
  @IsOptional() @IsString() sort?: string;
  @IsOptional() @IsString() source?: string;
  @IsOptional() cat?: number;
  @IsOptional() badge?: string; // lọc theo badge key
}
