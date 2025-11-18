"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.typeormConfig = void 0;
const item_entity_1 = require("../entities/item.entity");
const coupon_entity_1 = require("../entities/coupon.entity");
const category_entity_1 = require("../entities/category.entity");
const coupon_category_entity_1 = require("../entities/coupon_category.entity");
const badge_entity_1 = require("../entities/badge.entity");
const source_entity_1 = require("../entities/source.entity");
const item_coupon_link_entity_1 = require("../entities/item_coupon_link.entity");
const user_entity_1 = require("../entities/user.entity");
const favorite_item_entity_1 = require("../entities/favorite_item.entity");
const favorite_coupon_entity_1 = require("../entities/favorite_coupon.entity");
const favorite_source_entity_1 = require("../entities/favorite_source.entity");
const item_category_entity_1 = require("../entities/item_category.entity");
exports.typeormConfig = {
    type: "postgres",
    url: process.env.DATABASE_URL,
    synchronize: false, // bật true khi dev lần đầu, sau đó false + migration
    logging: false,
    entities: [
        item_entity_1.Item,
        item_category_entity_1.ItemCategory,
        coupon_entity_1.Coupon,
        category_entity_1.Category,
        coupon_category_entity_1.CouponCategory,
        badge_entity_1.Badge,
        source_entity_1.Source,
        item_coupon_link_entity_1.ItemCouponLink,
        user_entity_1.User,
        favorite_item_entity_1.FavoriteItem,
        favorite_coupon_entity_1.FavoriteCoupon,
        favorite_source_entity_1.FavoriteSource,
    ],
    migrations: ["dist/migrations/*.js"],
};
