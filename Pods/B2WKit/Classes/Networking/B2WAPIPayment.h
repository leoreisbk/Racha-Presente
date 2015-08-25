//
//  B2WAPIPayment.h
//  B2WKit
//
//  Created by Eduardo Callado on 8/1/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

//
// http://api-portal.ideais.com.br/#/project/payment-api/v2
//

#import <Foundation/Foundation.h>
#import "B2WAPIClient.h"

@interface B2WAPIPayment : NSObject

+ (AFHTTPRequestOperation *)requestPaymentsWithPriceTotal:(NSString *)priceTotal
                                               hasVoucher:(BOOL)hasVoucher
                                              hasWarranty:(BOOL)hasWarranty
                                             salesChannel:(NSString *)salesChannel
                                          paymentProducts:(NSArray *)paymentProducts
                                                    block:(B2WAPICompletionBlock)block;

/**
 *  Requests a credit card id with bin.
 *
 *  @param bin The first six numbers of credit card.
 *  @param block      The completion handler block that processes the result.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation *)requestCreditCardIdWithBin:(NSString *)bin
                                                 block:(B2WAPICompletionBlock)block;

@end