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
exports.SourcesService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const source_entity_1 = require("../../entities/source.entity");
let SourcesService = class SourcesService {
    constructor(repo) {
        this.repo = repo;
    }
    async list() {
        return this.repo.find({ order: { priority: "DESC", name: "ASC" } });
    }
    async get(id) {
        const s = await this.repo.findOne({ where: { id } });
        if (!s)
            throw new common_1.NotFoundException("Source not found");
        return s;
    }
    async create(dto) {
        const exists = await this.repo.findOne({ where: { id: dto.id } });
        if (exists)
            throw new Error("Source ID already exists");
        const s = this.repo.create(dto);
        return this.repo.save(s);
    }
    async update(id, dto) {
        const s = await this.repo.findOne({ where: { id } });
        if (!s)
            throw new common_1.NotFoundException("Source not found");
        Object.assign(s, dto);
        return this.repo.save(s);
    }
    async remove(id) {
        const s = await this.repo.findOne({ where: { id } });
        if (!s)
            throw new common_1.NotFoundException("Source not found");
        await this.repo.softDelete({ id });
        return { ok: true };
    }
};
exports.SourcesService = SourcesService;
exports.SourcesService = SourcesService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(source_entity_1.Source)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], SourcesService);
