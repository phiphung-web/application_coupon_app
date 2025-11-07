import { Controller, Get, Query, Param, Post, Body, Patch, Delete } from '@nestjs/common';
import { CategoriesService } from './categories.service';
import { CreateCategoryDto, ListCategoryDto, UpdateCategoryDto } from './dto';

@Controller('categories')
export class CategoriesController {
  constructor(private readonly svc: CategoriesService) {}

  @Get() list(@Query() q: ListCategoryDto) { return this.svc.list(q); }
  @Get(':id') get(@Param('id') id: number) { return this.svc.get(+id); }
  @Post() create(@Body() dto: CreateCategoryDto) { return this.svc.create(dto); }
  @Patch(':id') update(@Param('id') id: number, @Body() dto: UpdateCategoryDto) { return this.svc.update(+id, dto); }
  @Delete(':id') remove(@Param('id') id: number) { return this.svc.remove(+id); }
}
