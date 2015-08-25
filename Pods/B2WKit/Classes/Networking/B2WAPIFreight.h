//
//  B2WAPIFreight.h
//  B2Wkit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

//
// http://api-portal.ideais.com.br/#/project/freight-api/v1-snapshot
//

#import <Foundation/Foundation.h>
#import "B2WAPIClient.h"

@interface B2WAPIFreight : NSObject

/**
 *  Requests a freight (shipping) estimate for a list of products with params.
 *
 *  @param postalCode The desired postal code.
 *  @param productParamsArray The array of dictionary params with SKU, partner (if exists) and salesPrice.
 *  @param block      The completion handler block that processes the result.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation *)requestEstimateWithPostalCode:(NSString *)postalCode
                                       productParamsArray:(NSArray *)productParamsArray
                                                    block:(B2WAPICompletionBlock)block;

@end