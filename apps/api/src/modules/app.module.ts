import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { TypeOrmModule } from "@nestjs/typeorm";
import { typeormConfig } from "../config/typeorm.config";
import { CategoriesModule } from "../modules/categories/categories.module";
import { SourcesModule } from "../modules/sources/sources.module.ts";
import { ProductsModule } from "../modules/products/products.module";
import { CouponsModule } from "../modules/coupons/coupons.module";
import { PricingModule } from "../modules/pricing/pricing.module";

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({ useFactory: typeormConfig }),
    CategoriesModule,
    SourcesModule,
    ProductsModule,
    CouponsModule,
    PricingModule,
  ],
})
export class AppModule {}
