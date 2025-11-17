import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { PricingService } from "./pricing.service";
import { PricingController } from "./pricing.controller";
import { Item } from "../../entities/item.entity";
import { ItemCouponLink } from "../../entities/item_coupon_link.entity";
import { Coupon } from "../../entities/coupon.entity";

@Module({
  imports: [TypeOrmModule.forFeature([Item, ItemCouponLink, Coupon])],
  providers: [PricingService],
  controllers: [PricingController],
  exports: [PricingService],
})
export class PricingModule {}
