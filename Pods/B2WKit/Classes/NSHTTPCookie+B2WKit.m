//
//  NSHTTPCookie+B2WKit.m
//  B2WKit
//
//  Created by Mobile on 14/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "NSHTTPCookie+B2WKit.h"
#import "NSURL+B2WKit.h"
#import "B2WAPIClient.h"

@implementation NSHTTPCookie (B2WKit)

+ (NSHTTPCookie*)cookieWithName:(NSString*)name value:(NSString*)value
{
    NSURL *url = [NSURL URLWithString:[B2WAPIClient baseURLString]];
    NSString *cookieDomain = [NSString stringWithFormat:@".%@", [url domain]];
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                cookieDomain, NSHTTPCookieDomain,
                                @"/", NSHTTPCookiePath,
                                name, NSHTTPCookieName,
                                value, NSHTTPCookieValue,
                                nil];
    
    return [NSHTTPCookie cookieWithProperties:properties];
}

@end
