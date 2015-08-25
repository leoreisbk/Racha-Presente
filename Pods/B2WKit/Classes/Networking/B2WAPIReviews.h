//
//  B2WAPIReviews.h
//  B2WKit
//
//  Created by Thiago Peres on 09/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BVSDK/BVSDK.h>
#import "B2WAPIClient.h"
#import "B2WPagingProtocol.h"

extern NSString *const B2WAPIReviewsSortTypeMostUseful;
extern NSString *const B2WAPIReviewsSortTypeMostComments;
extern NSString *const B2WAPIReviewsSortTypeNewest;
extern NSString *const B2WAPIReviewsSortTypeOldest;
extern NSString *const B2WAPIReviewsSortTypeMostPositive;
extern NSString *const B2WAPIReviewsSortTypeMostNegative;

@interface B2WAPIReviews : NSObject

/**
 *  Sets API information. You must call this method first before making any requests.
 *
 *  @param key     The BazaarVoice's API key
 *  @param staging A Boolean value indicating if connection is made to staging servers or production servers.
 */
+ (void)setAPIKey:(NSString *)key staging:(BOOL)staging;

/**
 *  Returns a string containing the provided API key.
 *
 *  @return A string containing the provided API key.
 */
+ (NSString*)APIKey;

/**
 *  Requests an array of review, review comments and product review information
 *
 *  @param identifier     The product identifier.
 *  @param sortType       A string indicating how results should be sorted. The string's value must be one
 *  the values previously defined in B2WAPIReviews.
 *  @param page           An unsigned integer containing the desired page. Starts at zero.
 *  @param resultsPerPage An unsigned integer containing the number of desired results per page. Must be greater than zero.
 *  @param block          The completion handler block that processes results, containing a B2WReviewResults object.
 */
+ (void)requestReviewsWithProductIdentifier:(NSString*)identifier
                                       sort:(NSString*)sortType
                                       page:(NSUInteger)page
                             resultsPerPage:(NSUInteger)resultsPerPage
                                      block:(B2WAPICompletionBlock)block;

@end
