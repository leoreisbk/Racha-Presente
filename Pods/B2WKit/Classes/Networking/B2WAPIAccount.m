//
//  B2WAPIAuth.m
//  B2WKit
//
//  Created by Thiago Peres on 15/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WAPIAccount.h"

#import "B2WAPIClient.h"
#import "B2WAPIPush.h"
#import "B2WKitUtils.h"
#import "NSURL+B2WKit.h"
#import "NSDictionary+B2WKit.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <SFHFKeychainUtils/SFHFKeychainUtils.h>
#import <UICKeyChainStore/UICKeyChainStore.h>

static NSTimeInterval const kAuthTokenExpirationTimeInterval = (NSTimeInterval) 10.0 * 60 * 60; // 10 hours

@interface B2WAPIAccount ()

@property (nonatomic, assign) BOOL _isLoggedIn;
@property (nonatomic, assign) BOOL _stagingEnabled;

@end

@implementation B2WAPIAccount

+ (void)setStaging:(BOOL)staging
{
    [[B2WAPIAccount _manager] set_stagingEnabled:staging];
}

+ (BOOL)isStaging
{
	return [[B2WAPIAccount _manager] _stagingEnabled];
}

+ (B2WAPIAccount *)_manager
{
    static B2WAPIAccount *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[B2WAPIAccount alloc] init];
    });
    
    return _sharedInstance;
}

+ (BOOL)isLoggedIn
{
    return [UICKeyChainStore dataForKey:B2WAPIAuthKeychainUserInfoKey] != nil; //&& ![B2WAPIAccount _tokenExpired];
}

+ (NSDictionary *)userInfo
{
    NSData *data = [UICKeyChainStore dataForKey:B2WAPIAuthKeychainUserInfoKey];
    
    return data == nil ? nil : [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (NSString *)token
{
    return [B2WAPIAccount userInfo][@"token"];
}

+ (NSString *)userIdentifier
{
    return [[[B2WAPIAccount userInfo][@"link"][@"href"] componentsSeparatedByString:@"/"] lastObject];
}

+ (NSString *)username
{
    return [UICKeyChainStore stringForKey:B2WAPIAuthKeychainUsernameKey];
}

+ (void)setUsername:(NSString *)username
{
    if (username == nil)
    {
        return;
    }
    
	[UICKeyChainStore setString:username forKey:B2WAPIAuthKeychainUsernameKey];
}

+ (NSString *)lastUsername
{
    return [UICKeyChainStore stringForKey:B2WAPIAuthKeychainLastUsernameKey];
}

+ (NSString *)password
{
    return [UICKeyChainStore stringForKey:B2WAPIAuthKeychainPasswordKey];
}

+ (void)setPassword:(NSString *)password
{
    if (password == nil)
    {
        return;
    }
    
	[UICKeyChainStore setString:password forKey:B2WAPIAuthKeychainPasswordKey];
}

+ (NSString *)B2WUID
{
    return [UICKeyChainStore stringForKey:B2WAPIAuthKeychainUIDKey];
}

+ (void)setB2WUID:(NSString *)B2WUID
{
    if (B2WUID == nil)
    {
        return;
    }
    
    [UICKeyChainStore setString:B2WUID forKey:B2WAPIAuthKeychainUIDKey];
}

+ (void)updateB2WUID
{
    NSString *newB2WUID = [self B2WUID];
    if ([self isLoggedIn])
    {
        newB2WUID = [self encryptedB2WUIDWithEmail:[self username]];
    }
    else if ([self isAnonymousB2WUID:newB2WUID])
    {
        newB2WUID = [self anonymousB2WUID];
    }
    [self setB2WUID:newB2WUID];
}

+ (BOOL)isAnonymousB2WUID:(NSString *)B2WUID
{
    if (B2WUID == nil || (B2WUID && [B2WUID hasPrefix:@"va_"]))
    {
        return YES;
    }
    return NO;
}

+ (NSString *)anonymousB2WUID
{
    return [self createB2WUIDWithFunction:@"crmWA_anonymousID" arguments:nil];
}

+ (NSString *)encryptedB2WUIDWithEmail:(NSString *)email
{
    if (email)
    {
        return [self createB2WUIDWithFunction:@"crmWA_encriptID" arguments:@[email]];
    }
    return nil;
}

+ (NSString *)createB2WUIDWithFunction:(NSString *)functionName arguments:(NSArray *)arguments
{
    NSString *path = [[NSBundle B2WKitBundle] pathForResource:@"jsSHA" ofType:@"js"];
    if (path)
    {
        NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        if (jsScript)
        {
            JSContext *context = [[JSContext alloc] init];
            [context evaluateScript: jsScript];
            JSValue *function = context[functionName];
            JSValue* result = [function callWithArguments:arguments];
            return [result toString];
        }
    }
    return nil;
}

+ (BOOL)recentlyAlternatedAccounts
{
    NSString *lastLoggedInUserEmail = [B2WAPIAccount lastUsername];
    NSString *currentlyLoggedInUserEmail = [B2WAPIAccount username];
    
    if (lastLoggedInUserEmail && currentlyLoggedInUserEmail)
	{
        return ! [lastLoggedInUserEmail isEqualToString:currentlyLoggedInUserEmail];
    }
	else
	{
        return NO; // if any of them are nil, we're either not logged in or this is the first login
    }
}

+ (BOOL)tokenExpired
{
    NSData *data = [UICKeyChainStore dataForKey:B2WAPIAuthKeychainTokenExpirationDateKey];
    NSDate *expirationDate = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSLog(@"[*] Token expiration date: %@", expirationDate);
    NSLog(@"[*] Time interval since exp date: %lf", [[NSDate date] timeIntervalSinceDate:expirationDate]);
    NSLog(@"[*] Token expiration interval: %lf\n\n", kAuthTokenExpirationTimeInterval);
    
    return [[NSDate date] timeIntervalSinceDate:expirationDate] > 0;
}

+ (AFHTTPRequestOperation *)_loginWithUsername:(NSString *)username password:(NSString *)password block:(B2WAPICompletionBlock)block
{
    if (username == nil || username.length == 0 ||
       password == nil || password.length == 0 ||
       block == nil)
    {
        return nil;
    }
    
    /*
    if ([B2WAPIAccount isLoggedIn] && block)
    {
        block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                       code:B2WAPIAlreadyLoggedInError
                                   //userInfo:@{NSLocalizedDescriptionKey: @"There's an user already logged in. You must logout first."}]);
								   userInfo:@{NSLocalizedDescriptionKey: @"Já existe um usuário conectado. Você deve sair primeiro."}]);
    }
    */
	
	NSString *path;
    if ([[B2WAPIAccount _manager] _stagingEnabled])
    {
        path = @"http://checkout:@bentley:8080/AccountRest-v3/account";
    }
    else
    {
        path = [NSURL URLStringWithSubdomain:@"carrinho"
									 options:B2WAPIURLOptionsAddCorporateKey | B2WAPIURLOptionsUsesHTTPS
										//path:@"api/v3/account"];
										path:@"account-v3/account"];
    }
    
    NSString *encodedUsername = [B2WKitUtils stringByAddingPercentEscapes:username];
	NSDictionary *params = @{ @"password": password };
	
	NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
																			   URLString:[path stringByAppendingFormat:@"/%@", encodedUsername]
																			  parameters:params
																				   error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		[B2WAPIAccount storeUsername:username
							password:password
							userInfo:responseObject];
		
		block(responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		//
		// Checks if the API returned an error message
		//
		if (error && ![error.domain isEqualToString:NSURLErrorDomain])
		{
			NSString *responseString = operation.responseString;
			
			NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
			NSError *e;
			id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
			
			if (e)
			{
				block(nil, error);
				return;
			}
			if (response)
			{
				block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
											   code:B2WAPIServiceError
										   userInfo:@{NSLocalizedDescriptionKey : response}]);
			}
		}
		else
		{
			block(nil, error);
			return;
		}
	}];
	
	[op setResponseSerializer:[AFJSONResponseSerializer serializer]];
	
	[[[B2WAPIClient sharedClient] operationQueue] addOperation:op];
	
	return op;
}

+ (void)storeUsername:(NSString *)username password:(NSString *)password userInfo:(NSDictionary *)userInfo
{
	[B2WAPIAccount setUsername:username];
	[B2WAPIAccount setPassword:password];
	
    [UICKeyChainStore setData:[NSKeyedArchiver archivedDataWithRootObject:userInfo]
					   forKey:B2WAPIAuthKeychainUserInfoKey];
	
    [UICKeyChainStore setData:[NSKeyedArchiver archivedDataWithRootObject:[[NSDate date] dateByAddingTimeInterval:kAuthTokenExpirationTimeInterval]]
                       forKey:B2WAPIAuthKeychainTokenExpirationDateKey];
}

+ (void)loginWithUsername:(NSString*)username password:(NSString*)password token:(NSString*)token
{
    [B2WAPIAccount storeUsername:username password:password userInfo:@{@"token":token}];
}

+ (void)logout
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [B2WAPIPush setDeviceToken:nil];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setBool:NO forKey:kUSER_DEFAULTS_PUSH_NOTIFICATION_SETTINGS];
    [standardDefaults synchronize];
    
    NSString *username = [B2WAPIAccount username];
    NSString *B2WUID = [B2WAPIAccount B2WUID];
    [UICKeyChainStore removeAllItems];
    
    if (username)
    {
        [UICKeyChainStore setString:username forKey:B2WAPIAuthKeychainLastUsernameKey];
    }
	
    if (B2WUID)
    {
        [B2WAPIAccount setB2WUID:B2WUID];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserSignedOut" object:nil];
}

+ (AFHTTPRequestOperation*)requestPasswordRetrievalForUsernamed:(NSString *)username
														  block:(B2WAPICompletionBlock)block
{
	if (username == nil || username.length == 0 ||
	   block == nil)
	{
		return nil;
	}
	
	if ([B2WAPIAccount isLoggedIn] && block)
	{
		block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
									   code:B2WAPIAlreadyLoggedInError
								   //userInfo:@{NSLocalizedDescriptionKey: @"There's an user already logged in. You must logout first."}]);
								   userInfo:@{NSLocalizedDescriptionKey: @"Já existe um usuário conectado. Você deve sair primeiro."}]);
	}
	
	NSString *path;
	if ([[B2WAPIAccount _manager] _stagingEnabled])
	{
		path = @"http://checkout:@bentley:8080/AccountRest-v3/account";
	}
	else
	{
		path = [NSURL URLStringWithSubdomain:@"carrinho"
									 options:B2WAPIURLOptionsAddCorporateKey | B2WAPIURLOptionsUsesHTTPS
									    //path:@"api/v3/account"];
										path:@"account-v3/account"];
	}
	
	AFHTTPRequestOperation *op = [[B2WAPIClient sharedClient] GET:[path stringByAppendingFormat:@"/%@/retrieve-password", username] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		block(responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		//
		// Checks if the API returned an error message
		//
		if (error && ![error.domain isEqualToString:NSURLErrorDomain])
		{
			NSString *responseString = operation.responseString;
			
			NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
			NSError *e;
			id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
			
			if (e)
			{
				block(nil, error);
				return;
			}
			if (response)
			{
				block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
											   code:B2WAPIServiceError
										   userInfo:@{NSLocalizedDescriptionKey : response}]);
			}
		}
		else
		{
			block(nil, error);
			return;
		}
	}];
	
	[op setResponseSerializer:[AFJSONResponseSerializer serializer]];
	
	return op;
}

+ (AFHTTPRequestOperation*)updatePasswordForUserNamed:(NSString *)username
										  newPassword:(NSString *)newPassword
												block:(B2WAPICompletionBlock)block

{
	if (username == nil || username.length == 0 ||
	   block == nil)
	{
		return nil;
	}
	
	NSString *path;
	if ([[B2WAPIAccount _manager] _stagingEnabled])
	{
		path = @"http://checkout:@bentley:8080/AccountRest-v3/account";
	}
	else
	{
		path = [NSURL URLStringWithSubdomain:@"carrinho"
									 options:B2WAPIURLOptionsAddCorporateKey | B2WAPIURLOptionsUsesHTTPS
									    //path:@"api/v3/account"];
										path:@"account-v3/account"];
	}

	path = [path stringByAppendingFormat:@"/%@/password", username];
	
	NSString *authToken = [B2WAPIAccount token];
	NSDictionary *queryParams = @{@"token":authToken};
	
	NSDictionary *params = @{@"password":[self password], @"newPassword":newPassword};
	
	// TODO: testar implementacao abaixo
	if (queryParams.count > 0)
	{
		path = [path stringByAppendingString:@"?"];
		
		NSArray *keys = [queryParams allKeys];
		
		for (int i = 0; i < queryParams.count; i++)
		{
			path = [path stringByAppendingFormat:@"%@=%@", keys[i], queryParams[keys[i]]];
			if (i < queryParams.count-1)
			{
				path = [path stringByAppendingString:@"&"];
			}
		}
	}
	
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
	NSString *jsonParams = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	
	NSLog(@"[B2WAPIAccount] jsonParams = %@", jsonParams);
	
	NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"PUT"
																				 URLString:path
																				parameters:params
																					 error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		block(responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		//
		// Checks if the API returned an error message
		//
		if (error && ![error.domain isEqualToString:NSURLErrorDomain])
		{
			NSString *responseString = operation.responseString;
			
			NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
			NSError *e;
			id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
			
			if (e)
			{
				block(nil, error);
				return;
			}
			if (response)
			{
				block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
											   code:B2WAPIServiceError
										   userInfo:@{NSLocalizedDescriptionKey : response}]);
			}
		}
		else
		{
			block(nil, error);
			return;
		}
	}];
	
	[op setResponseSerializer:[AFJSONResponseSerializer serializer]];
	
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];

	return op;
}

+ (AFHTTPRequestOperation*)updateUsernameForUserNamed:(NSString *)username
										  newUsername:(NSString *)newUsername
												block:(B2WAPICompletionBlock)block

{
	if (username == nil || username.length == 0 ||
	   block == nil)
	{
		return nil;
	}
	
	NSString *path;
	if ([[B2WAPIAccount _manager] _stagingEnabled])
	{
		path = @"http://checkout:@bentley:8080/AccountRest-v3/account";
	}
	else
	{
		path = [NSURL URLStringWithSubdomain:@"carrinho"
									 options:B2WAPIURLOptionsAddCorporateKey | B2WAPIURLOptionsUsesHTTPS
								        //path:@"api/v3/account"];
										path:@"account-v3/account"];
	}
	
	path = [path stringByAppendingFormat:@"/%@", username];
	
	NSString *authToken = [B2WAPIAccount token];
	NSDictionary *queryParams = @{@"token":authToken};
	
	NSDictionary *params = @{@"password":[self password], @"newId":newUsername};
	
	// TODO: testar implementacao abaixo
	if (queryParams.count > 0)
	{
		path = [path stringByAppendingString:@"?"];
		
		NSArray *keys = [queryParams allKeys];
		
		for (int i = 0; i < queryParams.count; i++)
		{
			path = [path stringByAppendingFormat:@"%@=%@", keys[i], queryParams[keys[i]]];
			if (i < queryParams.count-1)
			{
				path = [path stringByAppendingString:@"&"];
			}
		}
	}
	
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
	NSString *jsonParams = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	
	NSLog(@"[B2WAPIAccount] jsonParams = %@", jsonParams);
	
	NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"PUT"
																				 URLString:path
																				parameters:params
																					 error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		block(responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		//
		// Checks if the API returned an error message
		//
		if (error && ![error.domain isEqualToString:NSURLErrorDomain])
		{
			NSString *responseString = operation.responseString;
			
			NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
			NSError *e;
			id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
			
			if (e)
			{
				block(nil, error);
				return;
			}
			if (response)
			{
				block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
											   code:B2WAPIServiceError
										   userInfo:@{NSLocalizedDescriptionKey : response}]);
			}
		}
		else
		{
			block(nil, error);
			return;
		}
	}];
	
	[op setResponseSerializer:[AFJSONResponseSerializer serializer]];
	
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];
	
	return op;
}

@end
