//
//  AFHTTPRequestOperation+B2WKit.m
//  B2WKit
//
//  Created by Flávio Caetano on 5/6/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "AFHTTPRequestOperation+B2WKit.h"

#import <objc/runtime.h>

static char const *const B2WAPICatalogMutableUserInfoKey = "B2WAPICatalogMutableUserInfoKey";


@implementation AFHTTPRequestOperation (B2WKit)

- (NSMutableDictionary*)mutableUserInfo
{
    NSMutableDictionary *_mutableUserInfo = objc_getAssociatedObject(self, B2WAPICatalogMutableUserInfoKey);
    
    if (_mutableUserInfo == nil)
    {
        _mutableUserInfo = [[NSMutableDictionary alloc] init];
        
        objc_setAssociatedObject(self, B2WAPICatalogMutableUserInfoKey, _mutableUserInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return _mutableUserInfo;
}

@end
