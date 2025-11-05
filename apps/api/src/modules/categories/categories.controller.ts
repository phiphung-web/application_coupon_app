import { Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post, Query } from '@nestjs/common';
import { CategoriesService } from './categories.service';
import { CreateCategoryDto, QueryCategoriesDto, UpdateCategoryDto } from './dto';

@Controller('categories')
export class CategoriesController {
  constructor(private readonly svc: CategoriesService) {}

  @Post() create(@Body() dto: CreateCategoryDto) { return this.svc.create(dto); }
  @Patch(':id') update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateCategoryDto) { return this.svc.update(id, dto); }
  @Delete(':id') remove(@Param('id', ParseIntPipe) id: number) { return this.svc.remove(id); }

  @Get('top') top() { return this.svc.top(); }
  @Get(':id') get(@Param('id', ParseIntPipe) id: number) { return this.svc.getById(id); }
  @Get() list(@Query() q: QueryCategoriesDto) { return this.svc.list(q); }
}
