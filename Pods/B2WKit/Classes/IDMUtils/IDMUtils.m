//
//  IDMUtils.m
//  B2WKit
//
//  Created by Eduardo Callado on 7/13/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "IDMUtils.h"

@implementation UIView (CornerRadius)

- (void)setMaskRoundCorners:(UIRectCorner)corners radius:(CGFloat)radius
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    [shapeLayer setPath:bezierPath.CGPath];
    
    self.layer.mask = shapeLayer;
}

@end


@implementation CALayer (CornerShadow)

- (void)applyShadowWithoutPath
{
    self.shadowOffset = CGSizeMake(0, 0.5);
    self.shadowRadius = 1.5;
    self.shadowOpacity = 0.2;
    self.shadowColor = [UIColor colorWithWhite:0.2 alpha:1.].CGColor;
    
    self.masksToBounds = NO;
    self.cornerRadius = 2.0;
    
    self.shouldRasterize = YES;
    self.rasterizationScale = [UIScreen mainScreen].scale;
    
    self.shadowPath = nil;
}

- (void)applyShadow
{
    [self applyShadowWithoutPath];
    self.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)removeShadow
{
    self.shadowOffset = CGSizeZero;
    self.shadowPath = nil;
    
    self.shadowRadius = 0.;
}

@end

@implementation UIAlertView (ShowAlert)

+ (void)showAlertViewWithTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

+ (void)showAlertViewWithMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString*)message
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0, 0, 1, 1);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

@end


@implementation IDMUtils

@end
