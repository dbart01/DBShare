DBShare
=======

Do you every wish sending an email or message from within the app didn't have to go through the pain of setting up delegates and dealing with MFMailComposeViewController? Now you don't have to! DBShare is a library that makes MFMailComposeViewController and MFMessageComposeViewController problems a thing of the past.

Here's how to quickly send an email:
```objc
NSString *subject   = @"A Simple Email";
NSString *body      = @"Its really easy to send emails now!";
NSString *recipient = @"your.email@gmail.com";

DBShareMail *mailShare = [[DBShareMail alloc] initWithController:self];
[mailShare addRecipient:recipient];
[mailShare setSubject:subject];
[mailShare setBody:body];
[mailShare setFinishedHandler:^(MFMailComposeResult result, NSError *error) {
    // This is option, but provides a handle on completion
    if (result == MFMailComposeResultSent) {
        // Message is sent
    }
}];
[mailShare present];
```

Just as easily you can send messages:
```objc
DBShareMessage *messageShare = [DBShareMessage shareFromController:self];
[messageShare setBody:body];
[messageShare setFinishedHandler:^(MessageComposeResult result) {
    // Again, this is optional
    if (result == MessageComposeResultSent) {
        // Message sent
    }
}];
[messageShare present];
```

Both <code>DBShareMail</code> and <code>DBShareMessage</code> inherit from the <code>DBShareable</code> object, which supports adding attachments. For both mail and message sharing, adding an attachment is as simple as:
```objc
- (void)sendImage:(UIImage *)image {
    DBShareAttachment *attachment = [DBShareAttachment attachmentWithJPEGImage:image quality:0.85f fileName:@"image.jpeg"];
    DBShareMessage *messageShare  = [DBShareMessage shareFromController:self];
    [messageShare addAttachment:attachment];
    [messageShare present];
}
```
