//
//  B2WDailyOffer.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 12/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WDailyOffer.h"

@implementation B2WDailyOffer

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        for (NSString *key in @[@"id", @"url", @"listingAttributes"]) {
            if ( ! [dictionary containsObjectForKey:key]) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException
                                               reason:[NSString stringWithFormat:@"Missing key '%@' in B2WDailyOffer dictionary", key] userInfo:dictionary];
            }
        }
        
        _listingAttributes = [[B2WListingAttributes alloc] initWithDictionary:dictionary[@"listingAttributes"]];
        _URL = [NSURL URLWithString:dictionary[@"url"]];
        _productIdentifier = dictionary[@"id"];
    }
    return self;
}

- (NSString *)description
{
    return [@[
        @"-------------------",
        [NSString stringWithFormat:@"- id: %@", self.productIdentifier],
        [NSString stringWithFormat:@"- product: [%@] %@", self.product.price, self.product.name],
        [NSString stringWithFormat:@"- url: %@", self.URL],
        [NSString stringWithFormat:@"- listing attributes: %@", self.listingAttributes],
        @"-------------------"
    ] componentsJoinedByString:@"\n"];
}

@end
