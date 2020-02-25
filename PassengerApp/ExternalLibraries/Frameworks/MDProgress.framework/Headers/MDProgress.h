//
//  MDProgress.h
//  MDProgress
//
//  Created by Admin on 03/09/18.
//  Copyright © 2018 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MDProgressLayer.h"
#import "MDLinearProgressLayer.h"
#import "UIColorHelper.h"
#import "MDCircularProgressLayer.h"
#import "UIViewHelper.h"
#import "MDConstants.h"

//! Project version number for MDProgress.
FOUNDATION_EXPORT double MDProgressVersionNumber;

//! Project version string for MDProgress.
FOUNDATION_EXPORT const unsigned char MDProgressVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MDProgress/PublicHeader.h>

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MDProgressStyle) {
    MDProgressStyleCircular,
    MDProgressStyleLinear
};

typedef NS_ENUM(NSInteger, MDProgressType) {
    MDProgressTypeIndeterminate,
    MDProgressTypeDeterminate,
    //  MDProgressTypeBuffer,
    //  MDProgressTypeQueryIndeterminateAndDeterminate
};


@interface MDProgress : UIView

@property(nonatomic) IBInspectable UIColor *progressColor;
@property(nonatomic) IBInspectable UIColor *trackColor;
@property(nonatomic) MDProgressType progressType;
@property(nonatomic) MDProgressStyle progressStyle;

@property(nonatomic) IBInspectable NSInteger type;
@property(nonatomic) IBInspectable NSInteger style;
@property(nonatomic) IBInspectable CGFloat trackWidth;
@property(nonatomic) IBInspectable CGFloat circularSize;

@property(nonatomic) IBInspectable CGFloat progress;
@property(nonatomic) IBInspectable BOOL enableTrackColor;
@end
