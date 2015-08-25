//
//  B2WMarketplaceInformation.m
//  B2WKit
//
//  Created by Mobile on 7/16/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WMarketplaceInformation.h"
#import "B2WProductMarketplacePartner.h"

@implementation B2WMarketplaceInformation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _isMarketplaceExclusive = [dictionary[@"_isExclusiveMarketPlace"] boolValue];
        _smallestPriceOfAllPartners = dictionary[@"_smallestPriceOfAllPartners"];
        _hasPartnersWithStock = [dictionary[@"_hasPartnersWithStock"] boolValue];
        _partners = [B2WProductMarketplacePartner objectsWithDictionaryArray:[dictionary arrayForKey:@"partner"]];
        _sellerIdentifiers = [_partners valueForKeyPath:@"identifier"];
    }
    return self;
}

@end
