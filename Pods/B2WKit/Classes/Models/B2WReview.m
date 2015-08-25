//
//  B2WReview.m
//  B2WKit
//
//  Created by Thiago Peres on 13/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WReview.h"
#import "B2WReviewComment.h"

@implementation B2WReview

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self)
    {
        _productIdentifier    = dictionary[@"ProductId"];
        _totalCommentCount    = [dictionary[@"TotalCommentCount"] integerValue];

        id isRecommended      = dictionary[@"IsRecommended"];

        if (isRecommended == [NSNull null])
        {
        _recommendationStatus = B2WRecommendationStatusNotInformed;
        }
        else
        {
        _recommendationStatus = (B2WRecommendationStatusType)[isRecommended boolValue];
        }

        _rating      = [dictionary[@"Rating"] doubleValue];
        _ratingRange = [dictionary[@"RatingRange"] doubleValue];
        _comments    = [B2WReviewComment objectsWithDictionaryArray:dictionary[@"Comments"]];
    }
    return self;
}

@end
