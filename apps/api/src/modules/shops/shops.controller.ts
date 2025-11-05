import { Body, Controller, Delete, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { ShopsService } from './shops.service';
import { CreateShopDto, UpdateShopDto } from './dto';

@Controller('shops')
export class ShopsController {
  constructor(private readonly svc: ShopsService) {}

  @Post() create(@Body() dto: CreateShopDto) { return this.svc.create(dto); }
  @Patch(':id') update(@Param('id') id: string, @Body() dto: UpdateShopDto) { return this.svc.update(id, dto); }
  @Delete(':id') remove(@Param('id') id: string) { return this.svc.remove(id); }

  @Get(':id') get(@Param('id') id: string) { return this.svc.getById(id); }
  @Get() list(@Query('q') q?: string) { return this.svc.list({ q }); }
}
