//
//  DBShare.h
//
//  Created by Dima Bart on 2014-04-23.
//  Copyright (c) 2014 Dima Bart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

static NSString * const __DBMimeType[] = {
    @"application/pdf",
    @"application/ogg",
    @"application/postscript",
    @"application/json",
    @"application/javascript",
    @"application/octet-stream",
    @"application/atom+xml",
    @"application/rss+xml",
    @"application/soap+xml",
    @"application/zip",
    @"application/gzip",
    @"application/x-www-form-urlencoded",
    
    @"multipart/form-data",
    @"multipart/mixed",
    @"multipart/alternative",
    @"multipart/related",
    @"multipart/signed",
    @"multipart/encrypted",
    
    @"image/gif",
    @"image/jpeg",
    @"image/png",
    @"image/tiff",
    @"image/svg+xml",
    
    @"video/avi",
    @"video/mpeg",
    @"video/mp4",
    @"video/ogg",
    @"video/quicktime",
    @"video/webm",
    @"video/x-matroska",
    @"video/x-ms-wmv",
    @"video/x-flv",
    
    @"text/plain",
    @"text/xml",
    @"text/html",
    @"text/javascript",
    @"text/css",
    @"",
};
typedef enum {
    DBMimeTypeAppPDF,
    DBMimeTypeAppOGG,
    DBMimeTypeAppPostscript,
    DBMimeTypeAppJSON,
    DBMimeTypeAppJavascript,
    DBMimeTypeAppOctetStream,
    DBMimeTypeAppAtomXML,
    DBMimeTypeAppRSSXML,
    DBMimeTypeAppSoapXML,
    DBMimeTypeAppZip,
    DBMimeTypeAppGZip,
    DBMimeTypeAppFormURLEncoded,
    
    DBMimeTypeMultiPartForm,
    DBMimeTypeMultiPartMixed,
    DBMimeTypeMultiPartAlternative,
    DBMimeTypeMultiPartRelated,
    DBMimeTypeMultiPartSigned,
    DBMimeTypeMultiPartEncrypted,
    
    DBMimeTypeImageGIF,
    DBMimeTypeImageJPEG,
    DBMimeTypeImagePNG,
    DBMimeTypeImageTIFF,
    DBMimeTypeImageSVG,
    
    DBMimeTypeVideoAVI,
    DBMimeTypeVideoMPEG,
    DBMimeTypeVideoMP4,
    DBMimeTypeVideoOGG,
    DBMimeTypeVideoQuicktime,
    DBMimeTypeVideoWebM,
    DBMimeTypeVideoMKV,
    DBMimeTypeVideoWMV,
    DBMimeTypeVideoFLV,
    
    DBMimeTypeTextPlain,
    DBMimeTypeTextXML,
    DBMimeTypeTextHTML,
    DBMimeTypeTextJavascript,
    DBMimeTypeTextCSS,
    DBMimeTypeNone = -1,
} DBMimeType;

typedef void (^DBShareMailFinishedHandler)(MFMailComposeResult result, NSError *error);
typedef void (^DBShareMessageFinishedHandler)(MessageComposeResult result);

@interface DBShareAttachment : NSObject

@property (assign, nonatomic, readonly) DBMimeType mimeType;
@property (strong, nonatomic, readonly) NSString *fileName;
@property (strong, nonatomic, readonly) NSData *data;

+ (instancetype)attachmentWithData:(NSData *)data mime:(DBMimeType)mimeType fileName:(NSString *)fileName;
+ (instancetype)attachmentWithData:(NSData *)data;
+ (instancetype)attachmentWithPNGImage:(UIImage *)image fileName:(NSString *)fileName;
+ (instancetype)attachmentWithJPEGImage:(UIImage *)image quality:(CGFloat)quality fileName:(NSString *)fileName;

@end

@interface DBShareable : NSObject

@property (strong, nonatomic, readonly) UIViewController *targetController;
@property (strong, nonatomic, readonly) NSString *subject;
@property (strong, nonatomic, readonly) NSString *body;
@property (strong, nonatomic, readonly) NSMutableSet *recipients;
@property (strong, nonatomic, readonly) NSMutableArray *attachments;

+ (instancetype)shareFromController:(UIViewController *)targetController;
- (instancetype)initWithController:(UIViewController *)controller;

- (void)setSubject:(NSString *)subject;
- (void)setBody:(NSString *)body;
- (void)addRecipient:(NSString *)recipient;
- (void)addAttachment:(DBShareAttachment *)attachement;

- (void)present;

@end

@interface DBShareMail : DBShareable

@property (assign, nonatomic, readonly) BOOL isHTMLBody;
@property (strong, nonatomic, readonly) NSMutableSet *ccRecipients;
@property (strong, nonatomic, readonly) NSMutableSet *bccRecipients;

- (void)addCcRecipient:(NSString *)ccRecipient;
- (void)addBccRecipient:(NSString *)bccRecipient;
- (void)setBody:(NSString *)body isHTML:(BOOL)isHTML;
- (void)setFinishedHandler:(DBShareMailFinishedHandler)finishedHandler;

@end

@interface DBShareMessage : DBShareable

- (void)setFinishedHandler:(DBShareMessageFinishedHandler)finishedHandler;

@end
