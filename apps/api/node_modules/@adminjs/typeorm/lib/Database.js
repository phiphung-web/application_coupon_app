"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Database = void 0;
const adminjs_1 = require("adminjs");
const Resource_1 = require("./Resource");
class Database extends adminjs_1.BaseDatabase {
    constructor(dataSource) {
        super(dataSource);
        this.dataSource = dataSource;
    }
    resources() {
        const resources = [];
        // eslint-disable-next-line no-restricted-syntax
        for (const entityMetadata of this.dataSource.entityMetadatas) {
            resources.push(new Resource_1.Resource(entityMetadata.target));
        }
        return resources;
    }
    static isAdapterFor(dataSource) {
        return !!dataSource.entityMetadatas;
    }
}
exports.Database = Database;
//# sourceMappingURL=Database.js.map