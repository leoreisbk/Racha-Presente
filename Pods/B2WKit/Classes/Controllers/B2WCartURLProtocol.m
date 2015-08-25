//
//  ACOMBasketURLProtocol.m
//  Americanas
//
//  Created by Thiago Peres on 17/01/14.
//  Copyright (c) 2014 Ideais. All rights reserved.
//

#import "B2WCartURLProtocol.h"

@implementation NSString (Substring)

- (BOOL)containsSubstring:(NSString*)substring
{
    return ([self rangeOfString:substring].location != NSNotFound);
}

@end

@implementation B2WCartURLProtocol

static NSString *const B2WBasketCheckoutSubstring = @"/checkout";
static NSString *const B2WBasketURLProtocolHandledKey = @"B2WBasketURLProtocolHandledKey";

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([request.URL.absoluteString containsSubstring:B2WBasketCheckoutSubstring] &&
        ![NSURLProtocol propertyForKey:B2WBasketURLProtocolHandledKey inRequest:request])
    {
        return YES;
    }
    
    return NO;
}

- (void)startLoading
{
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
	
    [newRequest addValue:@"true" forHTTPHeaderField:@"x-b2w-webview"];
	NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	[newRequest addValue:version forHTTPHeaderField:@"x-b2w-appversion"];
    [NSURLProtocol setProperty:@YES forKey:B2WBasketURLProtocolHandledKey inRequest:newRequest];
    
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
