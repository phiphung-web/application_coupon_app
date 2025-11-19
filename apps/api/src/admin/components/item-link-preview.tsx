import React, { useEffect, useState } from "react";
import { BasePropertyProps } from "adminjs";
import { Box, Label, Loader, MessageBox, Text } from "@adminjs/design-system";

type ItemDto = {
  id: number;
  name: string;
  source?: { name?: string };
  sourceName?: string;
  price?: string;
  itemType?: string;
};

export default function ItemLinkPreview(props: BasePropertyProps) {
  const itemId = props.record?.params?.linkItemId;
  const [state, setState] = useState<
    { loading: boolean; error?: string; data?: ItemDto }
  >({ loading: false });

  useEffect(() => {
    if (!itemId) {
      setState({ loading: false, data: undefined });
      return;
    }
    let cancelled = false;
    setState({ loading: true });
    fetch(`/api/products/${itemId}`)
      .then(async (res) => {
        if (!res.ok) throw new Error(`Không tải được sản phẩm #${itemId}`);
        return (await res.json()) as ItemDto;
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
  }, [itemId]);

  if (!itemId) {
    return (
      <MessageBox mt="lg" message="Chọn item cần gán mã để xem chi tiết." />
    );
  }
  if (state.loading) {
    return (
      <Box mt="lg" display="flex" alignItems="center">
        <Loader />
        <Text ml="md">Đang tải item #{itemId}</Text>
      </Box>
    );
  }
  if (state.error) {
    return (
      <MessageBox
        mt="lg"
        variant="danger"
        message={state.error ?? "Không tải được thông tin item"}
      />
    );
  }
  if (!state.data) return null;
  const item = state.data;
  return (
    <Box variant="container" mt="lg">
      <Label>Sản phẩm đang chọn</Label>
      <Text fontWeight="bold">
        #{item.id} · {item.name}
      </Text>
      <Box mt="sm">
        {item.sourceName ?? item.source?.name ? (
          <Text color="grey60">
            Nguồn: {item.sourceName ?? item.source?.name}
          </Text>
        ) : null}
        {item.itemType && (
          <Text color="grey60">Loại: {item.itemType}</Text>
        )}
        {item.price && <Text color="grey60">Giá: {item.price}</Text>}
      </Box>
    </Box>
  );
}

