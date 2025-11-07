import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { CouponCategory } from "../../entities/coupon_category.entity";
import { CouponCategoriesController } from "./coupon-categories.controller";
import { CouponCategoriesService } from "./coupon-categories.service";

@Module({
  imports: [TypeOrmModule.forFeature([CouponCategory])],
  controllers: [CouponCategoriesController],
  providers: [CouponCategoriesService],
  exports: [CouponCategoriesService],
})
export class CouponCategoriesModule {}
