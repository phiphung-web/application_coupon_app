"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.HomeExperience1721800000000 = void 0;
class HomeExperience1721800000000 {
    constructor() {
        this.name = "HomeExperience1721800000000";
    }
    async up(queryRunner) {
        await queryRunner.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'source_type') THEN
          CREATE TYPE source_type AS ENUM ('ECOM','FOOD','TRAVEL','APP');
        END IF;
      END$$;
    `);
        await queryRunner.query(`
      ALTER TABLE sources
      ADD COLUMN IF NOT EXISTS type source_type NOT NULL DEFAULT 'ECOM',
      ADD COLUMN IF NOT EXISTS priority INT NOT NULL DEFAULT 0
    `);
        await queryRunner.query(`
      ALTER TABLE items
      ADD COLUMN IF NOT EXISTS view_count INT NOT NULL DEFAULT 0
    `);
        await queryRunner.query(`
      DELETE FROM item_coupon_links a
      USING item_coupon_links b
      WHERE a.item_id = b.item_id
        AND a.ctid > b.ctid
    `);
        await queryRunner.query(`
      ALTER TABLE item_coupon_links
      ADD CONSTRAINT item_coupon_links_item_unique UNIQUE (item_id)
    `);
        await queryRunner.query(`
      CREATE TYPE notification_category AS ENUM ('SYSTEM','EVENT','PERSONAL')
    `);
        await queryRunner.query(`
      CREATE TABLE notifications (
        id SERIAL PRIMARY KEY,
        category notification_category NOT NULL DEFAULT 'SYSTEM',
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        payload JSONB,
        source_id INT REFERENCES sources(id) ON DELETE SET NULL,
        item_id INT REFERENCES items(id) ON DELETE SET NULL,
        coupon_id INT REFERENCES coupons(id) ON DELETE SET NULL,
        tags TEXT[],
        importance SMALLINT NOT NULL DEFAULT 0,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        expires_at TIMESTAMPTZ,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    `);
        await queryRunner.query(`CREATE INDEX idx_notifications_category ON notifications(category)`);
        await queryRunner.query(`CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC)`);
    }
    async down(queryRunner) {
        await queryRunner.query(`DROP INDEX IF EXISTS idx_notifications_created_at`);
        await queryRunner.query(`DROP INDEX IF EXISTS idx_notifications_category`);
        await queryRunner.query(`DROP TABLE IF EXISTS notifications`);
        await queryRunner.query(`DROP TYPE IF EXISTS notification_category`);
        await queryRunner.query(`
      ALTER TABLE item_coupon_links
      DROP CONSTRAINT IF EXISTS item_coupon_links_item_unique
    `);
        await queryRunner.query(`
      ALTER TABLE items
      DROP COLUMN IF EXISTS view_count
    `);
        await queryRunner.query(`
      ALTER TABLE sources
      DROP COLUMN IF EXISTS priority,
      DROP COLUMN IF EXISTS type
    `);
        await queryRunner.query(`DROP TYPE IF EXISTS source_type`);
    }
}
exports.HomeExperience1721800000000 = HomeExperience1721800000000;
