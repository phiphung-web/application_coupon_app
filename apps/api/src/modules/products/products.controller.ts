import { Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post, Query } from '@nestjs/common';
import { ProductsService } from './products.service';
import { CreateProductDto, QueryProductsDto, UpdateProductDto } from './dto';

@Controller('products')
export class ProductsController {
  constructor(private readonly svc: ProductsService) {}

  @Post() create(@Body() dto: CreateProductDto) { return this.svc.create(dto); }
  @Patch(':id') update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateProductDto) { return this.svc.update(id, dto); }
  @Delete(':id') remove(@Param('id', ParseIntPipe) id: number) { return this.svc.remove(id); }

  @Get('hot') hot() { return this.svc.hot(); }
  @Get(':id') get(@Param('id', ParseIntPipe) id: number) { return this.svc.findById(id); }
  @Get() list(@Query() q: QueryProductsDto) { return this.svc.list(q); }
}
