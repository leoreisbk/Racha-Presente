//
//  B2WReviewResults.m
//  B2WKit
//
//  Created by Thiago Peres on 15/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WReviewResults.h"
#import "B2WReview.h"

@implementation B2WReviewResults

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        NSString *productIdentifier = [[dictionary[@"Includes"][@"Products"] allKeys] firstObject];
        _reviewStatistics           = [dictionary[@"Includes"][@"Products"][productIdentifier][@"ReviewStatistics"] copy];
        _reviews                    = [B2WReview objectsWithDictionaryArray:dictionary[@"Results"]];
    }
    return self;
}

@end
