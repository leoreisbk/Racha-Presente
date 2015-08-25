//
//  B2WReviewComment.m
//  B2WKit
//
//  Created by Thiago Peres on 13/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WReviewComment.h"

@implementation B2WReviewComment

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self)
    {
        _reviewIdentifier = dictionary[@"ReviewId"];
    }
    return self;
}

@end
