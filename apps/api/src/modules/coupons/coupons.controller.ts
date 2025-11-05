import { Body, Controller, Delete, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { CouponsService } from './coupons.service';
import { CreateCouponDto, QueryCouponsDto, UpdateCouponDto } from './dto';

@Controller('coupons')
export class CouponsController {
  constructor(private readonly svc: CouponsService) {}

  @Post() create(@Body() dto: CreateCouponDto) { return this.svc.create(dto); }
  @Patch(':id') update(@Param('id') id: string, @Body() dto: UpdateCouponDto) { return this.svc.update(id, dto); }
  @Delete(':id') remove(@Param('id') id: string) { return this.svc.remove(id); }

  @Get('hot') hot() { return this.svc.hot(); }
  @Get(':id') get(@Param('id') id: string) { return this.svc.getById(id); }
  @Get() list(@Query() q: QueryCouponsDto) { return this.svc.list(q); }
}
  