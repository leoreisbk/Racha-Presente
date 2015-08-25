//
//  B2WProduct.m
//  B2Wkit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WProduct.h"

// Models
#import "B2WImage.h"
#import "B2WSpecification.h"
#import "B2WSKUInformation.h"
#import "B2WCrossSellItem.h"
#import "B2WWishlistManager.h"
#import "B2WWishList.h"
#import "B2WExtendedWarranty.h"
#import "B2WMarketplaceInformation.h"
#import "B2WKitUtils.h"
#import "B2WPaymentOption.h"

// Categories
#import "NSDictionary+B2WKit.h"

// Controllers
#import <HCYoutubeParser/HCYoutubeParser.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "B2WPromoBadgeManager.h"

@implementation NSDictionary (B2WProductExtensions)

- (B2WProductDictionaryKind)productKind
{
    if ([self containsObjectForKey:@"brand_installment_value"] ||
        [self containsObjectForKey:@"sales_price"])
    {
        return B2WProductDictionaryKindSearch;
    }
    return B2WProductDictionaryKindCatalog;
}

@end

@interface B2WProduct ()

@property (nonatomic, strong) NSDictionary *_imagesSKU;

@end

@implementation B2WProduct

+ (NSNumberFormatter*)numberFormatter
{
    static NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"pt-BR"];
    });
    
    return formatter;
}

- (NSString *)defaultPartnerForBrand:(NSString *)brand
{
    if (self.partnerId && self.partnerId.length > 0)
    {
        return self.partnerName;
    }
    return brand;
}

- (NSArray *)allProductMarketplacePartners
{
    NSMutableArray *allProductMarketplacePartners = [NSMutableArray new];
    [allProductMarketplacePartners addObject:[self featuredProductPartner]];
    if (self.marketPlaceInformation) {
        [allProductMarketplacePartners addObjectsFromArray:self.marketPlaceInformation.partners];
    }
    return allProductMarketplacePartners;
}

- (B2WProductMarketplacePartner *)featuredProductPartner
{
    NSString *partnerId = self.partnerId == nil || [self.partnerId isEqualToString:@""] ? @"" : self.partnerId;
    NSString *partnerName = self.partnerName == nil || [self.partnerName isEqualToString:@""] ? [B2WKitUtils mainAppDisplayName] : self.partnerName;
    
    return [[B2WProductMarketplacePartner alloc] initWithIdentifier:partnerId hasStorePickup:@"false" name:partnerName salesPrice:self.price installment:self.installment];
}

- (instancetype)_initWithCatalogDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self)
    {
        _kind                           = B2WProductDictionaryKindCatalog;
        _identifier                     = dictionary[@"_prodId"];
		
        _name                           = dictionary[@"_name"];
        _supplier                       = dictionary[@"_supplier"];
        
        _price                          = dictionary[@"_price"];
        _priceFrom                      = dictionary[@"_priceFrom"];
        _installment                    = dictionary[@"_installment"];
		
		_brandDiscountedInstallment     = [dictionary[@"_brandDiscountedInstallment"] isEqualToString:@""] ? nil : dictionary[@"_brandDiscountedInstallment"];

		_brandInstallment               = dictionary[@"_brand_installment"];
		
        _videoURL                       = (dictionary[@"_video"] == nil || [dictionary[@"_video"] isEqualToString:@""]) ? nil : [NSURL URLWithString:dictionary[@"_video"]];
        
        _URL                            = [NSURL URLWithString:dictionary[@"_url"]];
        _inStock                        = [dictionary[@"_stock"] isEqualToString:@"true"] ? YES : NO;
        _isWhiteLine                    = [dictionary[@"_isWhiteLine"] isEqualToString:@"true"] ? YES : NO;
        
        _thumbnailImageURL              = [NSURL URLWithString:dictionary[@"_mqImage"]];
        _billetPrice                    = dictionary[@"_billetPrice"];
        _billetDiscountPercent          = dictionary[@"_billetDiscountPercent"];
        
        _reviewsCount                   = [dictionary[@"_numReviews"] integerValue];
        _reviewsRatingAverage           = [dictionary[@"_rating"] floatValue];
        _reviewsRatingAveragePercentage = [dictionary[@"_ratingPercent"] floatValue];
        
        _partnerName                    = dictionary[@"_partnerName"];
        
        NSString *partnerID = dictionary[@"_partnerId"]; // Fix for marketplace brand
        _partnerId = partnerID == nil || partnerID.length < 10 ? @"" : partnerID;
		
		if ([dictionary containsObjectForKey:@"_brandPrice"])
		{
			_brandPrice = dictionary[@"_brandPrice"];
		}
		
        if ([dictionary containsObjectForKey:@"_hasPromptDelivery"])
        {
            _hasPromptDelivery = [dictionary[@"_hasPromptDelivery"] isEqualToString:@"true"] ? YES : NO;
        }
        
        if ([dictionary containsObjectForKey:@"_billetDiscountImage"])
        {
            if ([dictionary[@"_billetDiscountImage"] length] > 0)
            {
                _billetDiscountImageURL = [NSURL URLWithString:dictionary[@"_billetDiscountImage"]];
            }
        }
        
        if ([dictionary containsObjectForKey:@"_badgeImage"])
        {
            if ([dictionary[@"_badgeImage"] length] > 0)
            {
                _badgeImageURL = [NSURL URLWithString:dictionary[@"_badgeImage"]];
                
                if (! [B2WPromoBadgeManager sharedManager].promoBadgeURL)
                {
                    [B2WPromoBadgeManager sharedManager].promoBadgeURL = _badgeImageURL.absoluteString;
                    [[B2WPromoBadgeManager sharedManager] requestPromoBadgeImage];
                }
                else
                {
                    [B2WPromoBadgeManager sharedManager].promoBadgeURL = _badgeImageURL.absoluteString;
                }
            }
        }
        
        if ([dictionary containsObjectForKey:@"warranties"])
        {
            _extendedWarranties = [B2WExtendedWarranty objectsWithDictionaryArray:[dictionary[@"warranties"] arrayForKey:@"warranty"]];
        }
        
        if ([dictionary containsObjectForKey:@"marketplace"])
        {
            _marketPlaceInformation = [[B2WMarketplaceInformation alloc] initWithDictionary:dictionary[@"marketplace"]];
        }
        
        if ([dictionary containsObjectForKey:@"paymentOptions"])
        {
            _paymentOptions = [B2WPaymentOption objectsWithDictionaryArray:[dictionary[@"paymentOptions"] arrayForKey:@"paymentOption"]];
        }
        
        NSMutableArray *specs = [NSMutableArray arrayWithArray:[dictionary arrayForKey:@"specTecs"]];
        
        //
        // Gets the product description
        //
        id description;
        
        for (id specObj in specs)
        {
            if ([specObj[@"_title"] isEqualToString:@"Descrição"])
            {
                description = specObj;
            }
        }
        
        if (description)
        {
            _productDescription = description[@"specTec"][@"_value"];
            [specs removeObject:description];
        }
        // END: Gets the product description
		
		//
		// Remove "Grupo SKU" speficiation
		//
		id skus;
		
		for (id specObj in specs)
		{
			if ([specObj[@"_title"] isEqualToString:@"Grupo SKU"])
			{
				skus = specObj;
			}
		}
		
		if (skus)
		{
			[specs removeObject:skus];
		}
		// END: Remove "Grupo SKU"
		
        _specifications = [B2WSpecification objectsWithDictionaryArray:specs];
        
        //
        // Get product images
        //
        _images = [B2WImage objectsWithDictionaryArray:[dictionary[@"images"] arrayForKey:@"thumbimage"]];
        // END: Get product images
        
        //
        // Add thumbnail image in array if none is found
        //
        if (_images.count == 0 &&
            self.thumbnailImageURL != nil)
        {
            B2WImage *image = [[B2WImage alloc] initWithDictionary:@{@"_url": self.thumbnailImageURL.absoluteString}];
            _images         = @[image];
        }
        
        if ([dictionary containsObjectForKey:@"skuInfo"])
        {
            _isFashion = YES;
            _skus      = [B2WSKUInformation objectsWithDictionaryArray:[dictionary[@"skuInfo"] arrayForKey:@"skudiffs"]];
        }
        else
        {
            _isFashion = NO;
            _skus      = [B2WSKUInformation objectsWithDictionaryArray:[dictionary[@"skus"] arrayForKey:@"sku"]];
        }
		
        if ([dictionary containsObjectForKey:@"crossSell"])
        {
            _crossSellItems = [B2WCrossSellItem objectsWithDictionaryArray:[dictionary[@"crossSell"] arrayForKey:@"crossSellItem"]];
        }
    }
    return self;
}

- (instancetype)_initWithSearchDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self)
    {
        _kind                           = B2WProductDictionaryKindSearch;
        _identifier                     = [dictionary[@"product_id"] stringValue];
        _name                           = dictionary[@"name"];
        _URL                            = [NSURL URLWithString:dictionary[@"url"]];
        _thumbnailImageURL              = [NSURL URLWithString:dictionary[@"image"]];
        _priceFrom                      = dictionary[@"default_price"] != [NSNull null] ? dictionary[@"default_price"] : @"";
        _price                          = dictionary[@"sales_price"] != [NSNull null] ? dictionary[@"sales_price"] : @"";
        _inStock                        = [dictionary[@"stock"] boolValue];
        if (dictionary[@"installment_total"] != [NSNull null] && dictionary[@"installment_value"] != [NSNull null]) {
            _installment                = [NSString stringWithFormat:@"%@x de %@", dictionary[@"installment_total"], dictionary[@"installment_value"]];
        } else {
            _installment = @"";
        }
        _reviewsCount                   = dictionary[@"reviews_count"] != [NSNull null] ? [dictionary[@"reviews_count"] integerValue] : 0;
        _reviewsRatingAverage           = dictionary[@"rating_overall_average"] != [NSNull null] ? [dictionary[@"rating_overall_average"] floatValue] : 0.0;
        _reviewsRatingAveragePercentage = dictionary[@"rating_average_percent"] != [NSNull null] ? [dictionary[@"rating_average_percent"] floatValue] : 0.0;
        
        if ([dictionary containsObjectForKey:@"blacknight"])
        {
            if (dictionary[@"blacknight"] != [NSNull null])
            {
                if ([dictionary[@"blacknight"] length] > 0)
                {
                    _badgeImageURL = [NSURL URLWithString:dictionary[@"blacknight"]];
                }
            }
        }
    }
    return self;
}

- (NSURL *)videoThumbnailImageURL
{
    return [HCYoutubeParser thumbnailUrlForYoutubeURL:self.videoURL thumbnailSize:YouTubeThumbnailDefaultHighQuality];
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if (dictionary.productKind == B2WProductDictionaryKindCatalog)
    {
        return [self _initWithCatalogDictionary:dictionary];
    }
    else if (dictionary.productKind == B2WProductDictionaryKindSearch)
    {
        return [self _initWithSearchDictionary:dictionary];
    }
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@", self.identifier, self.name];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@ - %@", self.identifier, self.name];
}

- (NSUInteger)hash
{
    return 0;
}

- (BOOL)isEqual:(B2WProduct*)product
{
    if (! [product isKindOfClass:self.class]) return NO;
    
    return [self.identifier isEqualToString:product.identifier];
}

#pragma mark - Lazy Getters

- (NSNumber *)priceFromNumber
{
    return [[B2WProduct numberFormatter] numberFromString:[self.priceFrom stringByReplacingOccurrencesOfString:@" " withString:@""]];
}

- (NSNumber *)priceNumber
{
    return [[B2WProduct numberFormatter] numberFromString:[self.price stringByReplacingOccurrencesOfString:@" " withString:@""]];
}

- (NSNumber *)billetPriceNumber
{
    return [[B2WProduct numberFormatter] numberFromString:[self.billetPrice stringByReplacingOccurrencesOfString:@" " withString:@""]];
}

- (NSDictionary *)imagesSKU
{
    if (self._imagesSKU == nil)
    {
        NSMutableDictionary *dict = @{}.mutableCopy;
        for (B2WImage *image in self.images)
        {
            if (image.SKUIdentifier != nil)
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SKUIdentifier == %@", image.SKUIdentifier];
                NSArray *subarray      = [self.images filteredArrayUsingPredicate:predicate];
                
                dict[image.SKUIdentifier] = subarray;
            }
        }
        
        self._imagesSKU = dict;
    }
    
    return self._imagesSKU;
}

- (BOOL)isFavorite
{
    B2WWishList *wishlist = [B2WWishlistManager sharedManager].defaultWishlist;
    return ([wishlist itemWithIdentifier:self.identifier] != nil);
}

@end