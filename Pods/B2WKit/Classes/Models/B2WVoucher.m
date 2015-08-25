//
//  B2WVoucher.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 5/18/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WVoucher.h"

@implementation B2WVoucher

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _identifier = [dictionary objectForKey:@"number"];
        _totalAmount = [dictionary objectForKey:@"totalAmount"];
        _usedAmount = [dictionary objectForKey:@"usedAmount"];
    }
    return self;
}

@end
