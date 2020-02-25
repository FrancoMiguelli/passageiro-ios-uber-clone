//
//  RMDateSelectionViewController.h
//  RMDateSelectionViewController
//
//  Created by Admin on 01/09/18.
//  Copyright © 2018 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for RMDateSelectionViewController.
FOUNDATION_EXPORT double RMDateSelectionViewControllerVersionNumber;

//! Project version string for RMDateSelectionViewController.
FOUNDATION_EXPORT const unsigned char RMDateSelectionViewControllerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <RMDateSelectionViewController/PublicHeader.h>

#import "RMActionController.h"
#import "RMAction+Private.h"
#import "RMActionController+Private.h"
#import "RMGroupedAction.h"
#import "RMScrollableGroupedAction.h"
#import "RMImageAction.h"
#import "RMAction.h"
#import "RMImageAction.h"
#import "NSProcessInfo+RMActionController.h"
#import "UIView+RMActionController.h"
#import "RMActionControllerTransition.h"

/**
 *  RMDateSelectionViewController is an iOS control for selecting a date using UIDatePicker in a UIActionSheet like fashon. When a RMDateSelectionViewController is shown the user gets the opportunity to select a date using a UIDatePicker.
 *
 *  RMDateSelectionViewController supports bouncing effects when animating the date selection view controller. In addition, motion effects are supported while showing the date selection view controller. Both effects can be disabled by using the properties called disableBouncingWhenShowing and disableMotionEffects.
 *
 *  On iOS 8 and later Apple opened up their API for blurring the background of UIViews. RMDateSelectionViewController makes use of this API. The type of the blur effect can be changed by using the blurEffectStyle property. If you want to disable the blur effect you can do so by using the disableBlurEffects property.
 *
 *  @warning RMDateSelectionViewController is not designed to be reused. Each time you want to display a RMDateSelectionViewController a new instance should be created. If you want to set a specific date before displaying, you can do so by using the datePicker property.
 */
@interface RMDateSelectionViewController : RMActionController <UIDatePicker *>

/**
 *  The UIDatePicker instance used by RMDateSelectionViewController.
 *
 *  Use this property to access the date picker and to set options like minuteInterval and others.
 */
@property (nonatomic, readonly) UIDatePicker *datePicker;

@end
