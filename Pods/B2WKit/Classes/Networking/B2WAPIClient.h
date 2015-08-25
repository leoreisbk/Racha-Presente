//
//  B2WAPIClient.h
//  B2Wkit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "B2WKitErrors.h"

extern NSString *const B2WAPIErrorDomain;

/**
 *  `B2WAPIClient` is a subclass of `AFHTTPRequestOperationManager` responsible for providing the basic structure for HTTP communication.
 */
@interface B2WAPIClient : AFHTTPRequestOperationManager

/**
 *  Returns a string containing the base URL string used for requests.
 *
 *  @return A string containing the base URL string used for requests.
 */
+ (NSString*)baseURLString;

/**
 *  Returns a string containing a four character brand identifier. Always uppercase.
 *
 *  @return A string containing a four character brand identifier. Always uppercase.
 */
+ (NSString*)brandCode;

+ (NSString*)apiKey;

+ (void)setOPNString:(NSString*)opnString;
+ (NSString*)OPNString;

+ (void)setEPARString:(NSString*)eparString;
+ (NSString*)EPARString;

+ (void)setFRANQString:(NSString *)franqString;
+ (NSString *)FRANQString;

+ (void)setReferrerURLString:(NSString *)referrerURLString;
+ (NSString *)referrerURLString;

/**
 *  Sets the base URL string and brand code used for requests.
 *
 *  @param baseURLString A string containing the base URL string.
 *  @param brandCode     A string containing the four character brand identifier.
 *  @param apiKey        A string containing the api key.
 */
+ (void)setBaseURLString:(NSString*)baseURLString brandCode:(NSString *)brandCode apiKey:(NSString*)apiKey;

/**
 *  Returns the shared API client object.
 *
 *  @return The shared API client object.
 */
+ (instancetype)sharedClient;

/**
 *  Returns a default AFNetworking block that handles B2WAPICompletionBlock blocks by passing errors along.
 *
 *  @param block The completion handler block that processes the results.
 */
+ (void (^)(AFHTTPRequestOperation *op, NSError *error))errorBlockWithBlock:(B2WAPICompletionBlock)block;
// TODO: merge with the method above
+ (void (^)(AFHTTPRequestOperation *op, NSError *error))defaultAPIFailureBlockWithBlock:(B2WAPICompletionBlock)block;

+ (void (^)(AFHTTPRequestOperation *op, id responseObject))completionBlockWithBlock:(B2WAPICompletionBlock)block;

@end
