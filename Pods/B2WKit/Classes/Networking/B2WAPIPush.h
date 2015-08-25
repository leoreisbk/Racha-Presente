//
//  B2WAPIPushTracking.h
//  B2WKit
//
//  Created by Thiago Peres on 25/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WAPIClient.h"

@interface B2WAPIPush : NSObject

/**
 Retrieves the last saved device token from NSUserDefaults.
 
 @return A string containing the last saved device token.
 */
+ (NSString*)deviceToken;

/**
 Sets the device token used in B2WAPIPush requests and stores it in NSUserDefaults.
 
 @param deviceToken A NSData object containing the device token.
 */
+ (void)setDeviceToken:(NSData*)deviceToken;

/**
 Sends a POST request enabling push notifications for the current logged in user and device.
 
 @param trackingEnabled  A boolean indicating if tracking should be enabled.
 @param marketingEnabled A boolean indicating if marketing should be enabled.
 @param block            The completion handler block that processes the result. This parameter must not be nil.
 
 @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)enablePushWithTrackingEnabled:(BOOL)trackingEnabled
                                        marketingEnabled:(BOOL)marketingEnabled
                                                   block:(B2WAPICompletionBlock)block;

/**
 *  Updates order tracking and marketing opt-ins for the logged user. If no user is currently logged in, returns nil.
 *
 *  @param trackingEnabled A boolean indicating if tracking should be enabled.
 *  @param marketingEnabled  A boolean indicating if marketing should be enabled.
 *  @param block       The completion handler block that processes the result. This parameter must not be nil.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation *)updateSettingsWithTrackingEnabled:(BOOL)trackingEnabled
                                             marketingEnabled:(BOOL)marketingEnabled
                                                        block:(B2WAPICompletionBlock)block;

@end
