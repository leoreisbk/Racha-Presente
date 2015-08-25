//
//  B2WImageOffer.h
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 11/7/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WOffer.h"

typedef NS_ENUM(NSUInteger, B2WOfferPlatform) {
    B2WOfferPlatformSmartphone,
    B2WOfferPlatformTablet,
    B2WOfferPlatformAll
};

@interface B2WImageOffer : B2WOffer

@property (nonatomic) B2WOfferPlatform platform;

@property (nonatomic, readonly) NSURL *smartphoneImageURL;
@property (nonatomic, readonly) NSURL *smartphoneLargeImageURL;
@property (nonatomic, readonly) NSURL *tabletImageURL;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic) CGFloat widthSmartphone;
@property (nonatomic) CGFloat heightSmartphone;

@property (nonatomic) CGFloat widthSmartphoneLarge;
@property (nonatomic) CGFloat heightSmartphoneLarge;

@property (nonatomic) CGFloat widthTablet;
@property (nonatomic) CGFloat heightTablet;

@end
