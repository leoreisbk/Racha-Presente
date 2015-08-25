//
//  B2WAPICustomer.m
//  B2WKit
//
//  Created by Thiago Peres on 15/04/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WAPICustomer.h"
#import "NSURL+B2WKit.h"
#import "B2WAPIAccount.h"
#import "B2WCustomer.h"
#import "B2WOneClickRelationship.h"
#import "B2WCreditCard.h"
#import "B2WAddress.h"
#import "B2WKitUtils.h"

static int const kMaxNumberOfTokenRenewalAttempts = 5;

typedef NS_ENUM(NSInteger, B2WAPICustomerOptions)
{
    B2WAPICustomerOptionsUsesAuthToken = (1 << 0)
};

@implementation B2WAPICustomer

BOOL _stagingEnabled;
BOOL _persistenceEnabled = YES;

+ (void)setStaging:(BOOL)staging
{
    _stagingEnabled = staging;
}

+ (BOOL)isStaging
{
	return _stagingEnabled;
}

+ (void)setPersistenceEnabled:(BOOL)shouldPersist
{
    _persistenceEnabled = shouldPersist;
}

NSString * _B2WAPIGetCustomerResourceTypeString(B2WAPICustomerResource resourceType)
{
    switch (resourceType)
    {
        case B2WAPICustomerResourceNone:
            return nil;
            break;
        case B2WAPICustomerResourceAddress:
            return @"address";
            break;
		case B2WAPICustomerResourceAddressAsMain:
			return @"address";
			break;
		case B2WAPICustomerResourceCreditCard:
            return @"credit-card";
            break;
		case B2WAPICustomerResourceCreditCardAssociate:
			return @"credit-card";
			break;
		case B2WAPICustomerResourceOneClick:
            return @"one-click";
            break;
        default:
            return nil;
            break;
    }
    
    return nil;
}

+ (AFHTTPRequestOperation*)_requestWithMethod:(NSString *)httpMethod
                                     username:(NSString *)username
                                     resource:(B2WAPICustomerResource)resourceType
                           resourceIdentifier:(NSString *)resourceIdentifier
                                   parameters:(NSDictionary *)parameters
                                      options:(B2WAPICustomerOptions)options
                                        block:(B2WAPICompletionBlock)block
{
    return [self _requestWithMethod:httpMethod
						   username:username
						   resource:resourceType
				 resourceIdentifier:resourceIdentifier
						 parameters:parameters
							options:options
							  block:block
				tokenRenewalAttempt:1];
}

+ (AFHTTPRequestOperation*)_requestWithMethod:(NSString *)httpMethod
                                     username:(NSString *)username
                                     resource:(B2WAPICustomerResource)resourceType
                           resourceIdentifier:(NSString *)resourceIdentifier
                                   parameters:(NSDictionary *)parameters
                                      options:(B2WAPICustomerOptions)options
                                        block:(B2WAPICompletionBlock)block
                          tokenRenewalAttempt:(int)tokenRenewalAttempt
{
    //
    // Build request URL
    //
    NSString *resourceTypeString = _B2WAPIGetCustomerResourceTypeString(resourceType);
    NSString *path;
    
	if (_stagingEnabled)
	{
		path = @"http://checkout:@bentley:8080/CustomerRest-v5/customer";
	}
	else
	{
		if ([[B2WKitUtils mainAppDisplayName] isEqualToString:@"Shoptime"])
		{
			path = [NSURL URLStringWithSubdomain:@"carrinho" options:B2WAPIURLOptionsAddCorporateKey | B2WAPIURLOptionsUsesHTTPS
											path:@"api/v5/customer"];
		}
		else
		{
			path = [NSURL URLStringWithSubdomain:@"sacola" options:B2WAPIURLOptionsAddCorporateKey | B2WAPIURLOptionsUsesHTTPS
											path:@"api/v5/customer"];
		}
	}
	
	path = username == nil ? path : [path stringByAppendingFormat:@"/%@", username];
    path = resourceTypeString == nil ? path : [path stringByAppendingFormat:@"/%@", resourceTypeString];
	if (resourceTypeString) path = resourceIdentifier == nil ? path : [path stringByAppendingFormat:@"/%@", resourceIdentifier];
	
	if (resourceType == B2WAPICustomerResourceAddressAsMain)
	{
		path = [path stringByAppendingFormat:@"/main"];
	}
	
	if (resourceType == B2WAPICustomerResourceCreditCardAssociate)
	{
		path = [path stringByAppendingFormat:[NSString stringWithFormat:@"/%@/actions/associate-address", parameters[@"creditCardId"]]];
		
		NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:parameters];
		[newDict removeObjectForKey:@"creditCardId"];
		parameters = newDict;
	}
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters];
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];

	if (options & B2WAPICustomerOptionsUsesAuthToken)
    {
        if ([B2WAPIAccount token] && ![B2WAPIAccount tokenExpired]) {
            if ([httpMethod isEqualToString:@"GET"])
            {
                params[@"token"] = [B2WAPIAccount token];
            }
            else
            {
                queryParams[@"token"] = [B2WAPIAccount token];
            }
        } else if ([B2WAPIAccount token] && [B2WAPIAccount tokenExpired]) {
            NSLog(@"[*] Token expired, requesting new one... (attempt no.: %d)", tokenRenewalAttempt);
            // Renew token (and every other user info)
            [B2WAPIAccount _loginWithUsername:[B2WAPIAccount username] password:[B2WAPIAccount password] block:^(id object, NSError *error) {
                if (error) {
                    NSLog(@"[*] Failed to get a new token: %@", error);
                    // This method is called recursively if the token expires, so we limit the max number of token renewal attempts
                    if (tokenRenewalAttempt > kMaxNumberOfTokenRenewalAttempts) {
                        block(nil, error);
                    } else {
                        int nextAttempt = tokenRenewalAttempt + 1;
                        [self _requestWithMethod:httpMethod username:username resource:resourceType resourceIdentifier:resourceIdentifier parameters:parameters options:options block:block tokenRenewalAttempt:nextAttempt];
                    }
                } else {
                    NSLog(@"[*] New token obtained successfully: %@", object[@"token"]);
                    [self _requestWithMethod:httpMethod username:username resource:resourceType resourceIdentifier:resourceIdentifier parameters:parameters options:options block:block];
                }
            }];
            
            return nil;
        } else if (![B2WAPIAccount token]) {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInternalInconsistencyError
                                       userInfo:@{NSLocalizedDescriptionKey: @"Authentication token not found."}]);
            return nil;
        }
    }
    
    if (!_persistenceEnabled)
    {
        if ([httpMethod isEqualToString:@"GET"])
        {
            params[@"persist"] = @"false";
        }
        else
        {
            queryParams[@"persist"] = @"false";
        }
    }
	else
    {
        if ([httpMethod isEqualToString:@"GET"])
        {
            params[@"persist"] = @"true";
        }
        else
        {
            queryParams[@"persist"] = @"true";
        }
    }
    
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
	
	NSLog(@"[B2WAPICustomer] jsonParams = %@", jsonParams);
	
	NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:httpMethod
																				 URLString:path
																				parameters:params
																					 error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (block)
		{
			NSArray *parsedResponseArray;
			NSArray *handledResponse;
			if ([responseObject isKindOfClass:[NSDictionary class]])
			{
				handledResponse = @[responseObject];
			}
			else
			{
				handledResponse = responseObject;
			}
			
			// Parse response according to resource type
			switch (resourceType)
			{
				case B2WAPICustomerResourceAddress:
					// TODO: Refact
					if ([[handledResponse.firstObject allKeys] containsObject:@"addresses"])
					{
						parsedResponseArray = [B2WAddress objectsWithDictionaryArray:handledResponse[0][@"addresses"]];
					}
					else
					{
						parsedResponseArray = [B2WAddress objectsWithDictionaryArray:handledResponse];
					}
					break;
				case B2WAPICustomerResourceAddressAsMain:
					parsedResponseArray = [B2WAddress objectsWithDictionaryArray:handledResponse];
					break;
				case B2WAPICustomerResourceCreditCard:
                    parsedResponseArray = [B2WCreditCard objectsWithDictionaryArray:handledResponse];
                    break;
				case B2WAPICustomerResourceCreditCardAssociate:
					parsedResponseArray = [B2WCreditCard objectsWithDictionaryArray:handledResponse];
					break;
				case B2WAPICustomerResourceOneClick:
                    parsedResponseArray = [B2WOneClickRelationship objectsWithDictionaryArray:handledResponse];
                    break;
                case B2WAPICustomerResourceNone:
                    parsedResponseArray = [B2WCustomer objectsWithDictionaryArray:handledResponse];
                    break;
                default:
                {
                    block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                                   code:B2WAPIInvalidResponseError
                                               userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The server response was not detected as a valid /customer resource (address, credit-card, one-click or customer) Response: %@", responseObject]}]);
                    return;
                }
                    break;
            }
			
            block(parsedResponseArray, nil);
        }
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
			//[B2WAPIClient errorBlockWithBlock:block];
			block(nil, error);
			
			return;
		}
    }];
	
    [op setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation*)requestWithMethod:(NSString*)httpMethod
                                    resource:(B2WAPICustomerResource)resourceType
                          resourceIdentifier:(NSString*)resourceIdentifier
                                  parameters:(NSDictionary*)parameters
                                       block:(B2WAPICompletionBlock)block
{
    AFHTTPRequestOperation *op = [B2WAPICustomer _requestWithMethod:httpMethod
                                                           username:[B2WAPIAccount userIdentifier]
                                                           resource:resourceType
                                                 resourceIdentifier:resourceIdentifier
                                                         parameters:parameters
                                                            options:B2WAPICustomerOptionsUsesAuthToken
                                                              block:block];
    
    return op;
}

+ (AFHTTPRequestOperation*)createCustomerWithCustomerDictionary:(NSDictionary *)customer block:(B2WAPICompletionBlock)block
{
    if (customer == nil || customer.count <= 0)
    {
        return nil;
    }
    
    AFHTTPRequestOperation *op = [B2WAPICustomer _requestWithMethod:@"POST"
                                                           username:nil
                                                           resource:B2WAPICustomerResourceNone
                                                 resourceIdentifier:nil
                                                         parameters:customer
                                                            options:0
                                                              block:^(id object, NSError *error) {
                                                                  if (error)
                                                                  {
                                                                      block(nil, error);
                                                                      return;
                                                                  }
                                                                  block(object, nil);
                                                              }];
    
    return op;
}

@end
