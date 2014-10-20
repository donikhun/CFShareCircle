//
//  Sharer.h
//  CFShareCircle
//
//  Created by Camden on 1/15/13.
//  Copyright (c) 2013 Camden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "Pinterest.h"
#import "MGInstagram.h"

#import "FacebookSDK.h"

@class CFShareCircleView;

typedef enum {
  CFSharerTypeInstagram,
  CFSharerTypeMail,
  CFSharerTypeSave,
  CFSharerTypeFacebook,
  CFSharerTypePinterest,
  CFSharerTypeTwitter,
  CFSharerTypeMore
} CFSharerType;

typedef void (^Block)();

typedef void (^FacebookCompletionBlock)(NSError *error, NSDictionary *results, FBWebDialogResult result);


@interface CFSharer : NSObject <MFMailComposeViewControllerDelegate> {
  Block savedCompletionBlock;
}

@property NSString *name;
@property UIImage *image;
@property CFSharerType type;
@property (weak) CFShareCircleView *shareView;

/**
 Initialize a custom sharer with the name that will be presented when hovering over and the name of the image.
 */
- (id)initWithName:(NSString *)name imageName:(NSString *)imageName type:(CFSharerType)type;

- (void)share:(Block)completionBlock;

+ (CFSharer *)instagram;
+ (CFSharer *)mail;
+ (CFSharer *)save;
+ (CFSharer *)facebook;
+ (CFSharer *)twitter;
+ (CFSharer *)pinterest;
//+ (CFSharer *)googleDrive;
//+ (CFSharer *)dropbox;
//+ (CFSharer *)evernote;

@end
