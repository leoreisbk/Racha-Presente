//
//  B2WCartAuthURLProtocol.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 10/3/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WCartAuthURLProtocol.h"
#import "B2WAPIAccount.h"
#import "B2WKitUtils.h"

@implementation NSString (Substring)

- (BOOL)containsSubstring:(NSString*)substring
{
    return ([self rangeOfString:substring].location != NSNotFound);
}

@end

@implementation NSData (Empty)

- (BOOL)isEmpty
{
    return [[[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding] isEqualToString:@""];
}

@end

@implementation B2WCartAuthURLProtocol

static NSString *const B2WBasketCheckoutPath = @"/checkout";
static NSString *const B2WBasketOneClickCheckoutPath = @"/checkout/one_click";
static NSString *const B2WBasketURLAuthProtocolHandledKey = @"B2WBasketURLAuthProtocolHandledKey";

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    BOOL hasRightPath = [request.URL.path isEqualToString:B2WBasketCheckoutPath] || [request.URL.path isEqualToString:B2WBasketOneClickCheckoutPath];
    BOOL hasPostMethod = [[request HTTPMethod] isEqualToString:@"POST"];
    BOOL hasEmptyBody = [[request HTTPBody] isEmpty];
    BOOL isFirstTimeBeingHandled = ! [NSURLProtocol propertyForKey:B2WBasketURLAuthProtocolHandledKey inRequest:request];
    
    return hasRightPath && hasPostMethod && hasEmptyBody && isFirstTimeBeingHandled;
}

- (void)startLoading
{
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:B2WBasketURLAuthProtocolHandledKey inRequest:newRequest];
    
    NSLog(@"[*] B2WCartAuthURLProtocol caught URL: %@", self.request.URL.absoluteString);
    NSLog(@"[*] HTTP Method = %@", [self.request HTTPMethod]);
    NSLog(@"[*] HTTP Body = '%@'", [[NSString alloc] initWithData:[self.request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    if ([B2WAPIAccount isLoggedIn]) {
        // BB's JavaScript doesn't percent encode '-' nor '*' (but they don't seem to accept weird email/passwords anyway)
        NSString *characters = @"~^!'()<>{}[];:@&=+$,/?%#";
        NSString *encodedUsername = [B2WKitUtils stringByAddingPercentEscapes:[B2WAPIAccount username] encodeCharacters:characters];
        NSString *encodedPassword = [B2WKitUtils stringByAddingPercentEscapes:[B2WAPIAccount password] encodeCharacters:characters];
        NSString *body = [NSString stringWithFormat:@"login=%@&password=%@", encodedUsername, encodedPassword];
        NSLog(@"[*] Setting request body: %@", body);
        [newRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

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
