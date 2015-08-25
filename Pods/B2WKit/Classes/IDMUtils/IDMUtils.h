//
//  IDMUtils.h
//  B2WKit
//
//  Created by Eduardo Callado on 7/13/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QuartzCore/QuartzCore.h>

@interface UIView (CornerRadius)

- (void)setMaskRoundCorners:(UIRectCorner)corners radius:(CGFloat)radius;

@end

@interface CALayer (CornerShadow)

- (void)applyShadowWithoutPath;
- (void)applyShadow;
- (void)removeShadow;

@end

@interface UIAlertView (ShowAlert)

+ (void)showAlertViewWithTitle:(NSString *)title;
+ (void)showAlertViewWithMessage:(NSString *)message;
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString*)message;

@end

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end

@interface IDMUtils : NSObject

// 

@end
