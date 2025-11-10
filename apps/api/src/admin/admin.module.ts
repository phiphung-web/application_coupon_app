import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { AdminModule } from "@adminjs/nestjs";
import AdminJS from "adminjs";
import * as AdminJSTypeorm from "@adminjs/typeorm";

import { Product } from "../entities/product.entity";
import { Coupon } from "../entities/coupon.entity";
import { Category } from "../entities/category.entity";
import { CouponCategory } from "../entities/coupon_category.entity";
import { Badge } from "../entities/badge.entity";
import { Source } from "../entities/source.entity";
import { ProductCoupon } from "../entities/product_coupon.entity";
import { buildAdminOptions } from "./admin.options";
import { buildAuth } from "./admin.auth";

AdminJS.registerAdapter({
  Resource: AdminJSTypeorm.Resource,
  Database: AdminJSTypeorm.Database,
});

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Product,
      Coupon,
      Category,
      CouponCategory,
      Badge,
      Source,
      ProductCoupon,
    ]),
    AdminModule.createAdminAsync({
      useFactory: async () => ({
        adminJsOptions: buildAdminOptions(),
        auth: buildAuth(), // basic auth
        sessionOptions: {
          resave: false,
          saveUninitialized: true,
          secret: "change_me",
        },
        // mặc định mountPath '/admin'
      }),
    }),
  ],
})
export class AdminCmsModule {}
