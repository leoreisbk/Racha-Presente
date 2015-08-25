//
//  B2WAPICart.m
//  Americanas
//
//  Created by Eduardo Callado on 3/18/15.
//  Copyright (c) 2015 Ideais. All rights reserved.
//

#import "B2WAPICart.h"

#import "B2WAPIClient.h"
#import "NSURL+B2WKit.h"
#import "NSDictionary+B2WKit.h"
#import "AFHTTPRequestOperation+B2WKit.h"
#import "B2WAccountManager.h"
#import "B2WAPIAccount.h"

#define B2WAPIKeychainCartIDKey @"B2WCartIDKey"

NSString *const B2WAPICartErrorDomain = @"B2WAPICartErrorDomain";

@implementation B2WAPICart

NSString *const B2WAPICartPath = @"/api/v2/cart";

+ (NSString *)cartID
{
	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
	return [standardDefaults objectForKey:B2WAPIKeychainCartIDKey];
}

+ (void)setCartID:(NSString *)cartID
{
	if (cartID == nil)
	{
		return;
	}
	
	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
	[standardDefaults setValue:cartID forKey:B2WAPIKeychainCartIDKey];
	[standardDefaults synchronize];
}

+ (void)resetCartID
{
	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
	[standardDefaults removeObjectForKey:B2WAPIKeychainCartIDKey];
	[standardDefaults synchronize];
}

+ (NSString *)createURL
{
	NSString *baseURLString = [B2WAPIClient baseURLString];
	NSString *URLString = [baseURLString stringByAppendingString:B2WAPICartPath];
	URLString = [URLString stringByReplacingOccurrencesOfString:@"www" withString:@"sacola"];
	URLString = [URLString stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
	return URLString;
}

+ (void)handleRequestError:(NSError *)error operation:(AFHTTPRequestOperation *)operation withBlock:(B2WAPICompletionBlock)block
{
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
}

+ (AFHTTPRequestOperation*)requestCreateNewCartWithBlock:(B2WAPICompletionBlock)block
{
	NSString *URLString = [B2WAPICart createURL];
	
	NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
																				 URLString:URLString
																				parameters:@{}
																					 error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString *cartID = operation.response.allHeaderFields[@"Location"];
		NSLog(@"[CART] New Cart ID = %@", cartID);
		[B2WAPICart setCartID:cartID];
		
		if ([B2WAPIAccount isLoggedIn])
		{
			B2WCartCustomer *cartCustomer = [[B2WCartCustomer alloc] initWithIdentifier:[B2WAccountManager currentCustomer].identifier
																				  token:[B2WAPIAccount token]];
			
			[B2WAPICart requestUpdateCartWithCustomer:cartCustomer block:^(id object, NSError *error) {
				[B2WAPICart requestCartWithBlock:^(B2WCart *cart, NSError *error) {
					NSLog(@"[CART] Cart with customer = %@\n\n\n", cart.description);
				}];
			}];
		}
		
		block(responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[B2WAPICart handleRequestError:error operation:operation withBlock:block];
	}];
	
	AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
	op.responseSerializer = responseSerializer;
	
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];
	
	return op;
}

+ (AFHTTPRequestOperation*)requestCartWithBlock:(B2WAPICompletionBlock)block
{
	NSString *URLString = [B2WAPICart createURL];
	
	if ([B2WAPICart cartID])
	{
		URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@", [B2WAPICart cartID]]];
	}
	else
	{
		// TODO: Create new cart
		
		return nil;
	}
	
	NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
																				 URLString:URLString
																				parameters:@{}
																					 error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		B2WCart *cart = [[B2WCart alloc] initWithCartDictionary:responseObject];
		block(cart, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[B2WAPICart handleRequestError:error operation:operation withBlock:block];
	}];
	
	AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
	op.responseSerializer = responseSerializer;
	
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];
	
	return op;
}

+ (AFHTTPRequestOperation *)addProductRequestOperation:(B2WCartProduct *)product
{
    NSString *URLString = [B2WAPICart createURL];
    
    if ([B2WAPICart cartID])
    {
        URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@/line", [B2WAPICart cartID]]];
    }
    else
    {
        // TODO: Create new cart
        
        return nil;
    }
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:URLString
                                                                                parameters:[product dictionaryValue]
                                                                                     error:nil];
    
    return [[AFHTTPRequestOperation alloc] initWithRequest:request];
}

+ (AFHTTPRequestOperation*)requestAddProduct:(B2WCartProduct *)product
                                       block:(B2WAPICompletionBlock)block
{
    AFHTTPRequestOperation *op = [B2WAPICart addProductRequestOperation:product];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [B2WAPICart handleRequestError:error operation:operation withBlock:block];
    }];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation*)requestAddProducts:(NSArray *)products
                                        block:(B2WAPICompletionBlock)block
{
    NSMutableArray *requestOperations = [[NSMutableArray alloc] initWithCapacity:products.count];
    
    for (B2WCartProduct *product in products) {
        AFHTTPRequestOperation *operation = [B2WAPICart addProductRequestOperation:product];
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        operation.responseSerializer = responseSerializer;
        [requestOperations addObject:operation];
    }
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:requestOperations progressBlock:nil completionBlock:^(NSArray *operations) {
        NSError *error;
        for (AFHTTPRequestOperation *operation in operations)
        {
            if (operation.error)
            {
                error = operation.error;
                break;
            }
        }
        if (block)
        {
            if (error)
            {
                block(nil, error);
            }
            else
            {
                block(operations, nil);
            }
        }
    }];
    
    [[B2WAPIClient sharedClient].operationQueue addOperations:operations waitUntilFinished:NO];
    
    return operations;
}

+ (AFHTTPRequestOperation *)requestUpdateProduct:(B2WCartProduct *)product
										   block:(B2WAPICompletionBlock)block
{
	NSString *URLString = [B2WAPICart createURL];
	
	NSString *lineID = product.lineId;
	
	if ([B2WAPICart cartID] && lineID)
	{
		URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@/line/%@", [B2WAPICart cartID], lineID]];
	}
	else
	{
		// TODO: Create new cart
		
		return nil;
	}
	
	NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
																				 URLString:URLString
																				parameters:[product dictionaryValue]
																					 error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		block(responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[B2WAPICart handleRequestError:error operation:operation withBlock:block];
	}];
	
	AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
	op.responseSerializer = responseSerializer;
	
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];
	
	return op;
}

+ (AFHTTPRequestOperation *)requestRemoveProduct:(B2WCartProduct *)product
										   block:(B2WAPICompletionBlock)block
{
	NSString *URLString = [B2WAPICart createURL];
	
	NSString *lineID = product.lineId;
	
	if ([B2WAPICart cartID] && lineID)
	{
		URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@/line/%@", [B2WAPICart cartID], lineID]];
	}
	else
	{
		// TODO: Create new cart
		
		return nil;
	}
	
	NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"DELETE"
																				 URLString:URLString
																				parameters:nil
																					 error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		block(responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[B2WAPICart handleRequestError:error operation:operation withBlock:block];
	}];
	
	AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
	op.responseSerializer = responseSerializer;
	
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];
	
	return op;
}

+ (AFHTTPRequestOperation *)requestUpdateCartWithCustomer:(B2WCartCustomer *)customer
													block:(B2WAPICompletionBlock)block
{
	NSString *URLString = [B2WAPICart createURL];
	if ([B2WAPICart cartID])
	{
		URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@", [B2WAPICart cartID]]];
	}
	else
	{
		// TODO: Create new cart
		
		return nil;
	}
	
	NSDictionary *parameters = customer ? @{@"customer" : [customer dictionaryValue]} :
	@{@"customer" : [B2WCartCustomer emptyDictionaryValue]};
	NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
																				 URLString:URLString
																				parameters:parameters
																					 error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		block(responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[B2WAPICart handleRequestError:error operation:operation withBlock:block];
	}];
	
	AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
	op.responseSerializer = responseSerializer;
	
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];
	
	return op;
}

+ (AFHTTPRequestOperation *)requestRemoveCustomerFromCartWithBlock:(B2WAPICompletionBlock)block
{
	return [B2WAPICart requestUpdateCartWithCustomer:nil block:block];
}

#pragma mark - Coupon

+ (AFHTTPRequestOperation *)requestAddCouponWithID:(NSString *)couponID block:(B2WAPICompletionBlock)block
{
	//NSString *URLString = [NSURL URLStringWithSubdomain:@"sacola" options:B2WAPIURLOptionsUsesHTTPS path:@"api/v2/cart/%@/coupon/%@", [B2WAPICart cartID], couponID];
	
	NSString *URLString = [B2WAPICart createURL];
	
	NSString *encodedCouponID = [B2WKitUtils stringByAddingPercentEscapes:couponID];
	
	if ([B2WAPICart cartID])
	{
		URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@/coupon/%@", [B2WAPICart cartID], encodedCouponID]];
	}
	else
	{
		// TODO: Create new cart
		
		return nil;
	}
	
	NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"PUT" URLString:URLString parameters:nil error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (block) {
			block(nil, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (error && ![error.domain isEqualToString:NSURLErrorDomain]) {
			NSString *responseString = operation.responseString;
			
			NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
			NSError *e;
			id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
			
			if (e) {
				block(nil, error);
				return;
			} else if (responseObject) {
				if ([responseObject isKindOfClass:[NSDictionary class]]) {
					NSDictionary *response = (NSDictionary *)responseObject;
					
					if ([response containsObjectForKey:@"additionalInfo"] &&
						[response[@"additionalInfo"] isKindOfClass:[NSArray class]])
					{
						NSArray *additionalInfo = (NSArray *)response[@"additionalInfo"];
						
						if ([[additionalInfo firstObject] isDictionaryWithPairs:@{@"key": @"COUPON_ERROR", @"value": @"EXPIRED"}]) {
							block(nil, [NSError errorWithDomain:B2WAPICartErrorDomain code:B2WAPICartErrorCouponExpired userInfo:nil]);
							return;
						}
						
						if ([[additionalInfo firstObject] isDictionaryWithPairs:@{@"key": @"COUPON_ERROR", @"value": @"NOT_FOUND"}]) {
							block(nil, [NSError errorWithDomain:B2WAPICartErrorDomain code:B2WAPICartErrorCouponNotFound userInfo:nil]);
							return;
						}
						
						if ([[additionalInfo firstObject] isDictionaryWithPairs:@{@"key": @"COUPON_ERROR", @"value": @"USED"}]) {
							block(nil, [NSError errorWithDomain:B2WAPICartErrorDomain code:B2WAPICartErrorCouponUsed userInfo:nil]);
							return;
						}
						
						block(nil, [NSError errorWithDomain:B2WAPICartErrorDomain code:B2WAPICartErrorCouponGeneric userInfo:nil]);
						return;
					}
				} else {
					block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
												   code:B2WAPIServiceError
											   userInfo:@{NSLocalizedDescriptionKey : responseObject}]);
					return;
				}
			}
		} else {
			block(nil, error);
			return;
		}
	}];
	
	[op setResponseSerializer:[AFJSONResponseSerializer serializer]];
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];
	
	return op;
}

+ (AFHTTPRequestOperation *)requestRemoveCouponWithBlock:(B2WAPICompletionBlock)block
{
	//NSString *URLString = [NSURL URLStringWithSubdomain:@"sacola" options:B2WAPIURLOptionsUsesHTTPS path:@"api/v2/cart/%@/coupon", [B2WAPICart cartID]];
	
	NSString *URLString = [B2WAPICart createURL];
	if ([B2WAPICart cartID])
	{
		URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@/coupon", [B2WAPICart cartID]]];
	}
	else
	{
		// TODO: Create new cart
		
		return nil;
	}
	
	NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"DELETE" URLString:URLString parameters:nil error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (block) {
			block(nil, nil);
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
			block(nil, error);
			return;
		}
	}];
	
	[op setResponseSerializer:[AFJSONResponseSerializer serializer]];
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];
	
	return op;
}

+ (AFHTTPRequestOperation *)requestGetCouponWithBlock:(B2WAPICompletionBlock)block
{
	//NSString *URLString = [NSURL URLStringWithSubdomain:@"sacola" options:B2WAPIURLOptionsUsesHTTPS path:@"api/v2/cart/%@/coupon", [B2WAPICart cartID]];
	
	NSString *URLString = [B2WAPICart createURL];
	if ([B2WAPICart cartID])
	{
		URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@/coupon", [B2WAPICart cartID]]];
	}
	else
	{
		// TODO: Create new cart
		
		return nil;
	}
	
	NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:URLString parameters:nil error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (block) {
			block(responseObject, nil);
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
			block(nil, error);
			return;
		}
	}];
	
	[op setResponseSerializer:[AFJSONResponseSerializer serializer]];
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];
	
	return op;
}

#pragma mark - OPN/EPar

+ (AFHTTPRequestOperation *)requestAddOPNEParWithblock:(B2WAPICompletionBlock)block
{
	NSString *URLString = [B2WAPICart createURL];
	
	if ([B2WAPICart cartID])
	{
		URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@", [B2WAPICart cartID]]];
	}
	else
	{
		// TODO: Create new cart

		block(nil, nil);
		
		return nil;
	}
	
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	
	if ([B2WAPIClient OPNString] != nil || [B2WAPIClient OPNString].length > 0)
	{
		// NSString *encodedOPN = [B2WKitUtils stringByAddingPercentEscapes:[B2WAPIClient OPNString]];
		[parameters setValue:[B2WAPIClient OPNString] forKey:@"opn"];
	}
	
	if ([B2WAPIClient EPARString] != nil || [B2WAPIClient EPARString].length > 0)
	{
		// NSString *encodedEPar = [B2WKitUtils stringByAddingPercentEscapes:[B2WAPIClient EPARString]];
		[parameters setValue:[B2WAPIClient EPARString] forKey:@"epar"];
	}
	
	NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
																		  URLString:URLString
																		 parameters:parameters
																			  error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (block) {
			block(responseObject, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (error && ![error.domain isEqualToString:NSURLErrorDomain]) {
			NSString *responseString = operation.responseString;
			
			NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
			NSError *e;
			id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
			
			if (e) {
				block(nil, error);
				return;
			} else if (responseObject) {
				if ([responseObject isKindOfClass:[NSDictionary class]]) {
					NSDictionary *response = (NSDictionary *)responseObject;
					
					if ([response containsObjectForKey:@"additionalInfo"] &&
						[response[@"additionalInfo"] isKindOfClass:[NSArray class]])
					{
						NSArray *additionalInfo = (NSArray *)response[@"additionalInfo"];
						
						//
						// Checks if the API returned an error message
						//
					}
				} else {
					block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
												   code:B2WAPIServiceError
											   userInfo:@{NSLocalizedDescriptionKey : responseObject}]);
					return;
				}
			}
		} else {
			block(nil, error);
			return;
		}
	}];
	
	[op setResponseSerializer:[AFJSONResponseSerializer serializer]];
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];
	
	return op;
}

#pragma mark - New API Methods

+ (AFHTTPRequestOperation*)createCartWithBlock:(B2WAPICompletionBlock)block
{
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	
	if ([B2WAPIClient OPNString] != nil || [B2WAPIClient OPNString].length > 0)
	{
		// NSString *encodedOPN = [B2WKitUtils stringByAddingPercentEscapes:[B2WAPIClient OPNString]];
		[parameters setValue:[B2WAPIClient OPNString] forKey:@"opn"];
	}
	
	if ([B2WAPIClient EPARString] != nil || [B2WAPIClient EPARString].length > 0)
	{
		// NSString *encodedEPar = [B2WKitUtils stringByAddingPercentEscapes:[B2WAPIClient EPARString]];
		[parameters setValue:[B2WAPIClient EPARString] forKey:@"epar"];
	}
	
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:[B2WAPICart createURL]
                                                                                parameters:parameters
                                                                                     error:nil];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *cartID = operation.response.allHeaderFields[@"Location"];
        if (block) block(cartID, nil);
    } failure:[B2WAPIClient defaultAPIFailureBlockWithBlock:block]];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation*)cartWithID:(NSString *)cartID block:(B2WAPICompletionBlock)block
{
    NSString *URLString = [[B2WAPICart createURL] stringByAppendingString:[NSString stringWithFormat:@"/%@", cartID]];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:URLString
                                                                                parameters:@{}
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        B2WCart *cart = [[B2WCart alloc] initWithCartDictionary:responseObject];
        if (block) block(cart, nil);
    } failure:[B2WAPIClient defaultAPIFailureBlockWithBlock:block]];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation *)addProduct:(B2WCartProduct *)product cartID:(NSString *)cartID block:(B2WAPICompletionBlock)block
{
    NSString *URLString = [[B2WAPICart createURL] stringByAppendingString:[NSString stringWithFormat:@"/%@/line", cartID]];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:URLString
                                                                                parameters:[product dictionaryValue]
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block) block(responseObject, nil);
    } failure:[B2WAPIClient defaultAPIFailureBlockWithBlock:block]];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation *)setCustomer:(B2WCartCustomer *)customer cartID:(NSString *)cartID block:(B2WAPICompletionBlock)block
{
    NSString *URLString = [[B2WAPICart createURL] stringByAppendingString:[NSString stringWithFormat:@"/%@", cartID]];
    
    NSDictionary *parameters = customer ? @{@"customer" : [customer dictionaryValue]} :
    @{@"customer" : [B2WCartCustomer emptyDictionaryValue]};
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:URLString
                                                                                parameters:parameters
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block) block(responseObject, nil);
    } failure:[B2WAPIClient defaultAPIFailureBlockWithBlock:block]];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

@end
