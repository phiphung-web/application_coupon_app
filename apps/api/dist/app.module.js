"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const typeorm_1 = require("@nestjs/typeorm");
const core_1 = require("@nestjs/core");
const common_2 = require("@nestjs/common");
const typeorm_config_1 = require("./config/typeorm.config");
// Admin CMS
const admin_module_1 = require("./admin/admin.module");
// Business modules
const products_module_1 = require("./modules/products/products.module");
const coupons_module_1 = require("./modules/coupons/coupons.module");
const categories_module_1 = require("./modules/categories/categories.module");
const coupon_categories_module_1 = require("./modules/coupon-categories/coupon-categories.module");
const badges_module_1 = require("./modules/badges/badges.module");
const sources_module_1 = require("./modules/sources/sources.module");
const pricing_module_1 = require("./modules/pricing/pricing.module");
const uploads_module_1 = require("./modules/uploads/uploads.module");
const notifications_module_1 = require("./modules/notifications/notifications.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            // .env loader (apps/api/.env ưu tiên)
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                expandVariables: true,
            }),
            // TypeORM dùng DATABASE_URL (postgres://user:pass@host:5432/db)
            typeorm_1.TypeOrmModule.forRootAsync({
                inject: [config_1.ConfigService],
                useFactory: (cfg) => {
                    const url = String(cfg.get("DATABASE_URL") ?? "");
                    if (!url)
                        throw new Error("Missing DATABASE_URL");
                    return {
                        type: "postgres",
                        url,
                        entities: typeorm_config_1.typeormConfig.entities,
                        autoLoadEntities: true,
                        synchronize: false,
                        logging: cfg.get("TYPEORM_LOGGING") === "true"
                            ? ["error", "query"]
                            : ["error"],
                        ssl: false,
                    };
                },
            }),
            // CMS giao diện quản trị
            admin_module_1.AdminCmsModule,
            // Modules nghiệp vụ
            products_module_1.ProductsModule,
            coupons_module_1.CouponsModule,
            categories_module_1.CategoriesModule,
            coupon_categories_module_1.CouponCategoriesModule,
            badges_module_1.BadgesModule,
            sources_module_1.SourcesModule,
            pricing_module_1.PricingModule,
            uploads_module_1.UploadsModule,
            notifications_module_1.NotificationsModule,
        ],
        providers: [
            // Validate DTO toàn cục
            {
                provide: core_1.APP_PIPE,
                useValue: new common_2.ValidationPipe({
                    whitelist: true,
                    forbidNonWhitelisted: true,
                    transform: true,
                }),
            },
        ],
    })
], AppModule);
