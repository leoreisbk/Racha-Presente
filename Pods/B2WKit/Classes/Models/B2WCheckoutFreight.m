//
//  B2WFreight.m
//  B2WKit
//
//  Created by rodrigo.fontes on 30/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WCheckoutFreight.h"

@implementation B2WCheckoutFreight

- (instancetype)initWithCheckoutFreightDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self)
    {
        _contract = dictionary[@"contract"];
        
        _voucher = dictionary[@"voucher"];
        
        _purchaseReason = dictionary[@"purchaseReason"];
        
        if (dictionary[@"scheduledDelivery"] != nil) {
            _scheduledDelivery = [[B2WCheckoutFreightScheduledDelivery alloc] initWithCheckoutFreightScheduledDeliveryDictionary:dictionary[@"scheduledDelivery"]];
        }
    }
    return self;
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (_contract)
    {
        [dict setValue:_contract forKey:@"contract"];
    }
    if (_voucher)
    {
        [dict setValue:_voucher forKey:@"voucher"];
    }
    if (_purchaseReason)
    {
        [dict setValue:_purchaseReason forKey:@"purchaseReason"];
    }
    if (_scheduledDelivery)
    {
        [dict setValue:[_scheduledDelivery dictionaryValue] forKey:@"scheduledDelivery"];
    }
    
    return dict;
}

@end