import { ResourceOptions } from 'adminjs';
import { Product } from '../entities/product.entity';
import { Coupon } from '../entities/coupon.entity';
import { Category } from '../entities/category.entity';
import { CouponCategory } from '../entities/coupon_category.entity';
import { Badge } from '../entities/badge.entity';
import { Source } from '../entities/source.entity';
import { ProductCoupon } from '../entities/product_coupon.entity';
import AdminJS from 'adminjs';

const cents = {
  type: 'number',
  components: {
    list: AdminJS.bundle('./components/cents.list.tsx'),
    show: AdminJS.bundle('./components/cents.show.tsx'),
    edit: AdminJS.bundle('./components/cents.edit.tsx'),
  },
};

export function buildAdminOptions(): any {
  const resources: { resource: any; options?: ResourceOptions }[] = [
    {
      resource: Product,
      options: {
        navigation: { name: 'Catalog', icon: 'Box' },
        properties: {
          priceOriginal: { ...cents, label: 'Price original (¢)' },
          priceCurrent:  { ...cents, label: 'Price current (¢)' },
          currency: { availableValues: [{ value: 'USD', label: 'USD' }] },
          createdAt: { isVisible: { list: true, filter: true, show: true, edit: false } },
          updatedAt: { isVisible: { list: true, filter: true, show: true, edit: false } },
        },
        listProperties: ['id', 'name', 'priceCurrent', 'priceOriginal', 'sourceId'],
        filterProperties: ['name', 'sourceId', 'categories', 'badges'],
        actions: {},
      },
    },
    {
      resource: Coupon,
      options: {
        navigation: { name: 'Deals', icon: 'Badge' },
        properties: {
          discountType: { availableValues: [
            { value: 'PERCENT', label: 'PERCENT' },
            { value: 'FIXED', label: 'FIXED' },
          ]},
          discountValue: { type: 'number' },
          minSpend: { ...cents, label: 'Min spend (¢)' },
          maxDiscount: { ...cents, label: 'Max discount (¢)' },
          endAt: { type: 'datetime' },
          imageUrl: { type: 'string' },
          isActive: { type: 'boolean' },
          createdAt: { isVisible: { list: true, filter: true, show: true, edit: false } },
          updatedAt: { isVisible: { list: true, filter: true, show: true, edit: false } },
        },
        listProperties: ['id', 'title', 'code', 'discountType', 'discountValue', 'endAt', 'isActive'],
        filterProperties: ['title', 'code', 'sourceId', 'categories', 'badges', 'isActive'],
      },
    },
    {
      resource: ProductCoupon,
      options: {
        navigation: { name: 'Relations', icon: 'Shuffle' },
        properties: {
          productId: { type: 'number' },
          couponId:  { type: 'string' },
          isPrimary: { type: 'boolean', label: 'Primary for product' },
          createdAt: { isVisible: { list: true, filter: true, show: true, edit: false } },
        },
        listProperties: ['productId', 'couponId', 'isPrimary', 'createdAt'],
      },
    },
    { resource: Category,       options: { navigation: { name: 'Catalog', icon: 'Tag' } } },
    { resource: CouponCategory, options: { navigation: { name: 'Deals',   icon: 'Tag' } } },
    { resource: Badge,          options: { navigation: { name: 'Settings',icon: 'Award' } } },
    { resource: Source,         options: { navigation: { name: 'Settings',icon: 'Cloud' } } },
  ];

  return {
    rootPath: '/admin',
    resources,
    branding: {
      companyName: 'Coupon App Admin',
      softwareBrothers: false,
    },
    locale: {
      language: 'vi',
      translations: {
        labels: { Product: 'Sản phẩm', Coupon: 'Mã giảm giá', Category: 'Danh mục SP',
                  CouponCategory: 'Danh mục mã', Badge: 'Huy hiệu', Source: 'Nguồn', ProductCoupon: 'Liên kết SP-Mã' },
      },
    },
  };
}
