//
//  NSDictionary+B2WKit.h
//  B2WKit
//
//  Created by Thiago Peres on 11/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (B2WKit)

- (NSArray*)arrayForKey:(id)aKey;

- (BOOL)containsObjectForKey:(id)aKey;

- (instancetype)reverseKeyValues;

- (NSString *)JSONString;

- (BOOL)isEmptyXMLDictionary;

- (NSString*)base64EncodedJSONString;

@end

@interface NSObject (B2WKit)

- (BOOL)isDictionaryWithPairs:(NSDictionary *)pairs;

@end