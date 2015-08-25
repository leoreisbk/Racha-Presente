//
//  NSURL+B2WKit.h
//  B2WKit
//
//  Created by Thiago Peres on 16/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, B2WAPIURLOptions)
{
    // Specifies that the url should contain the corporate api key
    B2WAPIURLOptionsAddCorporateKey = (1 << 0),
    // Specifies that the url should use https://
    B2WAPIURLOptionsUsesHTTPS = (1 << 1),
};

@interface NSURL (B2WKit)

@property (nonatomic, readonly) NSString *domain;

+ (NSString*)URLStringWithSubdomain:(NSString*)subdomain options:(B2WAPIURLOptions)options path:(NSString*)path, ... NS_FORMAT_FUNCTION(3, 4);

@end
