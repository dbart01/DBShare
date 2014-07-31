DBShare
=======

Do you every wish sending an email or message from within the app didn't have to go through the pain of setting up delegates and dealing with MFMailComposeViewController? Now you don't have to! DBShare is a library that makes MFMailComposeViewController and MFMessageComposeViewController problems a thing of the past.

Here's how to quickly send an email:
```objc
NSString *subject = @"A Simple Email";
NSString *body    = @"Its really easy to send emails now!";

DBShareMail *mailShare = [[DBShareMail alloc] initWithController:self];
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
