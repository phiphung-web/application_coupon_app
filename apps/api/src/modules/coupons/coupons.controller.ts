import { Controller, Get, Query } from "@nestjs/common";
import { CouponsService } from "./coupons.service";
import { CouponQuery } from "./dto";

@Controller("coupons")
export class CouponsController {
  constructor(private readonly service: CouponsService) {}
  @Get() list(@Query() query: CouponQuery) {
    return this.service.list(query);
  }
}
