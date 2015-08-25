//
//  B2WProduct.h
//  B2Wkit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WProductMarketplacePartner.h"
#import "B2WObject.h"

@class B2WMarketplaceInformation;

@interface NSDictionary (B2WProductExtensions)

typedef NS_ENUM(NSUInteger, B2WProductDictionaryKind) {
    B2WProductDictionaryKindCatalog,
    B2WProductDictionaryKindSearch,
};

@property (nonatomic, readonly) B2WProductDictionaryKind productKind;

@end

@interface B2WProduct : B2WObject

/**
 *  The product's catalog identifier.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 *  The product's name.
 */
@property (nonatomic, readonly) NSString *name;

/**
 *  The product's description HTML string.
 */
@property (nonatomic, readonly) NSString *productDescription;

/**
 *  The product's manufacturer name.
 */
@property (nonatomic, readonly) NSString *supplier;

/**
 *  A formatted string containing the previous price.
 */
@property (nonatomic, readonly) NSString *priceFrom;

/**
 *  The product's previous price as NSNumber.
 */
@property (nonatomic, readonly) NSNumber *priceFromNumber;

/**
 *  A formatted string containing the current price.
 */
@property (nonatomic, readonly) NSString *price;

/**
 *  The product's price as NSNumber.
 */
@property (nonatomic, readonly) NSNumber *priceNumber;

/**
 *  A formatted string containing the billet price.
 */
@property (nonatomic, readonly) NSString *billetPrice;

/**
 *  The product's billet price as NSNumber.
 */
@property (nonatomic, readonly) NSNumber *billetPriceNumber;

/**
 *  A formatted string containing the discount percentage.
 */
@property (nonatomic, readonly) NSString *billetDiscountPercent;

/**
 *  The URL for the billet dicount image.
 */
@property (nonatomic, readonly) NSURL *billetDiscountImageURL;

/**
 *  A formatted string containing the installment options.
 */
@property (nonatomic, readonly) NSString *installment;

/**
 *  A string containing the installment options when using
 *  the brand's credit card.
 */
@property (nonatomic, readonly) NSString *brandInstallment;

@property (nonatomic, readonly) NSString *brandDiscountedInstallment;

/**
 *  A string containing the total price when using
 *  the brand's credit card.
 */
@property (nonatomic, readonly) NSString *brandPrice;

/**
 *  Indicates wheter the product is currently in stock.
 */
@property (nonatomic, readonly, getter = isInStock) BOOL inStock;

/**
 *  The product's URL on the full website.
 */
@property (nonatomic, readonly) NSURL *URL;

/**
 *  Indicates wheter the product is white line or not. 
 *  "White line" is an internal company definition for products
 *  like refrigerators, air conditioners, ovens, etc.
 */
@property (nonatomic, readonly) BOOL isWhiteLine;

/**
 *  Indicates wheter the receiver is a fashion product.
 */
@property (nonatomic, readonly) BOOL isFashion;

/**
 *  The product's thumbnail image URL.
 */
@property (nonatomic, readonly) NSURL *thumbnailImageURL;

/**
 *  An array containing B2WImage objects
 */
@property (nonatomic, readonly) NSArray *images;

/**
 *  An array containing extended warranty information, represented as B2WExtendedWarranty objects.
 */
@property (nonatomic, readonly) NSArray *extendedWarranties;

/**
 *  An array containing payment option information, represented as B2WPaymentOption objects.
 */
@property (nonatomic, readonly) NSArray *paymentOptions;

/**
 *  An array containing B2WImage objects related to any SKUs.
 */
@property (nonatomic, readonly, getter = imagesSKU) NSDictionary *imagesSKU;

@property (nonatomic, readonly) B2WMarketplaceInformation *marketPlaceInformation;

/**
 *  An array containing B2WSKUInformation objects.
 */
@property (nonatomic, readonly) NSArray *skus;

/**
 *  An array containing B2WSpecification objects.
 */
@property (nonatomic, readonly) NSArray *specifications;

/**
 *  The product's number of reviews.
 */
@property (nonatomic, readonly) NSInteger reviewsCount;

/**
 *  The product's average rating.
 */
@property (nonatomic, readonly) CGFloat reviewsRatingAverage;

/**
 *  The product's average rating percentage.
 */
@property (nonatomic, readonly) CGFloat reviewsRatingAveragePercentage;

/**
 *  The product's video URL (if any).
 */
@property (nonatomic, readonly) NSURL *videoURL;

/**
 *  The URL for the video's thumbnail image
 */
@property (nonatomic, readonly) NSURL *videoThumbnailImageURL;

/**
 *  An array containing B2WCrossSellItem objects.
 */
@property (nonatomic, readonly) NSArray *crossSellItems;

/**
 *  Wether or not this product is an user's favorite. Lazy property.
 */
@property (nonatomic, readwrite) BOOL isFavorite;

/**
 *  The URL for the product's badge image URL. Used in big sales event like Black Friday.
 */
@property (nonatomic, readonly) NSURL *badgeImageURL;

/**
 *  A boolean indicating whether the product is eligibe for prompt delivery.
 */
@property (nonatomic, readonly) BOOL hasPromptDelivery;

/**
 The user info dictionary for the receiver.
 */
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, assign) B2WProductDictionaryKind kind;

/**
 *  The product's marketplace partner name.
 */
@property (nonatomic, readonly) NSString *partnerName;

/**
 *  The product's marketplace partner identifier.
 */
@property (nonatomic, readonly) NSString *partnerId;

+ (NSNumberFormatter*)numberFormatter;

- (NSArray *)allProductMarketplacePartners;
- (B2WProductMarketplacePartner *)featuredProductPartner;

@end
