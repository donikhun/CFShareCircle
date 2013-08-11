//
//  CFShareCircleView.h
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "CFSharer.h"

@class CFShareCircleView;

@protocol CFShareCircleViewDelegate
- (void)shareCircleDidCancel;
- (void)shareCircleView:(CFShareCircleView *)aShareCircleView didSelectSharer:(CFSharer *)sharer;
@end

@interface CFShareCircleView : UIView<UITableViewDelegate, UITableViewDataSource>

@property (assign) id <CFShareCircleViewDelegate> delegate;
@property (retain) NSMutableDictionary *params;

@property (assign) UIViewController *parentViewController;

/**
 Initialize the share circle with a custom list of sharers and custom photo and message for sharing.
 */
- (id)initWithFrame:(CGRect)frame sharers:(NSArray *)sharers;

/**
 Animates the share circle into view.
 */
- (void)show;

/**
 Animates the share circle out of view.
 */
- (void)hide;

@end
