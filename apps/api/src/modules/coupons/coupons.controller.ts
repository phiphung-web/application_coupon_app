import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from "@nestjs/common";
import { CouponsService } from "./coupons.service";
import { PaginationDto } from "../../common/dtos/pagination.dto";
import { UpsertCouponDto } from "./dto";

@Controller("coupons")
export class CouponsController {
  constructor(private readonly svc: CouponsService) {}

  @Get()
  list(@Query() q: PaginationDto, @Query("active") active?: string) {
    return this.svc.paginate({ ...q, active });
  }

  @Get(":id")
  get(@Param("id") id: string) {
    return this.svc.get(id);
  }

  @Post()
  upsert(@Body() dto: UpsertCouponDto) {
    return this.svc.upsert(dto);
  }

  @Patch(":id/deactivate")
  deactivate(@Param("id") id: string) {
    return this.svc.deactivate(id);
  }
}
