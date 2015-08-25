//
//  B2WAPIPaymentInfo.m
//  B2WKit
//
//  Created by Eduardo Callado on 7/8/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WAPIPaymentInfo.h"

#import "NSURL+B2WKit.h"
#import "B2WInstallment.h"
#import "B2WInstallmentProduct.h"
#import "AFHTTPRequestOperation+B2WKit.h"
#import "NSString+B2WKit.h"

NSString *const B2WAPIPaymentInfoPath = @"/api/v1/credit-card-payment-info";

@implementation B2WAPIPaymentInfo

+ (AFHTTPRequestOperation *)requestInstallmentsWithCheckoutID:(NSString *)checkoutID
													  cardBin:(NSString *)cardBin
														block:(B2WAPICompletionBlock)block
{
	//
	// TODO: handle nil or empty velues
	//
	
	NSString *baseURLString = [B2WAPIClient baseURLString];
	baseURLString = [baseURLString stringByReplacingOccurrencesOfString:@"www" withString:@"sacola"];
	baseURLString = [baseURLString stringByAppendingString:B2WAPIPaymentInfoPath];
	
	NSString *parameters = [NSString stringWithFormat:@"?checkoutId=%@", checkoutID];
	parameters = [NSString stringWithFormat:@"%@&bin=%@", parameters, cardBin];
	//parameters = [parameters stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
	
	NSString *URLString = [baseURLString stringByAppendingString:parameters];
	
	NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
																				 URLString:URLString
																				parameters:nil
																					 error:nil];
	
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *response = (NSDictionary *)responseObject;
		if ([[response allKeys] containsObject:@"installments"])
		{
			NSArray *installmentDictArray = (NSArray *) response[@"installments"];
			NSMutableArray *installmentArray = [[NSMutableArray alloc] initWithCapacity:installmentDictArray.count];
			for (NSDictionary *result in installmentDictArray) {
				B2WInstallment *installment = [[B2WInstallment alloc] initWithInstallmentDictionary:result];
				[installmentArray addObject:installment];
			}
			block(installmentArray, nil);
		}
		else
		{
			block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
										   code:B2WAPIServiceError
									   userInfo:@{NSLocalizedDescriptionKey : response}]);
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
	
	AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
	op.responseSerializer = responseSerializer;
	
	[[B2WAPIClient sharedClient].operationQueue addOperation:op];
	
	return op;
}

@end
