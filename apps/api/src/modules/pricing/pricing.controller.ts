import { Controller, Get, Param, ParseIntPipe } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Item } from "../../entities/item.entity";
import { ItemCouponLink } from "../../entities/item_coupon_link.entity";
import { Coupon } from "../../entities/coupon.entity";
import { PricingService } from "./pricing.service";

@Controller("pricing")
export class PricingController {
  constructor(
    @InjectRepository(Item) private readonly itemRepo: Repository<Item>,
    @InjectRepository(ItemCouponLink)
    private readonly linkRepo: Repository<ItemCouponLink>,
    @InjectRepository(Coupon) private readonly couponRepo: Repository<Coupon>,
    private readonly pricing: PricingService
  ) {}

  @Get("best-deal/:itemId")
  async bestDeal(@Param("itemId", ParseIntPipe) itemId: number) {
    const item = await this.itemRepo.findOne({ where: { id: itemId } });
    if (!item) return { bestDeal: null };

    const links = await this.linkRepo.find({ where: { itemId } });
    if (!links.length) return { bestDeal: null };

    const coupons = await this.couponRepo.findByIds(
      links.map((link) => link.couponId)
    );
    const deal = this.pricing.bestDealForProduct(item, coupons);
    return { bestDeal: deal };
  }
}
