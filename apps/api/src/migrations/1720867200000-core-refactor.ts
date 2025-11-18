import { MigrationInterface, QueryRunner } from "typeorm";

export class CoreRefactor1720867200000 implements MigrationInterface {
  name = "CoreRefactor1720867200000";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP TABLE IF EXISTS favorite_sources CASCADE;
      DROP TABLE IF EXISTS favorite_coupons CASCADE;
      DROP TABLE IF EXISTS favorite_items CASCADE;
      DROP TABLE IF EXISTS product_coupons CASCADE;
      DROP TABLE IF EXISTS product_categories_map CASCADE;
      DROP TABLE IF EXISTS coupon_categories_map CASCADE;
      DROP TABLE IF EXISTS product_badges CASCADE;
      DROP TABLE IF EXISTS coupon_badges CASCADE;
      DROP TABLE IF EXISTS products CASCADE;
      DROP TABLE IF EXISTS coupons CASCADE;
      DROP TABLE IF EXISTS product_categories CASCADE;
      DROP TABLE IF EXISTS coupon_categories CASCADE;
      DROP TABLE IF EXISTS badges CASCADE;
      DROP TABLE IF EXISTS sources CASCADE;
      DROP TABLE IF EXISTS users CASCADE;
      DROP TYPE IF EXISTS user_role;
      DROP TYPE IF EXISTS discount_type;
      DROP TYPE IF EXISTS item_type;
    `);

    await queryRunner.query(`
      CREATE TABLE sources (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        image_url VARCHAR(255),
        website_url VARCHAR(255),
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TABLE badges (
        id SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        slug VARCHAR(50) UNIQUE,
        icon_url VARCHAR(255),
        color_code VARCHAR(7),
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TABLE item_categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        parent_id INT REFERENCES item_categories(id) ON DELETE SET NULL,
        image_url VARCHAR(255),
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TABLE coupon_categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TYPE item_type AS ENUM ('PRODUCT','APP','GAME','SERVICE');
      CREATE TYPE discount_type AS ENUM ('PERCENT','FIXED_AMOUNT','FREESHIP','GIFT');
      CREATE TYPE user_role AS ENUM ('USER','ADMIN');

      CREATE TABLE items (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        image_url VARCHAR(255),
        item_type item_type NOT NULL DEFAULT 'PRODUCT',
        item_url VARCHAR(255),
        price NUMERIC(12,2),
        source_id INT REFERENCES sources(id) ON DELETE SET NULL,
        category_id INT REFERENCES item_categories(id) ON DELETE SET NULL,
        badge_id INT REFERENCES badges(id) ON DELETE SET NULL,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TABLE coupons (
        id SERIAL PRIMARY KEY,
        code VARCHAR(100) NOT NULL,
        description TEXT,
        image_url VARCHAR(255),
        discount_type discount_type NOT NULL DEFAULT 'FIXED_AMOUNT',
        discount_value NUMERIC(12,2),
        deal_url VARCHAR(255),
        source_id INT REFERENCES sources(id) ON DELETE SET NULL,
        category_id INT REFERENCES coupon_categories(id) ON DELETE SET NULL,
        badge_id INT REFERENCES badges(id) ON DELETE SET NULL,
        start_date TIMESTAMPTZ,
        end_date TIMESTAMPTZ,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TABLE item_coupon_links (
        item_id INT NOT NULL REFERENCES items(id) ON DELETE CASCADE,
        coupon_id INT NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
        is_primary_display BOOLEAN DEFAULT FALSE,
        linked_at TIMESTAMPTZ DEFAULT NOW(),
        PRIMARY KEY (item_id, coupon_id)
      );

      CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(100) NOT NULL,
        image_url VARCHAR(255),
        email VARCHAR(255) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        role user_role NOT NULL DEFAULT 'USER',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE TABLE favorite_items (
        user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        item_id INT NOT NULL REFERENCES items(id) ON DELETE CASCADE,
        PRIMARY KEY (user_id, item_id)
      );

      CREATE TABLE favorite_coupons (
        user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        coupon_id INT NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
        PRIMARY KEY (user_id, coupon_id)
      );

      CREATE TABLE favorite_sources (
        user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        source_id INT NOT NULL REFERENCES sources(id) ON DELETE CASCADE,
        PRIMARY KEY (user_id, source_id)
      );
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP TABLE IF EXISTS favorite_sources;
      DROP TABLE IF EXISTS favorite_coupons;
      DROP TABLE IF EXISTS favorite_items;
      DROP TABLE IF EXISTS users;
      DROP TABLE IF EXISTS item_coupon_links;
      DROP TABLE IF EXISTS coupons;
      DROP TABLE IF EXISTS items;
      DROP TYPE IF EXISTS discount_type;
      DROP TYPE IF EXISTS item_type;
      DROP TABLE IF EXISTS coupon_categories;
      DROP TABLE IF EXISTS item_categories;
      DROP TABLE IF EXISTS badges;
      DROP TABLE IF EXISTS sources;
      DROP TYPE IF EXISTS user_role;
    `);
  }
}
