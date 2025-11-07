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
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_config_1 = require("../config/typeorm.config");
const products_module_1 = require("./products/products.module");
const coupons_module_1 = require("./coupons/coupons.module");
const pricing_module_1 = require("./pricing/pricing.module");
const categories_module_1 = require("./categories/categories.module");
const sources_module_ts_1 = require("./sources/sources.module.ts");
const coupon_categories_module_1 = require("./coupon-categories/coupon-categories.module");
const badges_module_1 = require("./badges/badges.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            typeorm_1.TypeOrmModule.forRootAsync({ useFactory: () => typeorm_config_1.typeormConfig }),
            products_module_1.ProductsModule,
            coupons_module_1.CouponsModule,
            categories_module_1.CategoriesModule,
            coupon_categories_module_1.CouponCategoriesModule,
            badges_module_1.BadgesModule,
            sources_module_ts_1.SourcesModule,
            pricing_module_1.PricingModule,
        ],
    })
], AppModule);
