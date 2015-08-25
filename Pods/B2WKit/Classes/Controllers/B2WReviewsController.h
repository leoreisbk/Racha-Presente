//
//  B2WReviewsController.h
//  B2WKit
//
//  Created by Thiago Peres on 09/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WPagingProtocol.h"

@interface B2WReviewsController : NSObject <B2WPagingProtocol>

/**
 *  An array containing B2WReview objects fetched on the last request.
 */
@property (nonatomic, readonly) NSArray *lastResults;

/**
 *  A dictionary containing review statistic information.
 */
@property (nonatomic, readonly) NSDictionary *reviewStatistics;

/**
 *  A string indicating how results should be sorted. The string's value must be one
 *  the values previously defined in B2WAPIReviews. Setting this property will trigger
 *  a new first page request with the new sort type applied.
 */
@property (nonatomic, strong) NSString *sortType;

/**
 *  The delegate object to receive update events.
 */
@property (nonatomic, weak) id <B2WPagingResultsDelegate> delegate;

/**
 *  Returns a B2WReviewsController object initialized with the provided values
 *  and prepared to make requests.
 *
 *  @param identifier     The product's catalog identifier.
 *  @param sortType       A string indicating how results should be sorted.
 *  @param resultsPerPage An unsigned integer containing the number of desired results per page. Must be greater than zero.
 *
 *  @return A B2WReviewsController object initialized with the provided values.
 */
- (id)initWithProductIdentifier:(NSString*)identifier
                           sort:(NSString*)sortType
                 resultsPerPage:(NSUInteger)resultsPerPage;

@end
