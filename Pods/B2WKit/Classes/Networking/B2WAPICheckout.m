//
//  B2WAPICheckout.m
//  B2WKit
//
//  Created by Eduardo Callado on 3/25/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WAPICheckout.h"
#import "B2WAPICart.h"
#import "B2WKitUtils.h"
#import "B2WVoucher.h"
#import "AFHTTPRequestOperation+B2WKit.h"

#define B2WAPIKeychainCheckoutIDKey @"B2WCheckoutIDKey"

NSString *const B2WAPICheckoutErrorDomain = @"B2WAPICheckoutErrorDomain";

@implementation B2WAPICheckout

NSString *const B2WAPICheckoutPath = @"/api/v1/checkout";

+ (NSString *)checkoutID
{
	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    return [standardDefaults objectForKey:B2WAPIKeychainCheckoutIDKey];
}

+ (void)setCheckoutID:(NSString *)checkoutID
{
    if (checkoutID == nil)
    {
        return;
    }
	
	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setValue:checkoutID forKey:B2WAPIKeychainCheckoutIDKey];
    [standardDefaults synchronize];
}

+ (void)resetCheckoutID
{
	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
	[standardDefaults removeObjectForKey:B2WAPIKeychainCheckoutIDKey];
	[standardDefaults synchronize];
}

+ (NSString *)createURL
{
    NSString *baseURLString = [B2WAPIClient baseURLString];
    NSString *URLString = [baseURLString stringByAppendingString:B2WAPICheckoutPath];
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

+ (AFHTTPRequestOperation*)requestCreateNewCheckoutWithBlock:(B2WAPICompletionBlock)block
{
    if (! [B2WAPICart cartID])
	{
		// TODO: Create new cart
		
		return nil;
	}
    
    NSString *URLString = [B2WAPICheckout createURL];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:URLString
                                                                                parameters:@{@"cartId" : [B2WAPICart cartID]}
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *checkoutID = operation.response.allHeaderFields[@"Location"];
        NSLog(@"[B2WAPICheckout] New Checkout ID = %@", checkoutID);
        [B2WAPICheckout setCheckoutID:checkoutID];
        
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [B2WAPICheckout handleRequestError:error operation:operation withBlock:block];
    }];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation*)createCheckoutWithCartID:(NSString *)cartID block:(void (^)(NSString *checkoutID, NSError *error))block
{
    NSString *URLString = [B2WAPICheckout createURL];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:URLString
                                                                                parameters:@{@"cartId" : cartID}
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *checkoutID = operation.response.allHeaderFields[@"Location"];
        block(checkoutID, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
    }];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation*)requestCheckoutWithBlock:(B2WAPICompletionBlock)block
{
    NSString *URLString = [B2WAPICheckout createURL];
    
    if ([B2WAPICheckout checkoutID])
    {
        URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@", [B2WAPICheckout checkoutID]]];
    }
    else
	{
		// TODO: Create new checkout
		
		return nil;
	}
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:URLString
                                                                                parameters:@{}
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		B2WCheckout *checkout = [[B2WCheckout alloc] initWithCheckoutDictionary:responseObject];
		block(checkout, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [B2WAPICheckout handleRequestError:error operation:operation withBlock:block];
    }];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation *)checkoutWithID:(NSString *)checkoutID block:(void (^)(B2WCheckout *, NSError *))block
{
    NSString *URLString = [[B2WAPICheckout createURL] stringByAppendingString:[NSString stringWithFormat:@"/%@", checkoutID]];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:URLString
                                                                                parameters:@{}
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        B2WCheckout *checkout = [[B2WCheckout alloc] initWithCheckoutDictionary:responseObject];
        if (block) block(checkout, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) block(nil, error);
    }];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation *)requestAddPayment:(NSArray *)parameters
										block:(B2WAPICompletionBlock)block
{
	NSString *URLString = [B2WAPICheckout createURL];
	
	if ([B2WAPICheckout checkoutID])
	{
		URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@/payment", [B2WAPICheckout checkoutID]]];
	}
	else
	{
		// TODO: Create new checkout
		
		return nil;
	}
	
	NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"PUT"
																				 URLString:URLString
																				parameters:parameters
																					 error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		block(responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[B2WAPICheckout handleRequestError:error operation:operation withBlock:block];
	}];
	
	AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
	op.responseSerializer = responseSerializer;
	
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];
	
	return op;
}

+ (AFHTTPRequestOperation *)addPayment:(NSArray *)parameters checkoutID:(NSString *)checkoutID block:(B2WAPICompletionBlock)block
{
    NSString *URLString = [[B2WAPICheckout createURL] stringByAppendingString:[NSString stringWithFormat:@"/%@/payment", checkoutID]];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"PUT"
                                                                                 URLString:URLString
                                                                                parameters:parameters
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [B2WAPICheckout handleRequestError:error operation:operation withBlock:block];
    }];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation *)requestGetVouchersWithBlock:(B2WAPICompletionBlock)block
{
    NSString *URLString = [B2WAPICheckout createURL];
    
    if ([B2WAPICheckout checkoutID])
    {
        URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@/voucher", [B2WAPICheckout checkoutID]]];
    }
    else
	{
		// TODO: Create new checkout
		
		return nil;
	}
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:URLString
                                                                                parameters:nil
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *vouchers = [B2WVoucher objectsWithDictionaryArray:responseObject];
        block(vouchers, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [B2WAPICheckout handleRequestError:error operation:operation withBlock:block];
    }];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation *)requestAddVoucherWithID:(NSString *)voucherID block:(B2WAPICompletionBlock)block
{
    NSString *URLString = [B2WAPICheckout createURL];
    
    NSString *encodedVoucherID = [B2WKitUtils stringByAddingPercentEscapes:voucherID];
    if ([B2WAPICheckout checkoutID])
    {
        URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@/voucher/%@", [B2WAPICheckout checkoutID], encodedVoucherID]];
    }
    else
	{
		// TODO: Create new checkout
		
		return nil;
	}
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:URLString
                                                                                parameters:nil
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        // Checks if the API returned an error message
        //
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
                        
                        if ([[additionalInfo firstObject] isDictionaryWithPairs:@{@"key": @"VOUCHER_ERROR", @"value": @"EXPIRED"}]) {
                            block(nil, [NSError errorWithDomain:B2WAPICheckoutErrorDomain code:B2WAPICheckoutErrorVoucherExpired userInfo:nil]);
                            return;
                        }
                        
                        if ([[additionalInfo firstObject] isDictionaryWithPairs:@{@"key": @"VOUCHER_ERROR", @"value": @"NOT_FOUND"}]) {
                            block(nil, [NSError errorWithDomain:B2WAPICheckoutErrorDomain code:B2WAPICheckoutErrorVoucherNotFound userInfo:nil]);
                            return;
                        }
                        
                        if ([[additionalInfo firstObject] isDictionaryWithPairs:@{@"key": @"VOUCHER_ERROR", @"value": @"USED"}]) {
                            block(nil, [NSError errorWithDomain:B2WAPICheckoutErrorDomain code:B2WAPICheckoutErrorVoucherUsed userInfo:nil]);
                            return;
                        }
                        
                        if ([[additionalInfo firstObject] isDictionaryWithPairs:@{@"key": @"VOUCHER_ERROR", @"value": @"INVALID"}]) {
                            block(nil, [NSError errorWithDomain:B2WAPICheckoutErrorDomain code:B2WAPICheckoutErrorVoucherInvalid userInfo:nil]);
                            return;
                        }
                        
                        if ([[additionalInfo firstObject] isDictionaryWithPairs:@{@"key": @"VOUCHER_ERROR", @"value": @"BLOCKED"}]) {
                            block(nil, [NSError errorWithDomain:B2WAPICheckoutErrorDomain code:B2WAPICheckoutErrorVoucherBlocked userInfo:nil]);
                            return;
                        }
                        
                        block(nil, [NSError errorWithDomain:B2WAPICheckoutErrorDomain code:B2WAPICheckoutErrorVoucherGeneric userInfo:nil]);
                        return;
                    } else if ([response containsObjectForKey:@"message"] &&
							 [response[@"message"] isKindOfClass:[NSString class]]) {
						block(nil, [NSError errorWithDomain:B2WAPICheckoutErrorDomain code:B2WAPICheckoutErrorVoucherAlreadyAdded userInfo:nil]);
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
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation *)requestRemoveVoucherWithID:(NSString *)voucherID block:(B2WAPICompletionBlock)block
{
    NSString *URLString = [B2WAPICheckout createURL];
    
    NSString *encodedVoucherID = [B2WKitUtils stringByAddingPercentEscapes:voucherID];
    if ([B2WAPICheckout checkoutID])
    {
        URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"/%@/voucher/%@", [B2WAPICheckout checkoutID], encodedVoucherID]];
    }
    else
	{
		// TODO: Create new checkout
		
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
        [B2WAPICheckout handleRequestError:error operation:operation withBlock:block];
    }];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

@end
