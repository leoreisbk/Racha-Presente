//
//  NSData+B2WKit.m
//  B2WKit
//
//  Created by Thiago Peres on 10/04/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "NSData+B2WKit.h"

@implementation NSData (B2WKit)

- (NSString*)deviceTokenString
{
    //
    // Convert device token data to string
    //
    const unsigned *tokenBytes = [self bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    return hexToken;
}

@end
