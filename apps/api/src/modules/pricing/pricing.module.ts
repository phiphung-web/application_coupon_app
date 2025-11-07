import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { PricingService } from "./pricing.service";
import { PricingController } from "./pricing.controller";
import { Product } from "../../entities/product.entity";
import { ProductCoupon } from "../../entities/product_coupon.entity";
import { Coupon } from "../../entities/coupon.entity";

@Module({
  imports: [TypeOrmModule.forFeature([Product, ProductCoupon, Coupon])],
  providers: [PricingService],
  controllers: [PricingController],
  exports: [PricingService],
})
export class PricingModule {}
