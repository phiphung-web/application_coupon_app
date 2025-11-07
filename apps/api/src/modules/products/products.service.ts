import { BadRequestException, Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository, FindOptionsWhere } from "typeorm";
import { Product } from "../../entities/product.entity";
import { CreateProductDto, ListProductDto, UpdateProductDto } from "./dto";

@Injectable()
export class ProductsService {
  constructor(@InjectRepository(Product) private repo: Repository<Product>) {}

  async list(q: ListProductDto) {
    const {
      page = 1,
      pageSize = 20,
      q: keyword,
      categoryId,
      sourceId,
      isHot,
      sort,
    } = q;
    const where: FindOptionsWhere<Product> = {};
    if (categoryId) (where as any).categoryId = categoryId;
    if (sourceId) (where as any).sourceId = sourceId;
    if (isHot !== undefined) (where as any).isHot = isHot;
    if (keyword) (where as any).name = () => `ILIKE '%${keyword}%'`;

    const order: any = {};
    switch (sort) {
      case "priceAsc":
        order.basePrice = "ASC";
        break;
      case "priceDesc":
        order.basePrice = "DESC";
        break;
      case "discountDesc":
        order.discountPercent = "DESC";
        break;
      case "hot":
        order.isHot = "DESC";
        order.id = "DESC";
        break;
      case "new":
      default:
        order.id = "DESC";
    }

    const [items, total] = await this.repo.findAndCount({
      where,
      order,
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    return { items, total, page, pageSize };
  }

  get(id: number) {
    return this.repo.findOne({ where: { id } });
  }

  async create(dto: CreateProductDto) {
    if (dto.originalPrice && dto.originalPrice < dto.basePrice) {
      throw new BadRequestException("originalPrice must be >= basePrice");
    }
    if (
      !dto.discountPercent &&
      dto.originalPrice &&
      dto.originalPrice > dto.basePrice
    ) {
      dto.discountPercent = Math.round(
        100 - (dto.basePrice * 100) / dto.originalPrice
      );
    }
    return this.repo.save(this.repo.create(dto));
  }

  async update(id: number, dto: UpdateProductDto) {
    if (
      dto.originalPrice &&
      dto.basePrice &&
      dto.originalPrice < dto.basePrice
    ) {
      throw new BadRequestException("originalPrice must be >= basePrice");
    }
    if (
      !dto.discountPercent &&
      dto.originalPrice &&
      dto.basePrice &&
      dto.originalPrice > dto.basePrice
    ) {
      dto.discountPercent = Math.round(
        100 - (dto.basePrice * 100) / dto.originalPrice
      );
    }
    await this.repo.update({ id }, dto);
    return this.get(id);
  }

  async remove(id: number) {
    await this.repo.delete({ id });
    return { ok: true };
  }
}
