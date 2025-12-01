import {
  Controller,
  Get,
  Query,
  Param,
  DefaultValuePipe,
  ParseIntPipe,
  Post,
  Body,
  Patch,
  Delete,
} from "@nestjs/common";
import { ProductsService } from "./products.service";
import { CreateProductDto, LinkCouponDto, ProductQueryDto, UpdateProductDto } from "./dto";

@Controller("products")
export class ProductsController {
  constructor(private readonly svc: ProductsService) {}

  @Get()
  list(@Query() q: ProductQueryDto, @Query("withDeal") withDeal?: string) {
    return this.svc.paginate({ ...q, withDeal: withDeal === "true" });
  }

  @Get(":id")
  get(
    @Param("id", ParseIntPipe) id: number,
    @Query("withDeal") withDeal?: string
  ) {
    return this.svc.findOne(id, withDeal !== "false");
  }

  @Post()
  create(@Body() dto: CreateProductDto) {
    return this.svc.create(dto);
  }

  @Patch(":id")
  update(@Param("id", ParseIntPipe) id: number, @Body() dto: UpdateProductDto) {
    return this.svc.update(id, dto);
  }

  @Post(":id/coupons/link")
  link(@Param("id", ParseIntPipe) id: number, @Body() dto: LinkCouponDto) {
    return this.svc.linkCoupon(id, dto);
  }

  @Delete(":id/coupons/:couponId")
  unlink(
    @Param("id", ParseIntPipe) id: number,
    @Param("couponId", ParseIntPipe) couponId: number
  ) {
    return this.svc.unlinkCoupon(id, couponId);
  }
}
