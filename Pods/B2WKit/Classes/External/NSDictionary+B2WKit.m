//
//  NSDictionary+B2WKit.h
//  B2WKit
//
//  Created by Thiago Peres on 11/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "NSDictionary+B2WKit.h"

@implementation NSDictionary (B2WKit)

- (NSArray*)arrayForKey:(id)aKey
{
    id obj = self[aKey];
    
    if ([obj isKindOfClass:[NSArray class]])
    {
        return obj;
    }
    
    if (obj != nil)
    {
        return @[obj];
    }
    
    return @[];
}

- (BOOL)containsObjectForKey:(id)aKey
{
    return [[self allKeys] containsObject:aKey];
}

- (instancetype)reverseKeyValues
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    for (NSString *key in self.allKeys)
    {
        id value = self[key];
        if ([value isKindOfClass:[NSString class]])
        {
            result[value] = key;
        }
    }
    
    return result;
}

- (NSString *)JSONString
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (BOOL)isEmptyXMLDictionary
{
    if ((self.count <= 0) ||
        (self.count == 1 && [self containsObjectForKey:@"__name"]))
    {
        return YES;
    }
    return NO;
}

- (NSString *)base64EncodedJSONString
{
    return [[[self JSONString] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

@end

@implementation NSObject (B2WKit)

- (BOOL)isDictionaryWithPairs:(NSDictionary *)pairs
{
    if ( ! [self isKindOfClass:[NSDictionary class]] ) { return NO; }
    
    NSDictionary *dict = (NSDictionary *)self;
    for (NSString *key in pairs) {
        if ((![dict containsObjectForKey:key]) || (![pairs[key] isEqual:dict[key]])) {
            return NO;
        }
    }
    
    return YES;
}

@end