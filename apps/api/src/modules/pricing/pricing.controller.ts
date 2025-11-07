import { Controller, Get, Param, ParseIntPipe } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Product } from "../../entities/product.entity";
import { ProductCoupon } from "../../entities/product_coupon.entity";
import { Coupon } from "../../entities/coupon.entity";
import { PricingService } from "./pricing.service";

@Controller("pricing")
export class PricingController {
  constructor(
    @InjectRepository(Product) private readonly prodRepo: Repository<Product>,
    @InjectRepository(ProductCoupon)
    private readonly pcRepo: Repository<ProductCoupon>,
    @InjectRepository(Coupon) private readonly couponRepo: Repository<Coupon>,
    private readonly pricing: PricingService
  ) {}

  @Get("best-deal/:productId")
  async bestDeal(@Param("productId", ParseIntPipe) productId: number) {
    const p = await this.prodRepo.findOne({ where: { id: productId } });
    if (!p) return { bestDeal: null };

    const pcs = await this.pcRepo.find({ where: { productId } });
    const ids = pcs.map((x) => x.couponId);
    if (!ids.length) return { bestDeal: null };

    const coupons = await this.couponRepo.findByIds(ids);
    const deal = this.pricing.bestDealForProduct(p, coupons);
    return { bestDeal: deal };
  }
}
