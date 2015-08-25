//
//  B2WImage.m
//  B2Wkit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WImage.h"

@implementation B2WImage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _url           = [NSURL URLWithString:dictionary[@"_url"]];
        _SKUIdentifier = dictionary[@"_sku"];
    }
    return self;
}

@end
