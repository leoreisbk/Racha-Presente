//
//  B2WAPIInstallment.h
//  B2WKit
//
//  Created by Eduardo Callado on 3/25/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

//
// http://api-portal.ideais.com.br/#/project/installment-api/v1
//

#import <Foundation/Foundation.h>
#import "B2WAPIClient.h"
#import "B2WCartProduct.h"

@interface B2WAPIInstallment : NSObject

/**
 *  Requests a installment for a list of productInstallment objects.
 *
 *  @param paymentId The payment type ex:(MP_VISA).
 *  @param total The sum of products prices.
 *  @param installmentProducts The array of installmentProducts.
 *  @param block      The completion handler block that processes the result.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation *)requestInstallmentsWithPaymentId:(NSString *)paymentId
													   total:(NSString *)total
										 installmentProducts:(NSArray *)installmentProducts
													   block:(B2WAPICompletionBlock)block;

+ (NSArray *)installmentProductsWithCartProducts:(NSArray *)cartProducts;

@end
