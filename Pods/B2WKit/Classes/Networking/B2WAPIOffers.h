//
//  B2WAPIOffers.h
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 11/5/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WAPIClient.h"

typedef NS_ENUM(NSUInteger, B2WAPIOffersBrand) {
    B2WAPIOffersBrandACOM,
    B2WAPIOffersBrandSUBA,
    B2WAPIOffersBrandSHOP
};

typedef NS_ENUM(NSUInteger, B2WAPIOffersPlatform) {
    B2WAPIOffersPlatformSmartphone,
    B2WAPIOffersPlatformTablet,
    B2WAPIOffersPlatformAll
};

@interface B2WAPIOffers : NSObject

+ (void)setStaging:(BOOL)staging;
+ (BOOL)isStaging;

//
// TODO:
//       - change this method to requestCampaignOffers
//       - refactor B2WOffer to use a 'B2WListingAttribute' or something
//       - change B2WImageOffer to B2WCampaignOffer
//

/**
 *  Requests all available offers.
 *
 *  @param block      The completion handler block that processes the result.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestOffersForBrand:(B2WAPIOffersBrand)brand
                                        platform:(B2WAPIOffersPlatform)platform
                                           block:(B2WAPICompletionBlock)block;

/**
 *  Requests the currently available daily offers.
 *
 *  @param block      The completion handler block that processes the result.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation *)requestDailyOffersForBrand:(B2WAPIOffersBrand)brand
                                                 block:(B2WAPICompletionBlock)block;

/**
 *  Request for deep link.
 *
 *  @param block      The completion handler block that processes the result.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation *)requestDeepLinkWithURL:(NSString *)urlString
                                             block:(B2WAPICompletionBlock)block;

@end
