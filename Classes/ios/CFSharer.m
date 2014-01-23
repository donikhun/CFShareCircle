//
//  Sharer.m
//  CFShareCircle
//
//  Created by Camden on 1/15/13.
//  Copyright (c) 2013 Camden. All rights reserved.
//

#import "CFSharer.h"
#import "SIAlertView.h"
#import "CFShareCircleView.h"

#define kFacebookAppID @"xxxxx"
#define kPinterestClientId @"xxxxx"

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
- (void)share:(Block)completionBlock {
  if (_type == CFSharerTypeInstagram) {
    [self shareToInstagram:completionBlock];
  }
  else if (_type == CFSharerTypeMail) {
    [self shareToMail:completionBlock];
  }
  else if (_type == CFSharerTypeSave) {
    [self shareToSave:completionBlock];
  }
  else if (_type == CFSharerTypeFacebook) {
    [self shareToFacebook:completionBlock];
  }
  else if (_type == CFSharerTypePinterest) {
    [self shareToPinterest:completionBlock];
  }
  else if (_type == CFSharerTypeTwitter) {
    [self shareToTwitter:completionBlock];
  }
}

#pragma mark - Instagram
+ (CFSharer *)instagram {
  return [[CFSharer alloc] initWithName:@"Instagram" imageName:@"instagram.png" type:CFSharerTypeInstagram];
}

- (void)shareToInstagram:(Block)completionBlock {
  if ([MGInstagram isAppInstalled]) {
    [MGInstagram postImage:self.shareView.params[@"image"] withCaption:@"via #societyoflacquer" inView:self.shareView.parentViewController.view];
    completionBlock();
  }
  else {
    [SIAlertView presentErrorWithMessage:@"Please install the Instagram app"];
  }
}

#pragma mark - Instagram
+ (CFSharer *)mail {
  return [[CFSharer alloc] initWithName:@"Mail" imageName:@"mail.png" type:CFSharerTypeMail];
}

- (void)shareToMail:(Block)completionBlock {
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    [mailer addAttachmentData:UIImagePNGRepresentation(self.shareView.params[@"image"]) mimeType:@"image/jpeg" fileName:@"SoL_Photo"];
    [mailer setMessageBody:self.shareView.params[@"full_caption"] isHTML:NO];
    [mailer setSubject:self.shareView.params[@"subject"]];
    [self.shareView.parentViewController presentViewController:mailer animated:YES completion:nil];
    savedCompletionBlock = completionBlock;
  }
  else {
    [SIAlertView presentErrorWithMessage:@"Cannot access Mail app from your device"];
    completionBlock();
  }
}

//MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
  [self.shareView.parentViewController dismissViewControllerAnimated:YES completion:^{
    savedCompletionBlock();
  }];
}

#pragma mark - Save
+ (CFSharer *)save {
  return [[CFSharer alloc] initWithName:@"Save" imageName:@"camera_roll.png" type:CFSharerTypeSave];
}

- (void)shareToSave:(Block)completionBlock {
  UIImageWriteToSavedPhotosAlbum(self.shareView.params[@"image"], nil, nil, nil);
  completionBlock();
}

#pragma mark - Facebook
+ (CFSharer *)facebook {
  return [[CFSharer alloc] initWithName:@"Facebook" imageName:@"facebook.png" type:CFSharerTypeFacebook];
}

- (void)shareToFacebook:(Block)completionBlock {
  ACAccountStore *account = [[ACAccountStore alloc] init];
  ACAccountType *facebookType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
  
  NSDictionary *options = @{ ACFacebookAppIdKey: kFacebookAppID, ACFacebookPermissionsKey: @[@"publish_stream"], ACFacebookAudienceKey: ACFacebookAudienceFriends };

  [account requestAccessToAccountsWithType:facebookType options:options completion:^(BOOL granted, NSError *error) {
    if (granted) {
      NSArray *accounts = [account accountsWithAccountType:facebookType];
      if (accounts.count == 0) {
        [self.shareView.delegate shareCircleView:self.shareView didEncounterErrorMessage:@"No facebook accounts available! Please add one in your device settings."];
      }
      else {
        NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/photos"];
        NSDictionary *params = @{@"message" : @"via www.appstore.com/SocietyOfLacquer"};
        NSData *imageData = UIImagePNGRepresentation(self.shareView.params[@"image"]);

        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                requestMethod:SLRequestMethodPOST
                                                          URL:url
                                                   parameters:params];
        [request addMultipartData:imageData
                         withName:@"source"
                             type:@"multipart/form-data"
                         filename:@"Image"];
        
        [request setAccount:[accounts lastObject]];
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
          if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
              completionBlock();
            }
            else {
              [self.shareView.delegate shareCircleView:self.shareView didEncounterErrorMessage:[NSString stringWithFormat:@"[Error] invalid status code: %@", error.localizedDescription]];
            }
          }
          else {
            [self.shareView.delegate shareCircleView:self.shareView didEncounterErrorMessage:[NSString stringWithFormat:@"[Error] uploading post: %@", error.localizedDescription]];
          }
          
        }];
      }
    }
    else {
      [self.shareView.delegate shareCircleView:self.shareView didEncounterErrorMessage:@"[Error] with account authorization. Please check that you havea facebook account linked in your device settings."];
    }
  }];
}
//
#pragma mark - Pinterest
+ (CFSharer *)pinterest {
  return [[CFSharer alloc] initWithName:@"Pinterest" imageName:@"pinterest.png" type:CFSharerTypePinterest];
}

- (void)shareToPinterest:(Block)completionBlock {
  Pinterest *_pinterest = [[Pinterest alloc] initWithClientId:kPinterestClientId];
  [_pinterest createPinWithImageURL:self.shareView.params[@"image_url"] sourceURL:self.shareView.params[@"source_url"] description:@"via www.appstore.com/SocietyOfLacuqer"];
  completionBlock();
}

#pragma mark - Twitter
+ (CFSharer *)twitter {
  return [[CFSharer alloc] initWithName:@"Twitter" imageName:@"twitter.png" type:CFSharerTypeTwitter];
}

- (void)shareToTwitter:(Block)completionBlock {
  ACAccountStore *account = [[ACAccountStore alloc] init];
  ACAccountType *twitterType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  
  [account requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
    if (granted) {
      NSArray *accounts = [account accountsWithAccountType:twitterType];
      if (accounts.count == 0) {
        [self.shareView.delegate shareCircleView:self.shareView didEncounterErrorMessage:@"No twitter accounts available! Please add one in your device settings."];
      }
      else {
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
        NSDictionary *params = @{@"status" : @"via #societyoflacquer"};
        NSData *imageData = UIImageJPEGRepresentation(self.shareView.params[@"image"], 1.0f);
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodPOST
                                                          URL:url
                                                   parameters:params];
        [request addMultipartData:imageData
                         withName:@"media[]"
                             type:@"image/jpeg"
                         filename:@"image.jpg"];
        
        [request setAccount:[accounts lastObject]];
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
          if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
              completionBlock();
            }
            else {
              [self.shareView.delegate shareCircleView:self.shareView didEncounterErrorMessage:[NSString stringWithFormat:@"[Error] invalid status code: %@", error.localizedDescription]];
            }
          }
          else {
            [self.shareView.delegate shareCircleView:self.shareView didEncounterErrorMessage:[NSString stringWithFormat:@"[Error] uploading tweet: %@", error.localizedDescription]];
          }
          
        }];
      }
    }
    else {
      [self.shareView.delegate shareCircleView:self.shareView didEncounterErrorMessage:@"[Error] with account authorization. Please check that you havea twitter account linked in your device settings."];
    }
  }];
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
