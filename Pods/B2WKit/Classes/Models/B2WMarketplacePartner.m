//
//  B2WMarketplacePartner.m
//  B2WKit
//
//  Created by Flávio Caetano on 7/31/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WMarketplacePartner.h"

@implementation B2WMarketplacePartner

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue
{
    if (self = [self init])
    {
        _name = dictionaryValue[@"_name"];
        _CNPJ = dictionaryValue[@"_cnpj"];
        _aboutStore = dictionaryValue[@"_aboutStore"];
        _deliveryPolicy = dictionaryValue[@"_deliveryPolicy"];
        _returnPolicy = dictionaryValue[@"_returnPolicy"];
        _address = dictionaryValue[@"_address"];
        
        NSString *logoURLString = dictionaryValue[@"_logo"];
        if (logoURLString)
        {
            _logoURL = [NSURL URLWithString:logoURLString];
        }
    }
    
    return self;
}

@end
