//
//  B2WDeeplink.m
//  B2WKit
//
//  Created by rodrigo.fontes on 23/02/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WDeeplink.h"
#import "B2WOffer.h"

@implementation B2WDeeplink

- (id)initWithDictionary:(NSDictionary *)dictionary type:(NSString *)type
{
    _type = type;
    _offer = [[B2WOffer alloc] initWithDictionary:dictionary];
    
    return self;
}

@end