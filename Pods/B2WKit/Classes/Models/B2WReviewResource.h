//
//  B2WReviewResource.h
//  B2WKit
//
//  Created by Thiago Peres on 13/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

/**
 *   An abstract class that shares common properties through review related objects.
 */
@interface B2WReviewResource : B2WObject

/// The review's catalog identifier.
@property (nonatomic, readonly) NSString *identifier;

/// The total number of feedbacks for the review;
@property (nonatomic, readonly) NSInteger totalFeedbackCount;

/// The total number of negative feedbacks for the review.
@property (nonatomic, readonly) NSInteger totalNegativeFeedbackCount;

/// The total number of positive feedbacks for the review.
@property (nonatomic, readonly) NSInteger totalPositiveFeedbackCount;


/// The review's title.
@property (nonatomic, readonly) NSString *title;

/// The review's text.
@property (nonatomic, readonly) NSString *text;

/// The nickname of the user who wrote the review.
@property (nonatomic, readonly) NSString *userNickName;


/// The date when the review was written.
@property (nonatomic, readonly) NSDate *submissionTime;

/// The catalog identifier of the user who wrote the review.
@property (nonatomic, readonly) NSString *authorIdentifier;


@end
