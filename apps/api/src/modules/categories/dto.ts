import { Type } from "class-transformer";
import {
  IsBoolean,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from "class-validator";

export class CreateCategoryDto {
  @IsString() @MaxLength(120) @IsNotEmpty() name!: string;
  @IsOptional() @IsString() imageUrl?: string;
  @Type(() => Number) @IsInt() @IsOptional() priority?: number = 0;
  @IsOptional() @IsBoolean() isActive?: boolean = true;
}
export class UpdateCategoryDto extends CreateCategoryDto {}

export class QueryCategoriesDto {
  @Type(() => Number) @IsInt() @IsOptional() page: number = 1;
  @Type(() => Number) @IsInt() @IsOptional() pageSize: number = 50;
  @IsOptional() @IsString() q?: string;
}
