import React, { useEffect, useState } from "react";
import { BasePropertyProps } from "adminjs";
import { Box, Label, Loader, MessageBox, Text } from "@adminjs/design-system";

type CouponDto = {
  id: number;
  code: string;
  description?: string;
  sourceName?: string;
  discountType?: string;
  discountValue?: number;
  endDate?: string;
};

export default function CouponLinkPreview(props: BasePropertyProps) {
  const couponId = props.record?.params?.linkCouponId;
  const [state, setState] = useState<
    { loading: boolean; error?: string; data?: CouponDto }
  >({ loading: false });

  useEffect(() => {
    if (!couponId) {
      setState({ loading: false, data: undefined });
      return;
    }
    let cancelled = false;
    setState({ loading: true });
    fetch(`/api/coupons/${couponId}`)
      .then(async (res) => {
        if (!res.ok) {
          throw new Error(`Không tải được mã #${couponId}`);
        }
        return (await res.json()) as CouponDto;
      })
      .then((data) => {
        if (!cancelled) setState({ loading: false, data });
      })
      .catch((err: Error) => {
        if (!cancelled) setState({ loading: false, error: err.message });
      });
    return () => {
      cancelled = true;
    };
  }, [couponId]);

  if (!couponId) {
    return (
      <MessageBox mt="lg" message="Chọn mã cần liên kết để xem chi tiết." />
    );
  }
  if (state.loading) {
    return (
      <Box mt="lg" display="flex" alignItems="center">
        <Loader />
        <Text ml="md">Đang tải thông tin mã #{couponId}</Text>
      </Box>
    );
  }
  if (state.error) {
    return (
      <MessageBox
        mt="lg"
        variant="danger"
        message={state.error ?? "Không tải được thông tin mã"}
      />
    );
  }
  if (!state.data) return null;

  const coupon = state.data;
  return (
    <Box
      variant="container"
      mt="lg"
      flex
      flexDirection="column"
      data-testid="coupon-link-preview"
    >
      <Label>Mã đang chọn</Label>
      <Text fontWeight="bold">
        #{coupon.id} · {coupon.code}
      </Text>
      {coupon.description && (
        <Text mt="sm" color="grey60">
          {coupon.description}
        </Text>
      )}
      <Box mt="sm">
        {coupon.sourceName && (
          <Text color="grey60">Nguồn: {coupon.sourceName}</Text>
        )}
        {coupon.discountType && (
          <Text color="grey60">
            Loại giảm: {coupon.discountType} · Giá trị: {coupon.discountValue}
          </Text>
        )}
      </Box>
    </Box>
  );
}

