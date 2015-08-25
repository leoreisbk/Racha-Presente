//
//  NSObject+B2WKit.m
//  B2WKit
//
//  Created by Flávio Caetano on 5/6/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "NSObject+B2WKit.h"

// Categories
#import "NSDictionary+B2WKit.h"

@implementation NSObject (B2WKit)

- (BOOL)isValidResponseObject
{
    return [self isKindOfClass:[NSDictionary class]] && ![(NSDictionary*)self isEmptyXMLDictionary];
}

@end
