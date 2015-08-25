//
//  B2WAPIOffers.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 11/5/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WAPIOffers.h"
#import "B2WAPICatalog.h"
#import "B2WOffer.h"
#import "B2WProductOffer.h"
#import "B2WImageOffer.h"
#import "B2WDailyOffer.h"
#import "B2WAPICatalog.h"

NSString *const B2WAPIOffersBaseURLString = @"http://b2w-mobile-api.herokuapp.com/banner/v2";
NSString *const B2WAPIOffersStagingBaseURLString = @"http://b2w-mobile-api-staging.herokuapp.com/banner/v2";

NSString *const B2WAPIDeepLinkBaseURLString = @"http://b2w-mobile-api.herokuapp.com/parse/v2";
NSString *const B2WAPIDeepLinkStagingBaseURLString = @"http://b2w-mobile-api-staging.herokuapp.com/parse/v2";


@interface B2WAPIOffers ()

@property(nonatomic, assign) BOOL staging;

@end

@implementation B2WAPIOffers

+ (B2WAPIOffers *)manager
{
    static B2WAPIOffers *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[B2WAPIOffers alloc] init];
        _sharedInstance.staging = YES;
    });
    return _sharedInstance;
}

static NSString *baseURLString()
{
    return [B2WAPIOffers isStaging] ? B2WAPIOffersStagingBaseURLString : B2WAPIOffersBaseURLString;
}

static NSString *baseDeepLinkURLString()
{
    return [B2WAPIOffers isStaging] ? B2WAPIDeepLinkBaseURLString : B2WAPIDeepLinkStagingBaseURLString;
}

static NSString *brandToString(B2WAPIOffersBrand brand)
{
    if (brand == B2WAPIOffersBrandACOM) { return @"ACOM"; }
    else if (brand == B2WAPIOffersBrandSHOP) { return @"SHOP"; }
    else if (brand == B2WAPIOffersBrandSUBA) { return @"SUBA"; }
    
    return @"ACOM";
}

static NSString *platformToString(B2WAPIOffersPlatform platform)
{
    if (platform == B2WAPIOffersPlatformSmartphone) { return @"smartphone"; }
    else if (platform == B2WAPIOffersPlatformTablet) { return @"tablet"; }
    else if (platform == B2WAPIOffersPlatformAll) { return @"all"; }
    
    return @"all";
}

static B2WProduct *findProductWithIdentifier(NSArray *products, NSString *identifier)
{
    for (B2WProduct *product in products) {
        if ([product.identifier isEqualToString:identifier]) {
            return product;
        }
    }
    return nil;
}

static void setProductsForDailyOffers(NSArray *products, NSArray *dailyOffers)
{
    return;
}

#pragma mark -

+ (void)setStaging:(BOOL)staging
{
    [B2WAPIOffers manager].staging = staging;
}

+ (BOOL)isStaging
{
    return [B2WAPIOffers manager].staging;
}

+ (AFHTTPRequestOperation *)requestOffersForBrand:(B2WAPIOffersBrand)brand
                                         platform:(B2WAPIOffersPlatform)platform
                                            block:(B2WAPICompletionBlock)block
{
    if (!block) { return nil; }
    //NSString *URLString = [NSString stringWithFormat:@"%@?brand=%@&platform=%@", baseURLString(), brandToString(brand), platformToString(platform)];
    NSDictionary *parameters = @{@"brand": brandToString(brand), @"platform": platformToString(platform)};
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:baseURLString()
                                                                                parameters:parameters
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject == nil || ![responseObject isKindOfClass:[NSArray class]])
        {
            block(nil, nil);
            return;
        }
        NSArray *offers = [B2WOffer objectsWithDictionaryArray:responseObject];
        if (block)
        {
            block(offers, nil);
        }
        // TODO: check for errors, etc
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        // Checks if the API returned an error message
        //
        if (error && ![error.domain isEqualToString:NSURLErrorDomain])
        {
            if (operation.responseString && operation.responseString.length > 0)
            {
                if (block)
                {
                    block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                                   code:B2WAPIServiceError
                                               userInfo:@{NSLocalizedDescriptionKey : operation.responseString}]);
                }
            }
        }
        else
        {
            if (block)
            {
                block(nil, error);
            }
            return;
        }
    }];
    
    [op setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [[[B2WAPIClient sharedClient] operationQueue] addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation *)requestDailyOffersForBrand:(B2WAPIOffersBrand)brand block:(B2WAPICompletionBlock)block
{
    if (!block) { return nil; }
    
    NSDictionary *parameters = @{@"brand": brandToString(brand)};
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:([self isStaging]? @"http://b2w-mobile-api-staging.herokuapp.com/offer" : @"http://b2w-mobile-api.herokuapp.com/offer")
                                                                                parameters:parameters
                                                                                     error:nil];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *dailyOffers = [B2WDailyOffer objectsWithDictionaryArray:[responseObject objectForKey:@"results"]];
        if (dailyOffers && dailyOffers.count > 0)
        {
            NSMutableArray *identifiers = [NSMutableArray new];
            for (B2WDailyOffer *offer in dailyOffers) {
                [identifiers addObject:offer.productIdentifier];
            }
            
            [B2WAPICatalog requestProductsWithIdentifiers:identifiers block:^(id object, NSError *error) {
                if (error)
                {
                    NSLog(@"Request Products Error: %@", error);
                    if (block)
                    {
                        block(object, nil);
                    }
                }
                else if (object && [object count] > 0)
                {
                    NSArray *products = object;
                    NSMutableArray *newDailyOffers = [NSMutableArray new];
                    for (B2WDailyOffer *dailyOffer in dailyOffers) {
                        for (B2WProduct *product in products) {
                            if ([product.identifier isEqualToString:dailyOffer.productIdentifier]) {
                                dailyOffer.product = product;
                                [newDailyOffers addObject:dailyOffer];
                                break;
                            }
                        }
                    }
                    NSArray *dailyOffers = [NSArray arrayWithArray:newDailyOffers];
                    if (block)
                    {
                        block(dailyOffers, nil);
                    }
                }
            }];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        // Checks if the API returned an error message
        //
        if (error && ![error.domain isEqualToString:NSURLErrorDomain])
        {
            if (operation.responseString && operation.responseString.length > 0)
            {
                if (block)
                {
                    block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                                   code:B2WAPIServiceError
                                               userInfo:@{NSLocalizedDescriptionKey : operation.responseString}]);
                }
            }
        }
        else
        {
            if (block)
            {
                block(nil, error);
            }
            return;
        }
    }];
    
    [op setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [[[B2WAPIClient sharedClient] operationQueue] addOperation:op];
    
    return nil;
}

+ (AFHTTPRequestOperation *)requestDeepLinkWithURL:(NSString *)urlString block:(B2WAPICompletionBlock)block
{
    if (!block) { return nil; }
    
    urlString = [NSString stringWithFormat:@"%@?url=%@", baseDeepLinkURLString(), urlString];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:urlString
                                                                                parameters:nil
                                                                                     error:nil];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject)
        {
            NSMutableDictionary *dict = @{@"type": @"product",
                                          @"shortDescription": @"Promoção",
                                          @"listingAttributes": responseObject}.mutableCopy;
            
            B2WOffer *offer = [[B2WOffer alloc] initWithDictionary:dict];
            if (block)
            {
                block(offer, nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        // Checks if the API returned an error message
        //
        if (error && ![error.domain isEqualToString:NSURLErrorDomain])
        {
            if (operation.responseString && operation.responseString.length > 0)
            {
                if (block)
                {
                    block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                                   code:B2WAPIServiceError
                                               userInfo:@{NSLocalizedDescriptionKey : operation.responseString}]);
                }
            }
        }
        else
        {
            if (block)
            {
                block(nil, error);
            }
            return;
        }
    }];
    
    [op setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [[[B2WAPIClient sharedClient] operationQueue] addOperation:op];
    
    return nil;
}

@end