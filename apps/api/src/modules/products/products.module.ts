import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { ProductsController } from "./products.controller";
import { ProductsService } from "./products.service";
import { Product } from "../../entities/product.entity";
import { Category } from "../../entities/category.entity";
import { Badge } from "../../entities/badge.entity";
import { Coupon } from "../../entities/coupon.entity";
import { ProductCoupon } from "../../entities/product_coupon.entity";
import { PricingModule } from "../pricing/pricing.module";

@Module({
  imports: [
    TypeOrmModule.forFeature([Product, Category, Badge, Coupon, ProductCoupon]),
    PricingModule,
  ],
  controllers: [ProductsController],
  providers: [ProductsService],
  exports: [ProductsService],
})
export class ProductsModule {}
