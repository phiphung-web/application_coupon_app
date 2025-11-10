export declare function buildAuth(): {
    authenticate: (email: string, password: string) => Promise<{
        email: string;
    } | null>;
    cookieName: string;
    cookiePassword: string;
};
