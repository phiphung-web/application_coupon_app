import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PricingService } from './pricing.service';
import { PricingController } from './pricing.controller';
import { Product } from '../../entities/product.entity';
import { Coupon } from '../../entities/coupon.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Product, Coupon])],
  providers: [PricingService],
  controllers: [PricingController],
  exports: [PricingService],
})
export class PricingModule {}
