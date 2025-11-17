import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { ProductsController } from "./products.controller";
import { ProductsService } from "./products.service";
import { Item } from "../../entities/item.entity";
import { Coupon } from "../../entities/coupon.entity";
import { ItemCouponLink } from "../../entities/item_coupon_link.entity";
import { PricingModule } from "../pricing/pricing.module";

@Module({
  imports: [
    TypeOrmModule.forFeature([Item, Coupon, ItemCouponLink]),
    PricingModule,
  ],
  controllers: [ProductsController],
  providers: [ProductsService],
  exports: [ProductsService],
})
export class ProductsModule {}
