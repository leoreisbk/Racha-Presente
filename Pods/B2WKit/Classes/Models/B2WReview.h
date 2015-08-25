//
//  B2WReview.h
//  B2WKit
//
//  Created by Thiago Peres on 13/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

/**
 *  Defines whether or not the product is recommended by the review's writer.
 */
typedef NS_ENUM(NSInteger, B2WRecommendationStatusType){
    /**
     *  The user does not recommend the product.
     */
    B2WRecommendationStatusNotRecommended = 0,
    /**
     *  The product is recommended.
     */
    B2WRecommendationStatusRecommended = 1,
    /**
     *  The user did not inform if he recommends the product.
     */
    B2WRecommendationStatusNotInformed
};

#import "B2WReviewResource.h"

@interface B2WReview : B2WReviewResource

/// The review's product's catalog identifier.
@property (nonatomic, readonly) NSString *productIdentifier;

/// An array containing the comments for the review.
@property (nonatomic, readonly) NSArray *comments;


/// The review's total number of comments.
@property (nonatomic, readonly) NSInteger totalCommentCount;


/// Whether or not the product is recommended by the review's writer.
@property (nonatomic, readonly) B2WRecommendationStatusType recommendationStatus;

/// The rating given to the product.
@property (nonatomic, readonly) CGFloat rating;

/// The maximum possible rating grade.
@property (nonatomic, readonly) CGFloat ratingRange;

@end
