import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { Coupon } from "../entities/coupon.entity";
import { Shop } from "../entities/shop.entity";
import { Category } from "../entities/category.entity";
import { CouponsModule } from "./coupons/coupons.module";
import { ShopsModule } from "./shops/shops.module";
import { ReportsModule } from "./reports/reports.module";

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: "sqlite",
      database: "data.sqlite",
      synchronize: true, // DEV only
      entities: [Coupon, Shop, Category],
    }),
    CouponsModule,
    ShopsModule,
    ReportsModule,
  ],
})
export class AppModule {}
