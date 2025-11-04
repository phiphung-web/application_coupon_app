import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Shop } from "../../entities/shop.entity";

@Injectable()
export class ShopsService {
  constructor(@InjectRepository(Shop) private shops: Repository<Shop>) {}
  list() {
    return this.shops.find({ order: { name: "ASC" } });
  }
}
