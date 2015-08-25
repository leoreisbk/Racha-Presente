//
//  B2WAPIFreight.m
//  B2Wkit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WAPIFreight.h"
#import "NSURL+B2WKit.h"
#import "B2WFreightCalculationResult.h"
#import "B2WFreightCalculationProduct.h"
#import "AFHTTPRequestOperation+B2WKit.h"
#import "B2WFreightProduct.h"

#define kB2WAPIFreightCalculatorPostalCodeStringLength 8

NSString *const B2WAPIFreightCalculatorAPIPath = @"/api/v1/freight";

@implementation B2WAPIFreight

+ (AFHTTPRequestOperation *)requestEstimateWithPostalCode:(NSString *)postalCode
                                       productParamsArray:(NSArray *)productParamsArray
                                                    block:(B2WAPICompletionBlock)block
{
    if (postalCode == nil || postalCode == 0 || productParamsArray == nil || productParamsArray.count == 0 || block == nil)
    {
        return nil;
	}
	
	return [B2WAPIFreight _estimateRequestOperationWithPostalCode:postalCode
											   productParamsArray:productParamsArray block:^(id result, NSError *error) {
		if (error)
		{			
            if (![error.domain isEqualToString:NSURLErrorDomain])
            {
                if ([error.userInfo valueForKey:@"NSLocalizedDescription"] != nil && [[error.userInfo valueForKey:@"NSLocalizedDescription"] isKindOfClass:[NSDictionary class]])
                {
                    if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] objectForKey:@"additionalInfo"])
                    {
                        NSArray *errors = [error.userInfo valueForKeyPath:@"NSLocalizedDescription.additionalInfo.value"];
                        NSString *errorMessage = errors.firstObject;
                        
                        if (errorMessage)
                        {
                            B2WFreightCalculationResult *freightResult = [[B2WFreightCalculationResult alloc] initWithResultMessage:errorMessage
                                                                                                                 productParamsArray:productParamsArray];
                            block(freightResult, nil);
                            return;
                        }
                    }
                }
            }
            block(nil, error);
		}
		if (result)
		{
			B2WFreightCalculationResult *freightResult = [[B2WFreightCalculationResult alloc] initWithDictionary:result
																									  postalCode:postalCode];
			block(freightResult, nil);
		} }];
}

+ (AFHTTPRequestOperation*)_estimateRequestOperationWithPostalCode:(NSString *)postalCode
                                                productParamsArray:(NSArray *)productParamsArray
                                                             block:(B2WAPICompletionBlock)block
{
	NSString *strippedPostalCode = postalCode;
	strippedPostalCode = [strippedPostalCode stringByReplacingOccurrencesOfString:@"-" withString:@""];
    strippedPostalCode = [strippedPostalCode stringByReplacingOccurrencesOfString:@" " withString:@""];
	
    if (strippedPostalCode.length != kB2WAPIFreightCalculatorPostalCodeStringLength)
    {
        [NSException raise:NSInvalidArgumentException format:@"Postal code string is not valid. Sent: %@", postalCode];
    }
	
	NSString *baseURLString = [B2WAPIClient baseURLString];
    baseURLString = [baseURLString stringByAppendingString:B2WAPIFreightCalculatorAPIPath];
    
    NSString *parameters = [NSString stringWithFormat:@"?cep=%@", strippedPostalCode];
    if ([B2WAPIClient OPNString] != nil || [B2WAPIClient OPNString].length > 0)
    {
        parameters = [NSString stringWithFormat:@"%@&opn=%@", parameters, [B2WAPIClient OPNString]];
    }
	
	for (B2WFreightProduct *product in productParamsArray)
	{
		NSString *encodedeJsonParam = @"";
        parameters = [parameters stringByAppendingString:@"&product="];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[product dictionaryValue] options:NSJSONWritingPrettyPrinted error:nil];
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
    
    AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer = responseSerializer;
    
    [[B2WAPIClient sharedClient].operationQueue addOperation:op];
    
    return op;
}

@end