import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
} from "@nestjs/common";
import { CouponsService } from "./coupons.service";
import { UpsertCouponDto, CouponQueryDto } from "./dto";

@Controller("coupons")
export class CouponsController {
  constructor(private readonly svc: CouponsService) {}

  @Get()
  list(@Query() q: CouponQueryDto, @Query("active") active?: string) {
    return this.svc.paginate({ ...q, active });
  }

  @Get(":id")
  get(@Param("id", ParseIntPipe) id: number) {
    return this.svc.get(id);
  }

  @Post()
  upsert(@Body() dto: UpsertCouponDto) {
    return this.svc.upsert(dto);
  }

  @Patch(":id/deactivate")
  deactivate(@Param("id", ParseIntPipe) id: number) {
    return this.svc.deactivate(id);
  }
}
