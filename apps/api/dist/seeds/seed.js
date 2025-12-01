"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const fs_1 = require("fs");
const path_1 = require("path");
const typeorm_config_1 = __importDefault(require("../typeorm.config"));
const source_entity_1 = require("../entities/source.entity");
const badge_entity_1 = require("../entities/badge.entity");
const item_category_entity_1 = require("../entities/item_category.entity");
const coupon_category_entity_1 = require("../entities/coupon_category.entity");
const item_entity_1 = require("../entities/item.entity");
const coupon_entity_1 = require("../entities/coupon.entity");
const item_coupon_link_entity_1 = require("../entities/item_coupon_link.entity");
const user_entity_1 = require("../entities/user.entity");
const favorite_item_entity_1 = require("../entities/favorite_item.entity");
const favorite_coupon_entity_1 = require("../entities/favorite_coupon.entity");
const favorite_source_entity_1 = require("../entities/favorite_source.entity");
const notification_entity_1 = require("../entities/notification.entity");
function load(file) {
    const p = (0, path_1.join)(__dirname, file);
    return JSON.parse((0, fs_1.readFileSync)(p, "utf8"));
}
(async () => {
    if (!typeorm_config_1.default.isInitialized) {
        await typeorm_config_1.default.initialize();
    }
    const ds = typeorm_config_1.default;
    const sourceRepo = ds.getRepository(source_entity_1.Source);
    const badgeRepo = ds.getRepository(badge_entity_1.Badge);
    const itemCategoryRepo = ds.getRepository(item_category_entity_1.ItemCategory);
    const couponCategoryRepo = ds.getRepository(coupon_category_entity_1.CouponCategory);
    const itemRepo = ds.getRepository(item_entity_1.Item);
    const couponRepo = ds.getRepository(coupon_entity_1.Coupon);
    const linkRepo = ds.getRepository(item_coupon_link_entity_1.ItemCouponLink);
    const userRepo = ds.getRepository(user_entity_1.User);
    const favItemRepo = ds.getRepository(favorite_item_entity_1.FavoriteItem);
    const favCouponRepo = ds.getRepository(favorite_coupon_entity_1.FavoriteCoupon);
    const favSourceRepo = ds.getRepository(favorite_source_entity_1.FavoriteSource);
    const notificationRepo = ds.getRepository(notification_entity_1.Notification);
    console.log("🔄 Seeding data...");
    await ds.query(`
    TRUNCATE TABLE
      item_coupon_links,
      favorite_items,
      favorite_coupons,
      favorite_sources,
      items,
      coupons,
      item_categories,
      coupon_categories,
      badges,
      sources,
      users,
      notifications
    RESTART IDENTITY CASCADE
  `);
    const sourceMap = new Map();
    for (const s of load("./sources.json")) {
        const entity = sourceRepo.create(s);
        const saved = await sourceRepo.save(entity);
        sourceMap.set(s.name, saved);
    }
    const badgeMap = new Map();
    for (const b of load("./badges.json")) {
        const entity = badgeRepo.create(b);
        const saved = await badgeRepo.save(entity);
        if (b.slug)
            badgeMap.set(b.slug, saved);
        badgeMap.set(b.name, saved);
    }
    const itemCategoryMap = new Map();
    for (const c of load("./item_categories.json")) {
        const entity = itemCategoryRepo.create(c);
        const saved = await itemCategoryRepo.save(entity);
        itemCategoryMap.set(c.name, saved);
    }
    const couponCategoryMap = new Map();
    for (const c of load("./coupon_categories.json")) {
        const entity = couponCategoryRepo.create(c);
        const saved = await couponCategoryRepo.save(entity);
        couponCategoryMap.set(c.name, saved);
    }
    const itemMap = new Map();
    for (const item of load("./items.json")) {
        const entity = itemRepo.create({
            name: item.name,
            description: item.description,
            imageUrl: item.imageUrl,
            itemType: item.itemType,
            itemUrl: item.itemUrl,
            price: item.price != null ? String(item.price) : undefined,
            sourceId: sourceMap.get(item.source)?.id,
            categoryId: itemCategoryMap.get(item.category)?.id,
            badgeId: item.badge ? badgeMap.get(item.badge)?.id : undefined,
        });
        const saved = await itemRepo.save(entity);
        itemMap.set(item.name, saved);
    }
    const couponMap = new Map();
    for (const c of load("./coupons.json")) {
        const entity = couponRepo.create({
            code: c.code,
            description: c.description,
            imageUrl: c.imageUrl,
            discountType: c.discountType,
            discountValue: c.discountValue != null ? String(c.discountValue) : undefined,
            dealUrl: c.dealUrl,
            sourceId: sourceMap.get(c.source)?.id,
            categoryId: couponCategoryMap.get(c.category)?.id,
            badgeId: c.badge ? badgeMap.get(c.badge)?.id : undefined,
            startDate: c.startDate ? new Date(c.startDate) : undefined,
            endDate: c.endDate ? new Date(c.endDate) : undefined,
        });
        const saved = await couponRepo.save(entity);
        couponMap.set(c.code, saved);
    }
    for (const link of load("./item_coupon_links.json")) {
        const item = itemMap.get(link.item);
        const coupon = couponMap.get(link.coupon);
        if (!item || !coupon)
            continue;
        await linkRepo.save(linkRepo.create({
            itemId: item.id,
            couponId: coupon.id,
            isPrimaryDisplay: !!link.isPrimaryDisplay,
        }));
    }
    const userMap = new Map();
    for (const u of load("./users.json")) {
        const entity = await userRepo.save(userRepo.create({
            username: u.username,
            imageUrl: u.imageUrl,
            email: u.email,
            passwordHash: u.password,
            role: u.role,
        }));
        userMap.set(u.email, entity);
    }
    for (const fav of load("./favorite_items.json")) {
        const user = userMap.get(fav.userEmail);
        const item = itemMap.get(fav.item);
        if (!user || !item)
            continue;
        await favItemRepo.save(favItemRepo.create({ userId: user.id, itemId: item.id }));
    }
    for (const fav of load("./favorite_coupons.json")) {
        const user = userMap.get(fav.userEmail);
        const coupon = couponMap.get(fav.coupon);
        if (!user || !coupon)
            continue;
        await favCouponRepo.save(favCouponRepo.create({ userId: user.id, couponId: coupon.id }));
    }
    for (const fav of load("./favorite_sources.json")) {
        const user = userMap.get(fav.userEmail);
        const source = sourceMap.get(fav.source);
        if (!user || !source)
            continue;
        await favSourceRepo.save(favSourceRepo.create({ userId: user.id, sourceId: source.id }));
    }
    for (const raw of load("./notifications.json")) {
        await notificationRepo.save(notificationRepo.create({
            title: raw.title,
            message: raw.message,
            category: raw.category ?? notification_entity_1.NotificationCategory.SYSTEM,
            importance: raw.importance ?? 0,
            tags: raw.tags,
            sourceId: raw.source ? sourceMap.get(raw.source)?.id : undefined,
            itemId: raw.item ? itemMap.get(raw.item)?.id : undefined,
            couponId: raw.coupon ? couponMap.get(raw.coupon)?.id : undefined,
        }));
    }
    console.log("✅ Seed done");
    if (ds.isInitialized) {
        await ds.destroy();
    }
})().catch((e) => {
    console.error("❌ Seed failed:", e);
    process.exit(1);
});
