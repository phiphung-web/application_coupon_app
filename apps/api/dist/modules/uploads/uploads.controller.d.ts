export declare class UploadsController {
    uploadFile(file: Express.Multer.File, folder?: string): {
        url: string;
        path: string;
        size: number;
        mimeType: string;
    };
}
