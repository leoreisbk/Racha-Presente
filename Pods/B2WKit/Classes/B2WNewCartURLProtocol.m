//
//  B2WNewCartURLProtocol.m
//  B2WKit
//
//  Created by Mobile on 14/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WNewCartURLProtocol.h"
#import "B2WAPIClient.h"
#import "NSURL+B2WKit.h"
#import "NSHTTPCookie+B2WKit.h"
#import "NSString+B2WKit.h"

@implementation B2WNewCartURLProtocol

static NSString *const B2WCheckoutSubstring = @"/checkout";
static NSString *const B2WNewCartURLProtocolHandledKey = @"B2WNewCartURLProtocolHandledKey";

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    static NSUInteger requestCount = 0;
    NSLog(@"[B2WNewCartURLProtocol] Request #%u: URL = %@", requestCount++, request);
    
    if ([NSURLProtocol propertyForKey:B2WNewCartURLProtocolHandledKey inRequest:request]) {
        //already load
        return NO;
    }
    if (request != nil && [request.URL.absoluteString containsSubstring:B2WCheckoutSubstring])
    {
        return YES;
    }
    
    return NO;
}

- (NSDictionary*)HTTPHeaderFieldsByAddingOPNCookiesForRequest:(NSURLRequest*)request
{
    NSMutableDictionary * headers = [[NSMutableDictionary alloc] init];
    
    [headers addEntriesFromDictionary:[request allHTTPHeaderFields]];
    
    NSString *cookieName;
    if ([[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
    {
        cookieName = @"acomOpn";
    }
    else
    {
        cookieName = [NSString stringWithFormat:@"%@Opn", [[B2WAPIClient brandCode] lowercaseString]];
    }
    
    NSArray *cookies = @[[NSHTTPCookie cookieWithName:@"b2wOpn" value:[B2WAPIClient OPNString]],
                         [NSHTTPCookie cookieWithName:cookieName value:[B2WAPIClient OPNString]]];
    
    [headers addEntriesFromDictionary:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
    
    return headers;
}

- (NSDictionary*)HTTPHeaderFieldsByAddingEPARCookiesForRequest:(NSURLRequest*)request
{
    NSMutableDictionary * headers = [[NSMutableDictionary alloc] init];
    
    [headers addEntriesFromDictionary:[request allHTTPHeaderFields]];
    
    NSString *cookieName;
    if ([[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
    {
        cookieName = @"acomEPar";
    }
    else
    {
        cookieName = [NSString stringWithFormat:@"%@EPar", [[B2WAPIClient brandCode] lowercaseString]];
    }
    
    NSArray *cookies = @[ [NSHTTPCookie cookieWithName:@"b2wEPar" value:[B2WAPIClient EPARString]],
                          [NSHTTPCookie cookieWithName:cookieName value:[B2WAPIClient EPARString]]];
    
    [headers addEntriesFromDictionary:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
    
    return headers;
}

- (NSMutableDictionary *)cookieProperties
{
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *cookieName = @"gtm_sac";
    NSString *cookieDomain = @".americanas.com.br";
    
    if ([[B2WAPIClient brandCode] isEqualToString:@"SUBA"])
    {
        cookieDomain = @".submarino.com.br";
    }
    else if ([[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
    {
        cookieDomain = @".shoptime.com.br";
    }
    
    [cookieProperties setObject:cookieName forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"claa" forKey:NSHTTPCookieValue];
    [cookieProperties setObject:cookieDomain forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    
    return cookieProperties;
}

- (void)startLoading
{
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:B2WNewCartURLProtocolHandledKey inRequest:newRequest];
    NSLog(@"\nLOAD URL: %@",newRequest);
    
    //
    // Adds OPN cookies if existant
    //
    if ([B2WAPIClient OPNString] != nil || [B2WAPIClient OPNString].length > 0)
    {
        [newRequest setAllHTTPHeaderFields:[self HTTPHeaderFieldsByAddingOPNCookiesForRequest:newRequest]];
    }
    
    //
    // Adds EPAR cookies if existant
    //
    if ([B2WAPIClient EPARString] != nil || [B2WAPIClient EPARString].length > 0)
    {
        [newRequest setAllHTTPHeaderFields:[self HTTPHeaderFieldsByAddingEPARCookiesForRequest:newRequest]];
    }

    NSMutableDictionary *cookieProperties = [self cookieProperties];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

#pragma mark - Base Methods

- (void)stopLoading
{
    [self.connection cancel];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
    self.connection = nil;
}

@end
