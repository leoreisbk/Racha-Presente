//
//  B2WObject.m
//  B2WKit
//
//  Created by Thiago Peres on 10/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@implementation B2WObject

+ (NSArray *)objectsWithDictionaryArray:(NSArray *)array
{
    if (array == nil)
    {
        return @[];
    }
    
    if (![array isKindOfClass:[NSArray class]])
    {
        return nil;
    }
        
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
    for (id dict in array)
    {
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            id object = [self alloc];
            id initializedObject = nil;
            
            @try {
                initializedObject = [object initWithDictionary:dict];
            }
            @catch (NSException *exception) {
                NSLog(@"\n\n[!] ERROR: exception thrown when parsing an API response. Failed to initialize %@ with dictionary:\n%@\n[*] Exception: %@ (%@)\n\n", [self class], dict, exception.reason, exception.name);
            }
            @finally {
                if (initializedObject) {
                    [result addObject:initializedObject];
                }
            }
        }
    }
    return result;
}

@end
