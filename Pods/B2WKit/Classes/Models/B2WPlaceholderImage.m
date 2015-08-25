//
//  B2WPlaceholderImage.m
//  B2WKit
//
//  Created by Thiago Peres on 17/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WPlaceholderImage.h"

static UIColor *_placeholderColor = nil;

@implementation B2WPlaceholderImage

+ (NSCache*)cache
{
    static NSCache *cache;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    
    return cache;
}

+ (void)setPlaceholderColor:(UIColor *)color
{
    _placeholderColor = color;
}

+ (UIColor*)placeholderColor
{
    return _placeholderColor;
}

+ (UIImage*)imageWithColor:(UIColor*)color
{
    UIImage *cachedImage = [[B2WPlaceholderImage cache] objectForKey:color];
    
    if (cachedImage)
    {
        return cachedImage;
    }
    
    //
    // This creates an image without an alpha channel
    // which reduces blending
    //
    CGRect rect          = CGRectMake(0, 0, 4, 4);
    CGColorSpaceRef cs   = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, 4, 4, 8, 4 * 4,
                                                 cs, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image      = [[UIImage alloc] initWithCGImage:imageRef];
    
    CGColorSpaceRelease(cs);
    CGImageRelease(imageRef);
    CGContextRelease(context);
    
    UIImage *resImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)
                                              resizingMode:UIImageResizingModeStretch];
    
    [[B2WPlaceholderImage cache] setObject:resImage forKey:color];
    
    return resImage;
}

+ (UIImage*)image
{
    return [B2WPlaceholderImage imageWithColor:_placeholderColor ? _placeholderColor : [UIColor colorWithRed:246./255 green:246./255 blue:246./255 alpha:1]];
}

@end
