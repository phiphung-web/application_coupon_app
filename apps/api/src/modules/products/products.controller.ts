import {
  Controller,
  Get,
  Query,
  Param,
  Post,
  Body,
  Patch,
  Delete,
} from "@nestjs/common";
import { ProductsService } from "./products.service";
import { CreateProductDto, ListProductDto, UpdateProductDto } from "./dto";

@Controller("products")
export class ProductsController {
  constructor(private readonly svc: ProductsService) {}

  @Get() list(@Query() q: ListProductDto) {
    return this.svc.list(q);
  }
  @Get("hot") hot(@Query("limit") limit = 8) {
    return this.svc.list({ page: 1, pageSize: +limit, sort: "discountDesc" });
  }
  @Get(":id") get(@Param("id") id: number) {
    return this.svc.get(+id);
  }
  @Post() create(@Body() dto: CreateProductDto) {
    return this.svc.create(dto);
  }
  @Patch(":id") update(@Param("id") id: number, @Body() dto: UpdateProductDto) {
    return this.svc.update(+id, dto);
  }
  @Delete(":id") remove(@Param("id") id: number) {
    return this.svc.remove(+id);
  }
}
