//
//  B2WAPIPaymentInfo.h
//  B2WKit
//
//  Created by Eduardo Callado on 7/8/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

//
// https://sacola.submarino.com.br/api/v1/credit-card-payment-info?checkoutId=75AaGSxI0FDdLJruVfhervCIeBF&bin=444433
//

#import <Foundation/Foundation.h>
#import "B2WAPIClient.h"

@interface B2WAPIPaymentInfo : NSObject

+ (AFHTTPRequestOperation *)requestInstallmentsWithCheckoutID:(NSString *)checkoutID
													  cardBin:(NSString *)cardBin
														block:(B2WAPICompletionBlock)block;

@end
