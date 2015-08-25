//
//  NSString+B2WKit.m
//  B2WKit
//
//  Created by Mobile on 14/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "NSString+B2WKit.h"

@implementation NSString (B2WKit)

- (BOOL)containsSubstring:(NSString*)substring
{
    return ([self rangeOfString:substring].location != NSNotFound);
}

- (NSString *)priceStringWithoutFormat
{
    NSString *priceString = [self stringByReplacingOccurrencesOfString:@"R$ " withString:@""];
    priceString = [priceString stringByReplacingOccurrencesOfString:@"." withString:@""];
    priceString = [priceString stringByReplacingOccurrencesOfString:@"," withString:@"."];
    return priceString;
}

@end