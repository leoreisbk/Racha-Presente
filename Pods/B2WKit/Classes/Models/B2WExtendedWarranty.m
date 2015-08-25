//
//  B2WExtendedWarranty.m
//  B2WKit
//
//  Created by Mobile on 7/16/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WExtendedWarranty.h"

@implementation B2WExtendedWarranty

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _identifier = dictionary[@"_id"];
        _years = [dictionary[@"_years"] integerValue];
        _installment = dictionary[@"_installment"];
    }
    return self;
}

@end
