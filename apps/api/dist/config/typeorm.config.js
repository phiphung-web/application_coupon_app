"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.typeormConfig = void 0;
const product_entity_1 = require("../entities/product.entity");
const coupon_entity_1 = require("../entities/coupon.entity");
const category_entity_1 = require("../entities/category.entity");
const coupon_category_entity_1 = require("../entities/coupon_category.entity");
const badge_entity_1 = require("../entities/badge.entity");
const source_entity_1 = require("../entities/source.entity");
const product_coupon_entity_1 = require("../entities/product_coupon.entity");
exports.typeormConfig = {
    type: "postgres",
    url: process.env.DATABASE_URL,
    synchronize: false, // bật true khi dev lần đầu, sau đó false + migration
    logging: false,
    entities: [
        product_entity_1.Product,
        coupon_entity_1.Coupon,
        category_entity_1.Category,
        coupon_category_entity_1.CouponCategory,
        badge_entity_1.Badge,
        source_entity_1.Source,
        product_coupon_entity_1.ProductCoupon,
    ],
    migrations: ["dist/migrations/*.js"],
};
