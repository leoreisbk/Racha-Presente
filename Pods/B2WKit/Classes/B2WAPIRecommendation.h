//
//  B2WAPIRecommendation.h
//  B2WKit
//
//  Created by Thiago Peres on 18/02/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WAPIClient.h"

@interface B2WAPIRecommendation : NSObject

/**
 *  Requests an array of product lists containing various types of recommendations
 *  for a specific product.
 *
 *  @param identifier The product identifier.
 *  @param block      The completion handler block that processes results.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestProductRecommendationsWithProductIdentifier:(NSString*)identifier
                                                                        block:(B2WAPICompletionBlock)block;

/**
 *  Requests an array of product lists containing various types of recommendations.
 *
 *  @param block The completion handler block that processes results.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestFeaturedRecommendationsWithBlock:(B2WAPICompletionBlock)block;

+ (void)addB2WUID:(NSMutableDictionary *)params;

@end
