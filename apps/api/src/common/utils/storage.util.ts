export function toPublicUrl(path?: string | null) {
  if (!path) return path ?? undefined;
  if (/^https?:\/\//i.test(path)) {
    return path;
  }
  const cleaned = path.replace(/^\/+/, "");
  const base =
    process.env.APP_URL?.replace(/\/$/, "") ||
    `http://localhost:${process.env.PORT || 3000}`;
  return `${base}/uploads/${cleaned}`;
}
