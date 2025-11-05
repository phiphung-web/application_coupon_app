import { IsBoolean, IsInt, IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateShopDto {
  @IsString() @MaxLength(50) @IsNotEmpty() id!: string;   // string id
  @IsString() @MaxLength(120) @IsNotEmpty() name!: string;
  @IsOptional() @IsString() logoUrl?: string;
  @IsOptional() @IsString() domain?: string;
  @Type(() => Number) @IsInt() @IsOptional() priority?: number = 0;
  @IsOptional() @IsBoolean() isActive?: boolean = true;
}
export class UpdateShopDto extends CreateShopDto {}
