//
//  NSURL+B2WKit.m
//  B2WKit
//
//  Created by Thiago Peres on 16/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "NSURL+B2WKit.h"
#import "B2WAPIClient.h"

@implementation NSURL (B2WKit)

- (NSString*)domain
{
    NSArray *first = [[self host] componentsSeparatedByString:@"/"];
    
    for (__strong NSString *part in first) {
        if ([part rangeOfString:@"."].location != NSNotFound){
            part = [part stringByReplacingOccurrencesOfString:@"www." withString:@""];
            return [part stringByReplacingOccurrencesOfString:@"mid-m." withString:@""];
        }
    }
    return nil;
}

+ (NSString*)URLStringWithSubdomain:(NSString*)subdomain options:(B2WAPIURLOptions)options path:(NSString*)path, ... NS_FORMAT_FUNCTION(3, 4)
{
    //
    // Create a string from arguments
    //
    va_list args;
    va_start(args, path);
    NSString *stringFromArguments = [[[NSString alloc] initWithFormat:path arguments:args] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    va_end(args);
    // END: Create a string from arguments
    
    NSString *urlString = (options & B2WAPIURLOptionsUsesHTTPS) ? @"https://" : @"http://";
    urlString = (options & B2WAPIURLOptionsAddCorporateKey) ? [urlString stringByAppendingFormat:@"%@:@", [B2WAPIClient apiKey]] : urlString;
    
    // Adds subdomain and base url
    urlString = [urlString stringByAppendingFormat:@"%@.%@", subdomain, [B2WAPIClient sharedClient].baseURL.domain];
        
    return [[NSURL URLWithString:stringFromArguments relativeToURL:[NSURL URLWithString:urlString]] absoluteString];
}

@end
