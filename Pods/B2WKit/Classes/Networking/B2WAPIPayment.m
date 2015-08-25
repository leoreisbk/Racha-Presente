//
//  B2WAPIPayment.m
//  B2WKit
//
//  Created by Eduardo Callado on 8/1/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WAPIPayment.h"
#import "B2WPaymentOption.h"
#import "B2WPaymentOptionProduct.h"


NSString *const B2WAPIPaymentPath = @"/api/v2/payment";
NSString *const B2WAPIPaymentCreditCardPath = @"/api/v2/credit-card";

@implementation B2WAPIPayment

+ (AFHTTPRequestOperation *)requestPaymentsWithPriceTotal:(NSString *)priceTotal
                                               hasVoucher:(BOOL)hasVoucher
                                              hasWarranty:(BOOL)hasWarranty
                                             salesChannel:(NSString *)salesChannel
                                          paymentProducts:(NSArray *)paymentProducts
                                                    block:(B2WAPICompletionBlock)block
{
    if (priceTotal == nil || priceTotal == 0 || salesChannel == nil || paymentProducts == nil || paymentProducts.count == 0 || block == nil)
    {
        return nil;
    }
	
	return [B2WAPIPayment _requestPaymentsWithPriceTotal:priceTotal
											  hasVoucher:hasVoucher
											 hasWarranty:hasWarranty
											salesChannel:salesChannel
										 paymentProducts:paymentProducts block:^(id result, NSError *error) {
											 
          if (error)
          {
              block(nil, error);
          }
          if (result)
          {
              NSArray *paymentDictArray = (NSArray *) result;
              NSMutableArray *paymentArray = [[NSMutableArray alloc] initWithCapacity:paymentDictArray.count];
              for (NSDictionary *result in paymentDictArray) {
                  B2WPaymentOption *paymentOption = [[B2WPaymentOption alloc] initWithPaymentOptionDictionary:result];
                  [paymentArray addObject:paymentOption];
              }
              block(paymentArray, nil);
          }
    }];
}

+ (AFHTTPRequestOperation *)_requestPaymentsWithPriceTotal:(NSString *)priceTotal
												hasVoucher:(BOOL)hasVoucher
											   hasWarranty:(BOOL)hasWarranty
											  salesChannel:(NSString *)salesChannel
										   paymentProducts:(NSArray *)paymentProducts
													 block:(B2WAPICompletionBlock)block
{
	
    NSString *baseURLString = [B2WAPIClient baseURLString];
    baseURLString = [baseURLString stringByReplacingOccurrencesOfString:@"www" withString:@"sacola"];
    baseURLString = [baseURLString stringByAppendingString:B2WAPIPaymentPath];
    
    NSString *parameters = [NSString stringWithFormat:@"?priceTotal=%@", priceTotal];
    parameters = [NSString stringWithFormat:@"%@&salesChannel=%@", parameters, salesChannel];
    parameters = [NSString stringWithFormat:@"%@&hasVoucher=%@", parameters, hasVoucher ? @"true" : @"false"];
    parameters = [NSString stringWithFormat:@"%@&hasWarranty=%@", parameters, hasWarranty ? @"true" : @"false"];
    
    for (B2WPaymentOptionProduct *paymentOptionProduct in paymentProducts) {
        NSString *encodedeJsonParam = @"";
        parameters = [parameters stringByAppendingString:@"&product="];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[paymentOptionProduct dictionaryValue] options:NSJSONWritingPrettyPrinted error:nil];
        encodedeJsonParam = [encodedeJsonParam stringByAppendingString:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
        encodedeJsonParam = [encodedeJsonParam stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        parameters = [parameters stringByAppendingString:encodedeJsonParam];
    }
    parameters = [parameters stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    NSString *URLString = [baseURLString stringByAppendingString:parameters];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:URLString
                                                                                parameters:nil
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [B2WAPIPayment handleError:error operation:operation block:block];
    }];
    
    AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (AFHTTPRequestOperation *)requestCreditCardIdWithBin:(NSString *)bin
                                                 block:(B2WAPICompletionBlock)block
{
    
    NSString *baseURLString = [B2WAPIClient baseURLString];
    baseURLString = [baseURLString stringByReplacingOccurrencesOfString:@"www" withString:@"carrinho"];
    baseURLString = [baseURLString stringByAppendingString:B2WAPIPaymentCreditCardPath];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:baseURLString
                                                                                parameters:@{@"bin":bin}
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [B2WAPIPayment handleError:error operation:operation block:block];
    }];
    
    AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

+ (void)handleError:(NSError *)error operation:(AFHTTPRequestOperation *)operation block:(B2WAPICompletionBlock)block
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

@end
