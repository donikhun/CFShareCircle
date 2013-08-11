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
#import "Facebook.h"

@class CFShareCircleView;

@interface CFSharer : NSObject <MFMailComposeViewControllerDelegate>

typedef enum {
  CFSharerTypeInstagram,
  CFSharerTypeMail,
  CFSharerTypeSave,
  CFSharerTypeFacebook,
  CFSharerTypePinterest,
  CFSharerTypeTwitter,
  CFSharerTypeMore
} CFSharerType;

typedef void (^FacebookCompletionBlock)(NSError *error, NSDictionary *results, FBWebDialogResult result);


@property NSString *name;
@property UIImage *image;
@property CFSharerType type;
@property (weak) CFShareCircleView *shareView;

/**
 Initialize a custom sharer with the name that will be presented when hovering over and the name of the image.
 */
- (id)initWithName:(NSString *)name imageName:(NSString *)imageName type:(CFSharerType)type;

- (void)share;

+ (CFSharer *)instagram;
+ (CFSharer *)mail;
+ (CFSharer *)save;
+ (CFSharer *)facebook;
+ (CFSharer *)pinterest;
+ (CFSharer *)twitter;
//+ (CFSharer *)googleDrive;
//+ (CFSharer *)dropbox;
//+ (CFSharer *)evernote;

@end
