"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
// src/seeds/seed.ts
require("dotenv/config");
const typeorm_config_1 = __importDefault(require("../typeorm.config"));
const fs_1 = require("fs");
const path_1 = require("path");
const source_entity_1 = require("../entities/source.entity");
const badge_entity_1 = require("../entities/badge.entity");
const category_entity_1 = require("../entities/category.entity");
const coupon_category_entity_1 = require("../entities/coupon_category.entity");
const coupon_entity_1 = require("../entities/coupon.entity");
const product_entity_1 = require("../entities/product.entity");
const product_coupon_entity_1 = require("../entities/product_coupon.entity");
function load(file) {
    const p = (0, path_1.join)(__dirname, file);
    return JSON.parse((0, fs_1.readFileSync)(p, "utf8"));
}
(async () => {
    var _a;
    const ds = await typeorm_config_1.default.initialize();
    await ds.initialize();
    const sourceRepo = ds.getRepository(source_entity_1.Source);
    const badgeRepo = ds.getRepository(badge_entity_1.Badge);
    const pCatRepo = ds.getRepository(category_entity_1.Category);
    const cCatRepo = ds.getRepository(coupon_category_entity_1.CouponCategory);
    const couponRepo = ds.getRepository(coupon_entity_1.Coupon);
    const prodRepo = ds.getRepository(product_entity_1.Product);
    const pcRepo = ds.getRepository(product_coupon_entity_1.ProductCoupon);
    // sources
    for (const s of load("./sources.json")) {
        await sourceRepo.save(sourceRepo.create(s));
    }
    // badges
    for (const b of load("./badges.json")) {
        await badgeRepo.save(badgeRepo.create(b));
    }
    // product categories
    for (const c of load("./product_categories.json")) {
        await pCatRepo.save(pCatRepo.create(c));
    }
    // coupon categories
    for (const c of load("./coupon_categories.json")) {
        await cCatRepo.save(cCatRepo.create(c));
    }
    // coupons
    for (const c of load("./coupons.json")) {
        await couponRepo.save(couponRepo.create(Object.assign(Object.assign({}, c), { endAt: c.endAt ? new Date(c.endAt) : null })));
    }
    // products + attach categories/badges by name/key
    const badges = await badgeRepo.find();
    const cats = await pCatRepo.find();
    for (const p of load("./products.json")) {
        const attachBadges = badges.filter((b) => { var _a; return ((_a = p.badgeKeys) !== null && _a !== void 0 ? _a : []).includes(b.key); });
        const attachCats = cats.filter((c) => { var _a; return ((_a = p.categoryNames) !== null && _a !== void 0 ? _a : []).includes(c.name); });
        const prod = prodRepo.create({
            name: p.name,
            imageUrl: p.imageUrl,
            priceOriginal: p.priceOriginal,
            priceCurrent: p.priceCurrent,
            currency: (_a = p.currency) !== null && _a !== void 0 ? _a : "USD",
            sourceId: p.sourceId,
            categories: attachCats,
            badges: attachBadges,
            description: p.description,
        });
        await prodRepo.save(prod);
    }
    // link product_coupons
    const allProducts = await prodRepo.find();
    for (const link of load("./product_coupons.json")) {
        const prod = allProducts.find((x) => x.name === link.productName);
        if (!prod)
            continue;
        await pcRepo.save(pcRepo.create({
            productId: prod.id,
            couponId: link.couponId,
            isPrimary: !!link.isPrimary,
        }));
    }
    console.log("Seed done");
    await ds.destroy();
})().catch((e) => {
    console.error(e);
    process.exit(1);
});
