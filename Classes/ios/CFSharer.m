//
//  Sharer.m
//  CFShareCircle
//
//  Created by Camden on 1/15/13.
//  Copyright (c) 2013 Camden. All rights reserved.
//

#import "CFSharer.h"
#import "SVProgressHUD.h"
#import "SIAlertView.h"
#import "CFShareCircleView.h"

#define kPinterestClientId @"XXXXXX"

@implementation CFSharer

@synthesize type = _type;
@synthesize name = _name;
@synthesize image = _image;

#pragma mark - Initializers
- (id)initWithName:(NSString *)name imageName:(NSString *)imageName type:(CFSharerType)type {
  self = [super init];
  if (self) {
    _name = name;
    _image = [UIImage imageNamed:imageName];
    _type = type;
  }
  return self;
}

#pragma mark - Methods
- (void)share {
  if (_type == CFSharerTypeInstagram) {
    [self shareToInstagram];
  }
  else if (_type == CFSharerTypeMail) {
    [self shareToMail];
  }
  else if (_type == CFSharerTypeSave) {
    [self shareToSave];
  }
  else if (_type == CFSharerTypeFacebook) {
    [self shareToFacebook];
  }
//  else if (_type == CFSharerTypePinterest) {
//    [self shareToPinterest];
//  }
  else if (_type == CFSharerTypeTwitter) {
    [self shareToTwitter];
  }
}

#pragma mark - Instagram
+ (CFSharer *)instagram {
  return [[CFSharer alloc] initWithName:@"Instagram" imageName:@"instagram.png" type:CFSharerTypeInstagram];
}

- (void)shareToInstagram {
  if ([MGInstagram isAppInstalled]) {
    [MGInstagram postImage:self.shareView.params[@"image"] withCaption:self.shareView.params[@"full_caption"] inView:self.shareView.parentViewController.view];
  }
  else {
    [SIAlertView presentErrorWithMessage:@"Please install the Instagram app"];
  }
}

#pragma mark - Instagram
+ (CFSharer *)mail {
  return [[CFSharer alloc] initWithName:@"Mail" imageName:@"mail.png" type:CFSharerTypeMail];
}

- (void)shareToMail {
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    [mailer addAttachmentData:UIImagePNGRepresentation(self.shareView.params[@"image"]) mimeType:@"image/jpeg" fileName:@"SoL_Photo"];
    [mailer setMessageBody:self.shareView.params[@"full_caption"] isHTML:NO];
    [mailer setSubject:self.shareView.params[@"subject"]];
    [self.shareView.parentViewController presentViewController:mailer animated:YES completion:nil];
  }
  else {
    [SIAlertView presentErrorWithMessage:@"Cannot access Mail app from your device"];
  }
}

//MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
  [self.shareView.parentViewController dismissModalViewControllerAnimated:YES];
  if (result == MFMailComposeResultSent) {
    [SVProgressHUD showSuccessWithStatus:@"Shared!"];
  }
}

#pragma mark - Save
+ (CFSharer *)save {
  return [[CFSharer alloc] initWithName:@"Save" imageName:@"camera_roll.png" type:CFSharerTypeSave];
}

- (void)shareToSave {
  [SVProgressHUD showWithStatus:@"Saving..." maskType:SVProgressHUDMaskTypeGradient];
  UIImageWriteToSavedPhotosAlbum(self.shareView.params[@"image"], nil, nil, nil);
  [SVProgressHUD showSuccessWithStatus:@"Saved!"];
}

#pragma mark - Facebook
+ (CFSharer *)facebook {
  return [[CFSharer alloc] initWithName:@"Facebook" imageName:@"facebook.png" type:CFSharerTypeFacebook];
}

- (void)shareToFacebook {
  //For some reason the description for FBShareDialog works but not Caption, while Caption works correctly for FBDialogs
  FBShareDialogParams *shareParams = [[FBShareDialogParams alloc] init];
  shareParams.name = self.shareView.params[@"message"];
  shareParams.description = self.shareView.params[@"caption"];
  shareParams.link = self.shareView.params[@"image_url"];
  shareParams.picture = self.shareView.params[@"image_url"];
  
  NSDictionary *params = @{@"name" : shareParams.name, @"caption" : shareParams.description,
                           @"picture" : [self.shareView.params[@"image_url"] absoluteString],
                           @"link" : [self.shareView.params[@"image_url"] absoluteString]};
  
  
  FacebookCompletionBlock completionBlock = ^(NSError *error, NSDictionary *results, FBWebDialogResult result) {
    if(error) {
      [SIAlertView presentErrorWithMessage:@"Error publishing story, please try again"];
    } else if ((results[@"completionGesture"] && [results[@"completionGesture"] isEqualToString:@"cancel"]) || result == FBWebDialogResultDialogNotCompleted) {}
    else {
      [SVProgressHUD showSuccessWithStatus:@"Shared!"];
    }
  };
  
  
  if ([FBDialogs canPresentShareDialogWithParams:shareParams]) {
    [FBDialogs presentShareDialogWithParams:shareParams clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
      completionBlock(error, results, nil);
    }];
    
  }
  else {
    [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
      completionBlock(error, nil, result);
    }];
  }
}
//
//#pragma mark - Pinterest
//+ (CFSharer *)pinterest {
//  return [[CFSharer alloc] initWithName:@"Pinterest" imageName:@"pinterest.png" type:CFSharerTypePinterest];
//}
//
//- (void)shareToPinterest {
//  Pinterest *_pinterest = [[Pinterest alloc] initWithClientId:kPinterestClientId];
//  [_pinterest createPinWithImageURL:self.shareView.params[@"image_url"] sourceURL:self.shareView.params[@"source_url"] description:self.shareView.params[@"caption"]];
//}

#pragma mark - Twitter
+ (CFSharer *)twitter {
  return [[CFSharer alloc] initWithName:@"Twitter" imageName:@"twitter.png" type:CFSharerTypeTwitter];
}

- (void)shareToTwitter {
  if ([TWTweetComposeViewController canSendTweet]) {
    TWTweetComposeViewController *tweetComposer = [[TWTweetComposeViewController alloc] init];
    [tweetComposer setInitialText:self.shareView.params[@"message"]];
    [tweetComposer addImage:self.shareView.params[@"image"]];
    [self.shareView.parentViewController presentViewController:tweetComposer animated:YES completion:nil];
    [tweetComposer setCompletionHandler:^(SLComposeViewControllerResult result) {
      [self.shareView.parentViewController dismissModalViewControllerAnimated:YES];
      if (result == SLComposeViewControllerResultDone) {
        [SVProgressHUD showSuccessWithStatus:@"Shared!"];
      }
    }];
  }
  else {
    [SIAlertView presentErrorWithMessage:@"Please sign into Twitter on your device's settings"];
  }
}

//#pragma mark - GoogleDrive
//+ (CFSharer *)googleDrive {
//    return [[CFSharer alloc] initWithName:@"Google Drive" imageName:@"google_drive.png"];
//}

//- (void)shareToGoogleDrive {
//
//}

//#pragma mark - Dropbox
//+ (CFSharer *)dropbox {
//    return [[CFSharer alloc] initWithName:@"Dropbox" imageName:@"dropbox.png"];
//}

//- (void)shareToDropbox {
//
//}

//#pragma mark - Evernote
//+ (CFSharer *)evernote {
//    return [[CFSharer alloc] initWithName:@"Evernote" imageName:@"evernote.png"];
//}

//- (void)shareToEvernote {
//
//}


@end
