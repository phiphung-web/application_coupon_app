import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { typeormConfig } from "../config/typeorm.config";
import { ProductsModule } from "./products/products.module";
import { CouponsModule } from "./coupons/coupons.module";
import { PricingModule } from "./pricing/pricing.module";
import { CategoriesModule } from "./categories/categories.module";
import { SourcesModule } from "./sources/sources.module.ts";
import { CouponCategoriesModule } from "./coupon-categories/coupon-categories.module";
import { BadgesModule } from "./badges/badges.module";

@Module({
  imports: [
    TypeOrmModule.forRootAsync({ useFactory: () => typeormConfig }),
    ProductsModule,
    CouponsModule,
    CategoriesModule,
    CouponCategoriesModule,
    BadgesModule,
    SourcesModule,
    PricingModule,
  ],
})
export class AppModule {}
