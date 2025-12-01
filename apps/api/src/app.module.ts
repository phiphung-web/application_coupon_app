import { Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { TypeOrmModule } from "@nestjs/typeorm";
import { APP_PIPE } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import { typeormConfig } from "./config/typeorm.config";

// Admin CMS
import { AdminCmsModule } from "./admin/admin.module";

// Business modules
import { ProductsModule } from "./modules/products/products.module";
import { CouponsModule } from "./modules/coupons/coupons.module";
import { CategoriesModule } from "./modules/categories/categories.module";
import { CouponCategoriesModule } from "./modules/coupon-categories/coupon-categories.module";
import { BadgesModule } from "./modules/badges/badges.module";
import { SourcesModule } from "./modules/sources/sources.module";
import { PricingModule } from "./modules/pricing/pricing.module";
import { UploadsModule } from "./modules/uploads/uploads.module";
import { NotificationsModule } from "./modules/notifications/notifications.module";

@Module({
  imports: [
    // .env loader (apps/api/.env ưu tiên)
    ConfigModule.forRoot({
      isGlobal: true,
      expandVariables: true,
    }),

    // TypeORM dùng DATABASE_URL (postgres://user:pass@host:5432/db)
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => {
        const url = String(cfg.get("DATABASE_URL") ?? "");
        if (!url) throw new Error("Missing DATABASE_URL");
        return {
          type: "postgres",
          url,
          entities: typeormConfig.entities,
          autoLoadEntities: true,
          synchronize: false,
          logging:
            cfg.get("TYPEORM_LOGGING") === "true"
              ? ["error", "query"]
              : ["error"],
          ssl: false,
        };
      },
    }),

    // CMS giao diện quản trị
    AdminCmsModule,

    // Modules nghiệp vụ
    ProductsModule,
    CouponsModule,
    CategoriesModule,
    CouponCategoriesModule,
    BadgesModule,
    SourcesModule,
    PricingModule,
    UploadsModule,
    NotificationsModule,
  ],
  providers: [
    // Validate DTO toàn cục
    {
      provide: APP_PIPE,
      useValue: new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    },
  ],
})
export class AppModule {}
