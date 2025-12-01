import { ResourceOptions } from "adminjs";
import { Item } from "../entities/item.entity";
import { Coupon } from "../entities/coupon.entity";
import { Category } from "../entities/category.entity";
import { CouponCategory } from "../entities/coupon_category.entity";
import { Badge } from "../entities/badge.entity";
import { Source } from "../entities/source.entity";
import { ItemCouponLink } from "../entities/item_coupon_link.entity";
import { User } from "../entities/user.entity";
import { DataSource } from "typeorm";

export function buildAdminOptions(ds: DataSource) {
  const resources: { resource: any; options?: ResourceOptions }[] = [
    {
      resource: Item,
      options: {
        navigation: { name: "Catalog", icon: "Box" },
        properties: {
          price: { type: "number" },
          itemType: {
            availableValues: [
              { value: "PRODUCT", label: "Product" },
              { value: "APP", label: "App" },
              { value: "GAME", label: "Game" },
              { value: "SERVICE", label: "Service" },
            ],
          },
          createdAt: {
            isVisible: { list: true, filter: true, show: true, edit: false },
          },
          updatedAt: {
            isVisible: { list: true, filter: true, show: true, edit: false },
          },
        },
        listProperties: [
          "id",
          "name",
          "itemType",
          "price",
          "sourceId",
          "categoryId",
        ],
      },
    },
    {
      resource: Coupon,
      options: {
        navigation: { name: "Deals", icon: "Badge" },
        properties: {
          discountType: {
            availableValues: [
              { value: "PERCENT", label: "Percent" },
              { value: "FIXED_AMOUNT", label: "Fixed amount" },
              { value: "FREESHIP", label: "Freeshop" },
              { value: "GIFT", label: "Gift" },
            ],
          },
          discountValue: { type: "number" },
          startDate: { type: "datetime" },
          endDate: { type: "datetime" },
        },
        listProperties: [
          "id",
          "code",
          "discountType",
          "discountValue",
          "startDate",
          "endDate",
        ],
      },
    },
    {
      resource: ItemCouponLink,
      options: {
        navigation: { name: "Relations", icon: "Shuffle" },
        listProperties: ["itemId", "couponId", "isPrimaryDisplay", "linkedAt"],
      },
    },
    {
      resource: Category,
      options: { navigation: { name: "Catalog", icon: "Tag" } },
    },
    {
      resource: CouponCategory,
      options: { navigation: { name: "Deals", icon: "Tag" } },
    },
    {
      resource: Badge,
      options: { navigation: { name: "Settings", icon: "Award" } },
    },
    {
      resource: Source,
      options: { navigation: { name: "Settings", icon: "Cloud" } },
    },
    {
      resource: User,
      options: { navigation: { name: "Settings", icon: "User" } },
    },
  ];

  return {
    rootPath: "/admin",
    resources,
    databases: [ds],
    branding: {
      companyName: "Coupon App Admin",
      softwareBrothers: false,
    },
    locale: { language: "vi" },
  };
}
