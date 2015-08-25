//
//  B2WCatalogURLProtocol.m
//  B2WKit
//
//  Created by Mobile on 7/10/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WCatalogURLProtocol.h"
#import "B2WAPIClient.h"
#import "NSURL+B2WKit.h"
#import "NSHTTPCookie+B2WKit.h"

@implementation NSString (Substring)

- (BOOL)containsSubstring:(NSString*)substring
{
	return ([self rangeOfString:substring].location != NSNotFound);
}

@end

@implementation B2WCatalogURLProtocol

static NSString *const B2WCatalogURLProtocolHandledKey = @"B2WCatalogURLProtocolHandledKey";

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
	NSString *baseURLString = [B2WAPIClient baseURLString];
	baseURLString = [baseURLString stringByReplacingOccurrencesOfString:@"http://www." withString:@""];
	baseURLString = [baseURLString stringByReplacingOccurrencesOfString:@"/" withString:@""];
	
	if ([request.URL.absoluteString containsSubstring:baseURLString] &&
		![NSURLProtocol propertyForKey:B2WCatalogURLProtocolHandledKey inRequest:request])
	{
		return YES;
	}
	
	return NO;
}

- (NSArray *)OPNCookies
{
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
	
	return cookies;
}

- (NSArray *)EParCookies
{
	NSString *cookieName;
	if ([[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
	{
		cookieName = @"acomEPar";
	}
	else
	{
		cookieName = [NSString stringWithFormat:@"%@EPar", [[B2WAPIClient brandCode] lowercaseString]];
	}
	
	NSArray *cookies = @[[NSHTTPCookie cookieWithName:@"b2wEPar" value:[B2WAPIClient EPARString]],
						 [NSHTTPCookie cookieWithName:cookieName value:[B2WAPIClient EPARString]]];
	
	return cookies;
}

- (void)startLoading
{
	NSMutableURLRequest *newRequest = [self.request mutableCopy];
	NSMutableArray *newCokies = [NSMutableArray new];
	
	//
	// Adds OPN cookies if existant
	//
	if ([B2WAPIClient OPNString] != nil || [B2WAPIClient OPNString].length > 0)
	{
		[newCokies addObjectsFromArray:[self OPNCookies]];
	}
	
	//
	// Adds EPAR cookies if existant
	//
	if ([B2WAPIClient EPARString] != nil || [B2WAPIClient EPARString].length > 0)
	{
		[newCokies addObjectsFromArray:[self EParCookies]];
	}
	
	NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithDictionary:newRequest.allHTTPHeaderFields];
	[headers addEntriesFromDictionary:[NSHTTPCookie requestHeaderFieldsWithCookies:newCokies]];
	[newRequest setAllHTTPHeaderFields:headers];
	
	[NSURLProtocol setProperty:@YES forKey:B2WCatalogURLProtocolHandledKey inRequest:newRequest];
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
