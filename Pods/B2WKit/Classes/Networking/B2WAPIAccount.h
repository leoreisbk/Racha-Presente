//
//  B2WAPIAuth.h
//  B2WKit
//
//  Created by Thiago Peres on 15/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WAPIClient.h"

#define B2WAPIAuthKeychainUsernameKey			  @"B2WAuthUsernameKey"
#define B2WAPIAuthKeychainLastUsernameKey		  @"B2WAuthLastUsernameKey"
#define B2WAPIAuthKeychainPasswordKey			  @"B2WAuthPasswordKey"
#define B2WAPIAuthKeychainUserInfoKey			  @"B2WAuthUserInfoKey"
#define B2WAPIAuthKeychainTokenExpirationDateKey  @"B2WAuthTokenExpirationKey"
#define B2WAPIAuthKeychainNameKey				  @"B2WAuthNameKey"
#define B2WAPIAuthKeychainUIDKey				  @"B2WAuthUIDKey"

@interface B2WAPIAccount : NSObject

+ (void)setStaging:(BOOL)staging;
+ (BOOL)isStaging;

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password token:(NSString *)token;

+ (AFHTTPRequestOperation *)_loginWithUsername:(NSString *)username password:(NSString *)password block:(B2WAPICompletionBlock)block;

/**
 *  Performs a login request.
 *
 *  @param username    The user's login name. This parameter must not be nil.
 *  @param password    The user's password. This parameter must not be nil.
 *  @param block       The completion handler block that processes the result. This parameter must not be nil.
 *
 *  @return The operation object responsible for the request.
 */
//+ (AFHTTPRequestOperation *)loginWithUsername:(NSString *)username
//                                     password:(NSString *)password
//                                        block:(B2WAPICompletionBlock)block;

/**
 *  Returns a Boolean value indicating if there's an user currently logged in.
 *
 *  @return YES if there's an user logged in; Otherwise, NO.
 */
+ (BOOL)isLoggedIn;

+ (BOOL)tokenExpired;

/**
 *  Returns a dictionary containing user information like name, email, etc.
 *
 *  @return A dictionary containing user information like name, email, etc.
 */
+ (NSDictionary *)userInfo;

+ (NSString *)token;

+ (NSString *)userIdentifier;

/**
 *  Returns a Boolean value indicating if two different accounts have been used recently.
 *
 *  @return YES if the currently logged in account is different from the last logged in account; Otherwise, NO. Also returns NO if there's no last account stored.
 */
+ (BOOL)recentlyAlternatedAccounts;

/**
 *  Returns the current user email address.
 */
+ (NSString *)username;

+ (void)setUsername:(NSString *)username;

/**
 *  Returns the last logged-in user email address, or nil if this is the first login.
 */
+ (NSString *)lastUsername;

/**
 *  Returns the current user password.
 */
+ (NSString *)password;

+ (void)setPassword:(NSString *)password;

/**
 *  Returns the current user B2WUID.
 */
+ (NSString *)B2WUID;

+ (void)setB2WUID:(NSString *)B2WUID;

+ (BOOL)isAnonymousB2WUID:(NSString *)B2WUID;

/**
 *  Update B2WUID.
 */
+ (void)updateB2WUID;

/**
 *  Performs logout.
 */
+ (void)logout;


+ (AFHTTPRequestOperation*)requestPasswordRetrievalForUsernamed:(NSString *)username
														  block:(B2WAPICompletionBlock)block;

+ (AFHTTPRequestOperation*)updatePasswordForUserNamed:(NSString *)username
										  newPassword:(NSString *)newPassword
												block:(B2WAPICompletionBlock)block;

+ (AFHTTPRequestOperation*)updateUsernameForUserNamed:(NSString *)username
										  newUsername:(NSString *)newUsername
												block:(B2WAPICompletionBlock)block;

@end
