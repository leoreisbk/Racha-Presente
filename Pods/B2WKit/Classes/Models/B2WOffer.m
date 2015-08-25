//
//  B2WOffer.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 11/6/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WOffer.h"
#import "B2WImageOffer.h"
#import "B2WProductOffer.h"

@implementation B2WOffer

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    NSArray *expectedKeys = @[@"type", @"listingAttributes"];
    
    for (NSString *key in expectedKeys) {
        if ( ! [dictionary containsObjectForKey:key]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:[NSString stringWithFormat:@"Missing key '%@' in API response JSON", key] userInfo:nil];
        }
    }
    
    NSString *type = dictionary[@"type"];
    
    if ([type isEqualToString:@"image"]) {
        self = [[B2WImageOffer alloc] initWithDictionary:dictionary];
    } else if ([type isEqualToString:@"product"]) {
        self = [[B2WProductOffer alloc] initWithDictionary:dictionary];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Unsupported offer type: %@", type] userInfo:nil];
    }
    
    _shortDescription = [dictionary objectForKey:@"shortDescription"];
    _listingAttributes = [[B2WListingAttributes alloc] initWithDictionary:dictionary[@"listingAttributes"]];
    
    return self;
}

@end
