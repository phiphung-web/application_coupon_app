import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { CouponsController } from "./coupons.controller";
import { CouponsService } from "./coupons.service";
import { Coupon } from "../../entities/coupon.entity";
import { Badge } from "../../entities/badge.entity";
import { CouponCategory } from "../../entities/coupon_category.entity";

@Module({
  imports: [TypeOrmModule.forFeature([Coupon, Badge, CouponCategory])],
  controllers: [CouponsController],
  providers: [CouponsService],
  exports: [CouponsService],
})
export class CouponsModule {}
