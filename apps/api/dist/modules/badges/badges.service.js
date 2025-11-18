"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.BadgesService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const badge_entity_1 = require("../../entities/badge.entity");
let BadgesService = class BadgesService {
    constructor(repo) {
        this.repo = repo;
    }
    list() {
        return this.repo.find({ order: { id: "DESC" } });
    }
    get(id) {
        return this.repo.findOneByOrFail({ id });
    }
    async create(data) {
        return this.repo.save(this.repo.create(data));
    }
    async update(id, data) {
        const badge = await this.repo.findOneBy({ id });
        if (!badge)
            throw new common_1.NotFoundException();
        Object.assign(badge, data);
        return this.repo.save(badge);
    }
    async remove(id) {
        await this.repo.delete({ id });
        return { ok: true };
    }
};
exports.BadgesService = BadgesService;
exports.BadgesService = BadgesService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(badge_entity_1.Badge)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], BadgesService);
