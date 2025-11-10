// src/admin/admin.auth.ts


export function buildAuth(){
  const ADMIN_EMAIL = process.env.ADMIN_EMAIL || "admin@example.com";
  const ADMIN_PASS = process.env.ADMIN_PASSWORD || "admin123";

  return {
    authenticate: async (email: string, password: string) =>
      email === ADMIN_EMAIL && password === ADMIN_PASS ? { email } : null,
    cookieName: "adminjs",
    cookiePassword: process.env.ADMIN_COOKIE_SECRET || "replace_me",
  };
}
