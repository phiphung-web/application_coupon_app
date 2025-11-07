import { IsInt, IsNotEmpty, IsOptional, IsString, MaxLength, Min, IsBoolean } from 'class-validator';
import { PaginationDto } from '../../common/dtos/pagination.dto';

export class CreateCategoryDto {
  @IsString() @IsNotEmpty() @MaxLength(120)
  name!: string;

  @IsOptional() @IsString()
  imageUrl?: string;

  @IsOptional() @IsInt() @Min(0)
  parentId?: number;

  @IsOptional() @IsInt() @Min(0)
  priority?: number;

  @IsOptional() @IsBoolean()
  isActive?: boolean;
}

export class UpdateCategoryDto {
  @IsOptional() @IsString() @MaxLength(120)
  name?: string;

  @IsOptional() @IsString()
  imageUrl?: string;

  @IsOptional() @IsInt() @Min(0)
  parentId?: number;

  @IsOptional() @IsInt() @Min(0)
  priority?: number;

  @IsOptional() @IsBoolean()
  isActive?: boolean;
}

export class CategoryQueryDto extends PaginationDto {
  @IsOptional() @IsInt()
  parentId?: number;

  @IsOptional() @IsBoolean()
  active?: boolean;
}
