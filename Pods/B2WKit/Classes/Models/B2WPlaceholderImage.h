//
//  B2WPlaceholderImage.h
//  B2WKit
//
//  Created by Thiago Peres on 17/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface B2WPlaceholderImage : UIImage

/**
 *  @return Returns the placeholder image color.
 */
+ (UIColor *)placeholderColor;

/**
 *  Sets the placeholder image color.
 *
 *  @param color An UIColor
 */
+ (void)setPlaceholderColor:(UIColor *)color;


/**
 *  Builds a 4x4px image filled with the `placeholderColor`. If `placeholderColor` is nil, the image is filled with `[UIColor lightGrayColor]`.
 *
 *  @param color An UIColor to fill the image.
 *
 *  @return An UIImage filled with the given color.
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  @return An UIImage filled with the stored `placeholderColor`. If `placeholderColor` is nil, the image is filled with `[UIColor lightGrayColor]`.
 */
+ (UIImage*)image;

@end
