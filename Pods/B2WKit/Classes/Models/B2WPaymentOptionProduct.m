//
//  B2WPaymentOptionProduct.m
//  B2WKit
//
//  Created by rodrigo.fontes on 31/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WPaymentOptionProduct.h"

@implementation B2WPaymentOptionProduct

#pragma mark - Initialization

- (instancetype)initWithPaymentOptionProductDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self)
    {
        _sku = dictionary[@"sku"];
        _salesPrice = dictionary[@"salesPrice"];
    }
    return self;
}

- (NSDictionary *)dictionaryValue
{
    return [[NSMutableDictionary alloc] initWithDictionary:@{ @"sku"          : _sku,
                                                              @"salesPrice"   : _salesPrice }];
}

@end