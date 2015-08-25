//
//  B2WProductMarketplacePartner.m
//  B2WKit
//
//  Created by Mobile on 7/16/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WProductMarketplacePartner.h"

@implementation B2WProductMarketplacePartner

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        NSString *partnerID = dictionary[@"_id"]; // Fix for marketplace brand
        _identifier = partnerID == nil || partnerID.length < 10 ? @"" : partnerID;
        _hasStorePickup = [dictionary[@"_hasPickupStore"] boolValue];
        _name = dictionary[@"_partnerName"];
        _price = dictionary[@"_salesPrice"];
        if ([dictionary containsObjectForKey:@"installment"])
        {
            NSArray *dictionaryInstallments = [dictionary arrayForKey:@"installment"];
            _installments = [dictionaryInstallments valueForKey:@"_value"];
        }
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                    hasStorePickup:(NSString *)hasPickupStore
                              name:(NSString *)partnerName
                        salesPrice:(NSString *)salesPrice
                       installment:(NSString *)installment

{
    self = [super init];
    if (self)
    {
        _identifier = identifier;
        _hasStorePickup = [hasPickupStore boolValue];
        _name = partnerName;
        _price = salesPrice;
        _installments = installment ? @[installment] : @[];
        
        /*if ([dictionary containsObjectForKey:@"installment"])
        {
            NSArray *dictionaryInstallments = [dictionary arrayForKey:@"installment"];
            _installments = [dictionaryInstallments valueForKey:@"_value"];
        }*/
    }
    return self;
}

@end
