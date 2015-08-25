//
//  NSString+B2WKit.h
//  B2WKit
//
//  Created by Mobile on 14/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (B2WKit)

- (BOOL)containsSubstring:(NSString*)substring;

- (NSString *)priceStringWithoutFormat;

@end