//
//  B2WReviewResults.h
//  B2WKit
//
//  Created by Thiago Peres on 15/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WReviewResults : B2WObject

/// A dictionary containing statistics for a list of product reviews.
@property (nonatomic, readonly) NSDictionary *reviewStatistics;

/// An array containing B2WReviewResource objects.
@property (nonatomic, readonly) NSArray *reviews;

@end
