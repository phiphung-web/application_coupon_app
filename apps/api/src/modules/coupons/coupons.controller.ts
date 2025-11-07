import { Controller, Get, Query, Param, Post, Body, Patch, Delete } from '@nestjs/common';
import { CouponsService } from './coupons.service';
import { CreateCouponDto, ListCouponDto, UpdateCouponDto } from './dto';

@Controller('coupons')
export class CouponsController {
  constructor(private readonly svc: CouponsService) {}

  @Get() list(@Query() q: ListCouponDto) { return this.svc.list(q); }
  @Get('hot') hot(@Query('limit') limit = 10) { return this.svc.hot(+limit); }
  @Get(':id') get(@Param('id') id: string) { return this.svc.get(id); }
  @Post() create(@Body() dto: CreateCouponDto) { return this.svc.create(dto); }
  @Patch(':id') update(@Param('id') id: string, @Body() dto: UpdateCouponDto) { return this.svc.update(id, dto); }
  @Delete(':id') remove(@Param('id') id: string) { return this.svc.remove(id); }
}
