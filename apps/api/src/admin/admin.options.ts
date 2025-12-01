import {
  ActionRequest,
  ActionResponse,
  ComponentLoader,
  Locale,
  ResourceWithOptions,
} from "adminjs";
import uploadFeature from "@adminjs/upload";
import { join } from "path";
import { existsSync, mkdirSync } from "fs";
import { DataSource } from "typeorm";
import { Item } from "../entities/item.entity";
import { Coupon } from "../entities/coupon.entity";
import { Category } from "../entities/category.entity";
import { CouponCategory } from "../entities/coupon_category.entity";
import { Badge } from "../entities/badge.entity";
import { Source } from "../entities/source.entity";
import { ItemCouponLink } from "../entities/item_coupon_link.entity";
import { User } from "../entities/user.entity";
import { Notification } from "../entities/notification.entity";

const UPLOADS_ROOT = join(process.cwd(), "apps", "api", "uploads");

function ensureDir(path: string) {
  if (!existsSync(path)) {
    mkdirSync(path, { recursive: true });
  }
}

function imageUploadFeature(folder: string, property = "imageUrl") {
  const bucket = join(UPLOADS_ROOT, folder);
  ensureDir(bucket);

  return uploadFeature({
    provider: {
      local: {
        bucket,
        opts: {},
      },
    },
    properties: {
      key: property,
      file: `${property}File`,
    },
    uploadPath: (_record, filename) =>
      `${folder}/${Date.now()}-${filename.replace(/\s+/g, "-")}`,
  });
}

export function buildAdminOptions(ds: DataSource) {
  const couponRepo = ds.getRepository(Coupon);
  const linkRepo = ds.getRepository(ItemCouponLink);
  const componentLoader = new ComponentLoader();
  const Components = {
    CouponLinkPreview: componentLoader.add(
      "CouponLinkPreview",
      "./components/coupon-link-preview"
    ),
    ItemLinkPreview: componentLoader.add(
      "ItemLinkPreview",
      "./components/item-link-preview"
    ),
  };

  const handleItemExtras = (actionName: string) => ({
    before: async (request: ActionRequest, context: any) => {
      if (request.payload) {
        const extras = {
          linkCouponId: request.payload.linkCouponId,
          newCouponCode: request.payload.newCouponCode,
          newCouponDescription: request.payload.newCouponDescription,
          newCouponDiscountType: request.payload.newCouponDiscountType,
          newCouponDiscountValue: request.payload.newCouponDiscountValue,
        };
        context.itemActionExtras = extras;
        Object.keys(extras).forEach((key) => {
          if (request.payload && key in request.payload) {
            delete request.payload[key];
          }
        });
      }
      return request;
    },
    after: async (
      response: ActionResponse,
      request: ActionRequest,
      context: any
    ) => {
      const extras = context.itemActionExtras || {};
      const recordId =
        context.record?.params?.id || response.record?.id || response.record?.params?.id;
      if (!recordId) return response;
      const itemId = Number(recordId);
      if (extras.linkCouponId) {
        const couponId = Number(extras.linkCouponId);
        if (!Number.isNaN(couponId)) {
          await linkRepo.delete({ itemId });
          await linkRepo.save(
            linkRepo.create({
              itemId,
              couponId,
              isPrimaryDisplay: true,
            })
          );
        }
      }
      if (extras.newCouponCode) {
        const discountValue = Number(extras.newCouponDiscountValue);
        const coupon = couponRepo.create({
          code: extras.newCouponCode,
          description: extras.newCouponDescription,
          discountType: extras.newCouponDiscountType || undefined,
          discountValue: Number.isNaN(discountValue)
            ? undefined
            : String(discountValue),
        });
        const saved = await couponRepo.save(coupon);
        await linkRepo.save(
          linkRepo.create({
            itemId,
            couponId: saved.id,
            isPrimaryDisplay: true,
          })
        );
      }
      return response;
    },
  });

  const handleCouponExtras = () => ({
    before: async (request: ActionRequest, context: any) => {
      if (request.payload) {
        const extras = {
          linkItemId: request.payload.linkItemId,
        };
        context.couponActionExtras = extras;
        if (request.payload) {
          delete request.payload.linkItemId;
        }
      }
      return request;
    },
    after: async (
      response: ActionResponse,
      request: ActionRequest,
      context: any
    ) => {
      const extras = context.couponActionExtras || {};
      const recordId =
        context.record?.params?.id || response.record?.id || response.record?.params?.id;
      if (!recordId) return response;
      const couponId = Number(recordId);
      if (extras.linkItemId) {
        const itemId = Number(extras.linkItemId);
        if (!Number.isNaN(itemId)) {
          await linkRepo.delete({ itemId });
          await linkRepo.save(
            linkRepo.create({
              itemId,
              couponId,
              isPrimaryDisplay: true,
            })
          );
        }
      }
      return response;
    },
  });

  const resources: ResourceWithOptions[] = [
    {
      resource: Item,
      options: {
        navigation: { name: "Catalog", icon: "Box" },
        properties: {
          imageUrl: {
            isVisible: { list: true, show: true, edit: false },
          },
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
          linkCouponId: {
            type: "reference",
            reference: "Coupon",
            isVisible: { list: false, filter: false, show: false, edit: true },
            position: 120,
          },
          linkCouponPreview: {
            isVisible: { list: false, filter: false, show: false, edit: true },
            components: {
              edit: Components.CouponLinkPreview,
            },
            isDisabled: true,
            position: 121,
          },
          newCouponCode: {
            type: "string",
            isVisible: { list: false, filter: false, show: false, edit: true },
            position: 130,
          },
          newCouponDescription: {
            type: "textarea",
            isVisible: { list: false, filter: false, show: false, edit: true },
            position: 131,
          },
          newCouponDiscountType: {
            type: "string",
            availableValues: [
              { value: "PERCENT", label: "Percent" },
              { value: "FIXED_AMOUNT", label: "Fixed amount" },
              { value: "FREESHIP", label: "Freeship" },
              { value: "GIFT", label: "Gift" },
            ],
            isVisible: { list: false, filter: false, show: false, edit: true },
            position: 132,
          },
          newCouponDiscountValue: {
            type: "number",
            isVisible: { list: false, filter: false, show: false, edit: true },
            position: 133,
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
        actions: {
          new: handleItemExtras("new"),
          edit: handleItemExtras("edit"),
        },
      },
      features: [imageUploadFeature("items")],
    },
    {
      resource: Coupon,
      options: {
        navigation: { name: "Deals", icon: "Badge" },
        properties: {
          imageUrl: {
            isVisible: { list: true, show: true, edit: false },
          },
          discountType: {
            availableValues: [
              { value: "PERCENT", label: "Percent" },
              { value: "FIXED_AMOUNT", label: "Fixed amount" },
              { value: "FREESHIP", label: "Freeship" },
              { value: "GIFT", label: "Gift" },
            ],
          },
          discountValue: { type: "number" },
          startDate: { type: "datetime" },
          endDate: { type: "datetime" },
          linkItemId: {
            type: "reference",
            reference: "Item",
            isVisible: { list: false, filter: false, show: false, edit: true },
            position: 110,
          },
          linkItemPreview: {
            isVisible: { list: false, filter: false, show: false, edit: true },
            components: {
              edit: Components.ItemLinkPreview,
            },
            isDisabled: true,
            position: 111,
          },
        },
        listProperties: [
          "id",
          "code",
          "discountType",
          "discountValue",
          "startDate",
          "endDate",
        ],
        actions: {
          new: handleCouponExtras(),
          edit: handleCouponExtras(),
        },
      },
      features: [imageUploadFeature("coupons")],
    },
    {
      resource: Notification,
      options: {
        navigation: { name: "Engagement", icon: "Notification" },
        listProperties: ["id", "title", "category", "importance", "createdAt"],
        properties: {
          message: { type: "textarea" },
          payload: { type: "mixed" },
          tags: { type: "mixed" },
        },
      },
    },
    {
      resource: Source,
      options: {
        navigation: { name: "Settings", icon: "Cloud" },
        properties: {
          imageUrl: {
            isVisible: { list: true, show: true, edit: false },
          },
        },
      },
      features: [imageUploadFeature("sources")],
    },
    {
      resource: Badge,
      options: {
        navigation: { name: "Settings", icon: "Award" },
        properties: {
          iconUrl: {
            isVisible: { list: true, show: true, edit: false },
          },
        },
      },
      features: [imageUploadFeature("badges", "iconUrl")],
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
      resource: User,
      options: { navigation: { name: "Settings", icon: "User" } },
    },
  ];

  return {
    rootPath: "/admin",
    databases: [ds],
    resources,
    componentLoader,
    branding: {
      companyName: "Coupon App Admin",
      softwareBrothers: false,
    },
    locale: {
      language: "vi",
      translations: {},
    } as Locale,
  };
}
