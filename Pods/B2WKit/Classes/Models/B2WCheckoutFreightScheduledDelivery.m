//
//  B2WCheckoutFreightScheduledDelivery.m
//  B2WKit
//
//  Created by rodrigo.fontes on 30/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WCheckoutFreightScheduledDelivery.h"

@implementation B2WCheckoutFreightScheduledDelivery

- (instancetype)initWithCheckoutFreightScheduledDeliveryDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self)
    {
        _date = dictionary[@"date"];
        
        _shift = dictionary[@"_date"];
    }
    return self;
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (_date)
    {
        [dict setValue:_date forKey:@"date"];
    }
    if (_shift)
    {
        [dict setValue:_shift forKey:@"shift"];
    }
    
    return dict;
}

@end
