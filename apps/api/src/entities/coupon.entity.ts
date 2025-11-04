// src/entities/coupon.entity.ts
export type CouponType = 'PERCENT' | 'FIXED';

@Entity('coupons')
export class Coupon {
  @PrimaryGeneratedColumn() id: number;

  @Column() title: string;
  @Column({ unique: true }) code: string;

  @Column({ type: 'varchar' }) type: CouponType;   // PERCENT|FIXED
  @Column({ type: 'integer' }) value: number;      // % khi PERCENT | số tiền khi FIXED
  @Column({ type: 'integer', default: 0 }) maxDiscount: number; // trần giảm

  @Column({ type: 'integer', nullable: true }) minOrder?: number;
  @Column({ default: false }) isHot: boolean;

  @ManyToOne(() => Shop, (s) => s.coupons) shop: Shop;
  @ManyToOne(() => Category, (c) => c.coupons) category: Category; // áp theo danh mục chính

  // Nhiều danh mục áp dụng thêm (tuỳ bạn có Product entity hay chưa)
  @ManyToMany(() => Category)
  @JoinTable({ name: 'coupon_applicable_categories' })
  applicableCategories: Category[];

  // Loại sản phẩm áp dụng (ví dụ: 'Accessory','Shoes',...) – lưu nhanh bằng JSON
  @Column({ type: 'simple-json', nullable: true })
  applicableTypes?: string[];     // hiển thị lên “item mã”

  @Column({ type: 'simple-json', nullable: true })
  excludedTypes?: string[];       // loại trừ (nếu có)

  @Column({ type: 'datetime' }) expiredAt: Date;
  @CreateDateColumn() createdAt: Date;
}
