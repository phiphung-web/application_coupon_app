// src/modules/coupons/coupons.controller.ts
@Post('preview')
preview(@Body() dto: PreviewDto) {
  return this.svc.preview(dto);
}
