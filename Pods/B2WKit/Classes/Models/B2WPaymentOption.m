//
//  B2WPaymentOption.m
//  B2WKit
//
//  Created by Mobile on 7/17/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WPaymentOption.h"

@implementation B2WPaymentOption

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _name = dictionary[@"_name"];
        if ([dictionary containsObjectForKey:@"_points"])
        {
            _points = [dictionary[@"_points"] integerValue];
        }
        if ([dictionary containsObjectForKey:@"parcel"])
        {
            _installments = [dictionary[@"parcel"] valueForKeyPath:@"_value"];
        }
    }
    return self;
}

- (instancetype)initWithPaymentOptionDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        if (dictionary[@"identifier"])
        {
            _identifier = dictionary[@"identifier"];
        }
        if (dictionary[@"type"])
        {
            _type = dictionary[@"type"];
        }
    }
    return self;
}

@end
