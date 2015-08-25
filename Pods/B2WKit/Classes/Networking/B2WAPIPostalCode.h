//
//  B2WAPIPostalCode.h
//  B2WKit
//
//  Created by Thiago Peres on 15/04/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WAPIClient.h"

@interface B2WAPIPostalCode : NSObject

/**
 Requests address information for a specific postal code.
 
 @param postalCode The desired postal code string.
 @param block      The completion handler block that processes results.
 
 @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestAddressInformationWithPostalCode:(NSString*)postalCode
                                                            block:(B2WAPICompletionBlock)block;

/**
 Requests address and postal code information for a given address. This method allows partial information to be provided (e.g only city/state).
 
 @param street A string containing street address information.
 @param city   A string containing city information.
 @param state  A string containing state information.
 @param block  The completion handler block that processes results.
 
 @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestPostalCodeWithStreet:(NSString*)street
                                                  city:(NSString*)city
                                                 state:(NSString*)state
                                                 block:(B2WAPICompletionBlock)block;

+ (void)cancelAllRequests;

@end
