// src/modules/coupons/coupons.service.ts
calcDiscount(price: number, c: Coupon) {
  const raw = c.type === 'PERCENT' ? Math.floor(price * c.value / 100) : c.value;
  const capped = c.maxDiscount ? Math.min(raw, c.maxDiscount) : raw;
  return Math.max(capped, 0);
}

async preview(dto: PreviewDto) {
  const c = await this.repo.findOne({
    where: { code: dto.couponCode },
    relations: ['shop', 'category', 'applicableCategories'],
  });
  if (!c) return { canApply: false, reason: 'Mã không tồn tại' };

  if (new Date(c.expiredAt) < new Date()) return { canApply: false, reason: 'Mã đã hết hạn' };
  if (c.minOrder && dto.price < c.minOrder) return { canApply: false, reason: 'Chưa đạt đơn tối thiểu' };
  if (dto.shopId && c.shop?.id && c.shop.id !== dto.shopId) return { canApply: false, reason: 'Sai shop' };

  // kiểm tra phạm vi áp dụng theo danh mục/loại
  const allowCat =
    !dto.categoryId ||
    c.category?.id === dto.categoryId ||
    (c.applicableCategories?.some((x) => x.id === dto.categoryId));

  const allowType =
    !dto.type ||
    (c.applicableTypes?.includes(dto.type) && !(c.excludedTypes?.includes(dto.type)));

  if (!allowCat || !allowType) return { canApply: false, reason: 'Không áp dụng cho sản phẩm này' };

  const discount = this.calcDiscount(dto.price, c);
  const finalPrice = Math.max(dto.price - discount, 0);

  return {
    canApply: true,
    discount,
    finalPrice,
    meta: {
      type: c.type, value: c.value, maxDiscount: c.maxDiscount, minOrder: c.minOrder,
      code: c.code, expiredAt: c.expiredAt,
      applicableTypes: c.applicableTypes ?? [],
    }
  };
}
