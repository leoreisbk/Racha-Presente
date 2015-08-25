//
//  B2WProductOffer.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 1/13/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WProductOffer.h"

@implementation B2WProductOffer

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _productIdentifier = dictionary[@"productIdentifier"];
    }
    
    return self;
}

@end
