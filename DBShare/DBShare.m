//
//  DBShare.m
//
//  Created by Dima Bart on 2014-04-23.
//  Copyright (c) 2014 Dima Bart. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "DBShare.h"

#pragma mark - DBShareAttachment -
@implementation DBShareAttachment

+ (instancetype)attachmentWithData:(NSData *)data mime:(DBMimeType)mimeType fileName:(NSString *)fileName {
    DBShareAttachment *attachment = [[DBShareAttachment alloc] init];
    attachment->_data     = data;
    attachment->_mimeType = mimeType;
    attachment->_fileName = fileName;
    return attachment;
}

+ (instancetype)attachmentWithData:(NSData *)data {
    return [self attachmentWithData:data mime:DBMimeTypeAppOctetStream fileName:@"attachment"];
}

+ (instancetype)attachmentWithPNGImage:(UIImage *)image fileName:(NSString *)fileName {
    return [self attachmentWithData:UIImagePNGRepresentation(image) mime:DBMimeTypeImagePNG fileName:fileName];
}

+ (instancetype)attachmentWithJPEGImage:(UIImage *)image quality:(CGFloat)quality fileName:(NSString *)fileName {
    return [self attachmentWithData:UIImageJPEGRepresentation(image, quality) mime:DBMimeTypeImageJPEG fileName:fileName];
}

- (NSString *)mimeString {
    return __DBMimeType[_mimeType];
}

- (void)dealloc {
    
}

@end

#pragma mark - DBShareable -
@interface DBShareable () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) id completionHandler;
@property (strong, nonatomic) dispatch_block_t captureBlock;

- (void)cleanup;

@end

@implementation DBShareable

@synthesize recipients  = _recipients;
@synthesize attachments = _attachments;

#pragma mark - Init -
+ (instancetype)shareFromController:(UIViewController *)targetController {
    return [[[self class] alloc] initWithController:targetController];
}

- (instancetype)initWithController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        _targetController = controller;
    }
    return self;
}

- (void)dealloc {
    
}

#pragma mark - Getters -
- (NSMutableSet *)recipients {
    if (_recipients) {
        return _recipients;
    }
    _recipients = [NSMutableSet new];
    return _recipients;
}

- (NSMutableArray *)attachments {
    if (_attachments) {
        return _attachments;
    }
    _attachments = [NSMutableArray new];
    return _attachments;
}

#pragma mark - Setters -
- (void)setSubject:(NSString *)subject {
    _subject = subject;
}

- (void)setBody:(NSString *)body {
    _body = body;
}

- (void)addRecipient:(NSString *)recipient {
    [self.recipients addObject:recipient];
}

- (void)addAttachment:(DBShareAttachment *)attachement {
    [self.attachments addObject:attachement];
}

#pragma mark - Presenting -
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
- (void)present {
    _captureBlock = ^{
        [self completionHandler]; // Used to keep the object alive for delegate callback, a little hack ;)
    };
}
#pragma clang diagnostic pop

#pragma mark - Mail Delegate -
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.targetController dismissViewControllerAnimated:YES completion:nil];
    
    DBShareMailFinishedHandler finishedHandler = _completionHandler;
    if (finishedHandler) finishedHandler(result, error);
    
    [self cleanup];
}

#pragma mark - Message Delegate -
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self.targetController dismissViewControllerAnimated:YES completion:nil];
    
    DBShareMessageFinishedHandler finishedHandler = _completionHandler;
    if (finishedHandler) finishedHandler(result);
    
    [self cleanup];
}

#pragma mark - Cleanup -
- (void)cleanup {
    _completionHandler = nil;
    _captureBlock      = nil;
}

@end

#pragma mark - DBShareMail -
@interface DBShareMail ()


@end

@implementation DBShareMail

@synthesize ccRecipients  = _ccRecipients;
@synthesize bccRecipients = _bccRecipients;

#pragma mark - Queries -
+ (BOOL)canSendMail {
    return [MFMailComposeViewController canSendMail];
}

#pragma mark - Getters -
- (NSMutableSet *)ccRecipients {
    if (_ccRecipients) {
        return _ccRecipients;
    }
    _ccRecipients = [NSMutableSet new];
    return _ccRecipients;
}

- (NSMutableSet *)bccRecipients {
    if (_bccRecipients) {
        return _bccRecipients;
    }
    _bccRecipients = [NSMutableSet new];
    return _bccRecipients;
}

#pragma mark - Setters -
- (void)addCcRecipient:(NSString *)ccRecipient {
    [self.ccRecipients addObject:ccRecipient];
}

- (void)addBccRecipient:(NSString *)bccRecipient {
    [self.bccRecipients addObject:bccRecipient];
}

- (void)setBody:(NSString *)body isHTML:(BOOL)isHTML {
    [super setBody:body];
    _isHTMLBody = isHTML;
}

- (void)setFinishedHandler:(DBShareMailFinishedHandler)finishedHandler {
    [self setCompletionHandler:finishedHandler];
}

#pragma mark - Present -
- (void)present {
    [super present];
    
    if (![DBShareMail canSendMail]) {
        NSLog(@"DBShare: Failed to send email. Functionality is unavailable.");
        [self cleanup];
        return;
    }
    
    MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
    [composer setSubject:self.subject];
    [composer setToRecipients:[self.recipients allObjects]];
    [composer setMessageBody:self.body isHTML:self.isHTMLBody];
    [composer setMailComposeDelegate:self];
    
    if (_ccRecipients) {
        [composer setCcRecipients:[self.ccRecipients allObjects]];
    }
    
    if (_bccRecipients) {
        [composer setBccRecipients:[self.bccRecipients allObjects]];
    }
    
    
    for (DBShareAttachment *attachment in self.attachments) {
        [composer addAttachmentData:attachment.data mimeType:[attachment mimeString] fileName:attachment.fileName];
    }
    [self.targetController presentViewController:composer animated:YES completion:nil];
}

@end

#pragma mark - DBShareMessage -
@interface DBShareMessage ()

@end

@implementation DBShareMessage

#pragma mark - Queries -
+ (BOOL)canSendMessage {
    return [MFMessageComposeViewController canSendText];
}

+ (BOOL)canSendAttachments {
    return [MFMessageComposeViewController canSendAttachments];
}

+ (BOOL)canSendSubject {
    return [MFMessageComposeViewController canSendSubject];
}

#pragma mark - Setters -
- (void)setFinishedHandler:(DBShareMessageFinishedHandler)finishedHandler {
    [self setCompletionHandler:finishedHandler];
}

#pragma mark - Present -
- (void)present {
    [super present];
    
    if (![DBShareMessage canSendMessage]) {
        NSLog(@"DBShare: Failed to send message. Functionality is unavailable.");
        [self cleanup];
        return;
    }
    
    MFMessageComposeViewController *composer = [[MFMessageComposeViewController alloc] init];
    if ([DBShareMessage canSendSubject]) {
        [composer setSubject:self.subject];
    }
    
    [composer setRecipients:[self.recipients allObjects]];
    [composer setBody:self.body];
    [composer setMessageComposeDelegate:self];
    
    if ([DBShareMessage canSendAttachments]) {
        for (DBShareAttachment *attachment in self.attachments) {
            NSString *type = CFBridgingRelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)[attachment mimeString], NULL));
            [composer addAttachmentData:attachment.data typeIdentifier:type filename:attachment.fileName];
        }
    } else {
        NSLog(@"DBShare: Attachment functionality is unavailable.");
    }
    [self.targetController presentViewController:composer animated:YES completion:nil];
}

@end
