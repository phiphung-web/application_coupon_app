import { Controller, Get, Param, Query } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PricingService } from './pricing.service';
import { Product } from '../../entities/product.entity';
import { Coupon } from '../../entities/coupon.entity';

@Controller('pricing')
export class PricingController {
  constructor(
    private readonly pricing: PricingService,
    @InjectRepository(Product) private products: Repository<Product>,
    @InjectRepository(Coupon) private coupons: Repository<Coupon>,
  ) {}

  @Get('product/:id')
  async best(@Param('id') id: number, @Query('limit') limit = 200) {
    const p = await this.products.findOne({ where: { id: +id } });
    if (!p) return { error: 'Product not found' };
    const cs = await this.coupons.find({ where: { isActive: true }, take: +limit });
    return this.pricing.bestForProduct(p, cs);
  }
}
