import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Coupon } from '../../entities/coupon.entity';
import { Category } from '../../entities/category.entity';
import { Shop } from '../../entities/shop.entity';
import { CouponsController } from './coupons.controller';
import { CouponsService } from './coupons.service';

@Module({
  imports: [TypeOrmModule.forFeature([Coupon, Category, Shop])],
  controllers: [CouponsController],
  providers: [CouponsService],
})
export class CouponsModule {}
