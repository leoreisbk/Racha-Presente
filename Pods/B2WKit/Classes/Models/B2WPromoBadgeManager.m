//
//  B2WPromoBadgeManager.m
//  B2WKit
//
//  Created by rodrigo.fontes on 11/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WPromoBadgeManager.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

CGFloat const ACOMPromoBadgeImageSmallSize  = 43.f;
CGFloat const ACOMPromoBadgeImageMediumSize = 53.f;
CGFloat const ACOMPromoBadgeImageNormalSize = 88.f;

CGFloat const SUBAPromoBadgeImageSmallSize  = 40.f;
CGFloat const SUBAPromoBadgeImageMediumSize = 60.f;
CGFloat const SUBAPromoBadgeImageNormalSize = 80.f;

CGFloat const SHOPPromoBadgeImageSmallSize  = 54.f;
CGFloat const SHOPPromoBadgeImageMediumSize = 64.f;
CGFloat const SHOPPromoBadgeImageNormalSize = 74.f;

@interface B2WPromoBadgeManager ()

@end

@implementation B2WPromoBadgeManager

#pragma mark - Shared Manager

+ (B2WPromoBadgeManager *)sharedManager
{
    static dispatch_once_t predManager;
    static B2WPromoBadgeManager *sharedManager = nil;
    dispatch_once(&predManager, ^{
        sharedManager = [B2WPromoBadgeManager new];
    });
    return sharedManager;
}

- (void)requestPromoBadgeImage
{
    if (self.promoBadgeURL)
    {
		[self addAppSuffixStringToPromoBadgeIfNeeded];
		
		NSURL *promoBadgeURLString = [NSURL URLWithString:self.promoBadgeURL];
        
        if (!self.promoBadgeImageView)
        {
            self.promoBadgeImageView = [UIImageView new];
        }
		
        __weak __block UIImageView *weakSelf = self.promoBadgeImageView;
        [weakSelf setImageWithURLRequest:[NSURLRequest requestWithURL:promoBadgeURLString]
                        placeholderImage:nil
                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                     weakSelf.image = image;
                                     [[B2WPromoBadgeManager sharedManager] createImagesFromImageView:weakSelf];
                                     
                                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                     NSLog(@"Get promo badge error: %@", error);
									 
                                     if (error.code == -1011)
                                     {
                                         weakSelf.image = nil;
                                     }
                                 }];
    }
	else
	{
		self.promoBadgeImageView = nil;
	}
}

- (void)addAppSuffixStringToPromoBadgeIfNeeded
{
	NSString *suffix = @"-app";
	
    if ([self.promoBadgeURL rangeOfString:suffix].location == NSNotFound)
    {
        self.promoBadgeURL = [self.promoBadgeURL stringByReplacingOccurrencesOfString:@".png"
																		 withString:[NSString stringWithFormat:@"%@.png", suffix]];
		
		self.promoBadgeURL = [self.promoBadgeURL stringByReplacingOccurrencesOfString:@".gif"
																		 withString:[NSString stringWithFormat:@"%@.gif", suffix]];
		
		self.promoBadgeURL = [self.promoBadgeURL stringByReplacingOccurrencesOfString:@".jpg"
																		 withString:[NSString stringWithFormat:@"%@.jpg", suffix]];
		
		self.promoBadgeURL = [self.promoBadgeURL stringByReplacingOccurrencesOfString:@".jpeg"
																		 withString:[NSString stringWithFormat:@"%@.jpeg", suffix]];
    }
}

- (void)createImagesFromImageView:(UIImageView *)imageView
{
    NSString *brand = [B2WPromoBadgeManager sharedManager].brand;
    
    if ([brand isEqualToString:@"ACOM"])
    {
        [B2WPromoBadgeManager sharedManager].smallImage  = [self scaleImage:imageView.image forSize:CGSizeMake(ACOMPromoBadgeImageSmallSize, ACOMPromoBadgeImageSmallSize)];
        [B2WPromoBadgeManager sharedManager].mediumImage = [self scaleImage:imageView.image forSize:CGSizeMake(ACOMPromoBadgeImageMediumSize, ACOMPromoBadgeImageMediumSize)];
        [B2WPromoBadgeManager sharedManager].normalImage = [self scaleImage:imageView.image forSize:CGSizeMake(ACOMPromoBadgeImageNormalSize, ACOMPromoBadgeImageNormalSize)];
        [B2WPromoBadgeManager sharedManager].largeImage  = [imageView.image copy];
    }
    else if ([brand isEqualToString:@"SUBA"])
    {
        [B2WPromoBadgeManager sharedManager].smallImage  = [self scaleImage:imageView.image forSize:CGSizeMake(SUBAPromoBadgeImageSmallSize, SUBAPromoBadgeImageSmallSize)];
        [B2WPromoBadgeManager sharedManager].mediumImage = [self scaleImage:imageView.image forSize:CGSizeMake(SUBAPromoBadgeImageMediumSize, SUBAPromoBadgeImageMediumSize)];
        [B2WPromoBadgeManager sharedManager].normalImage = [self scaleImage:imageView.image forSize:CGSizeMake(SUBAPromoBadgeImageNormalSize, SUBAPromoBadgeImageNormalSize)];
        [B2WPromoBadgeManager sharedManager].largeImage  = [imageView.image copy];
    }
	else if ([brand isEqualToString:@"SHOP"])
    {
        [B2WPromoBadgeManager sharedManager].smallImage  = [self scaleImage:imageView.image forSize:CGSizeMake(SHOPPromoBadgeImageSmallSize, SHOPPromoBadgeImageSmallSize)];
        [B2WPromoBadgeManager sharedManager].mediumImage = [self scaleImage:imageView.image forSize:CGSizeMake(SHOPPromoBadgeImageMediumSize, SHOPPromoBadgeImageMediumSize)];
        [B2WPromoBadgeManager sharedManager].normalImage = [self scaleImage:imageView.image forSize:CGSizeMake(SHOPPromoBadgeImageNormalSize, SHOPPromoBadgeImageNormalSize)];
        [B2WPromoBadgeManager sharedManager].largeImage  = [imageView.image copy];
    }
}

- (UIImage *)imageForSize:(CGSize)size
{
    NSString *brand = [B2WPromoBadgeManager sharedManager].brand;
    
    if ([brand isEqualToString:@"ACOM"])
    {
        if (size.width == ACOMPromoBadgeImageSmallSize  && size.height == ACOMPromoBadgeImageSmallSize)
			return [B2WPromoBadgeManager sharedManager].smallImage;
        if (size.width == ACOMPromoBadgeImageMediumSize  && size.height == ACOMPromoBadgeImageMediumSize)
			return [B2WPromoBadgeManager sharedManager].mediumImage;
        if (size.width == ACOMPromoBadgeImageNormalSize && size.height == ACOMPromoBadgeImageNormalSize)
			return [B2WPromoBadgeManager sharedManager].normalImage;
    }
    else if ([brand isEqualToString:@"SUBA"])
    {
        if (size.width == SUBAPromoBadgeImageSmallSize  && size.height == SUBAPromoBadgeImageSmallSize)
			return [B2WPromoBadgeManager sharedManager].smallImage;
        if (size.width == SUBAPromoBadgeImageMediumSize  && size.height == SUBAPromoBadgeImageMediumSize)
			return [B2WPromoBadgeManager sharedManager].mediumImage;
        if (size.width == SUBAPromoBadgeImageNormalSize && size.height == SUBAPromoBadgeImageNormalSize)
			return [B2WPromoBadgeManager sharedManager].normalImage;
    }
    else if ([brand isEqualToString:@"SHOP"])
    {
        if (size.width == SHOPPromoBadgeImageSmallSize  && size.height == SHOPPromoBadgeImageSmallSize)
			return [B2WPromoBadgeManager sharedManager].smallImage;
        if (size.width == SHOPPromoBadgeImageMediumSize  && size.height == SHOPPromoBadgeImageMediumSize)
			return [B2WPromoBadgeManager sharedManager].mediumImage;
        if (size.width == SHOPPromoBadgeImageNormalSize && size.height == SHOPPromoBadgeImageNormalSize)
			return [B2WPromoBadgeManager sharedManager].normalImage;
    }
	
    return nil;
}

- (UIImage *)scaleImage:(UIImage *)image forSize:(CGSize)size
{
    UIGraphicsBeginImageContext(CGSizeMake(size.width*2, size.height*2));
    [image drawInRect:CGRectMake(0, 0, size.width*2, size.height*2)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image copy];
}

@end