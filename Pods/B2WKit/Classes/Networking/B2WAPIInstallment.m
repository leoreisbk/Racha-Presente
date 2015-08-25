//
//  B2WAPIInstallment.m
//  B2WKit
//
//  Created by Eduardo Callado on 3/25/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WAPIInstallment.h"

#import "NSURL+B2WKit.h"
#import "B2WInstallment.h"
#import "B2WInstallmentProduct.h"
#import "AFHTTPRequestOperation+B2WKit.h"
#import "NSString+B2WKit.h"

NSString *const B2WAPIInstallmentPath = @"/api/v1/installment";

@implementation B2WAPIInstallment

+ (AFHTTPRequestOperation *)requestInstallmentsWithPaymentId:(NSString *)paymentId
                                                       total:(NSString *)total
                                         installmentProducts:(NSArray *)installmentProducts
                                                       block:(B2WAPICompletionBlock)block
{
    if (paymentId == nil || paymentId == 0 || total == nil || installmentProducts == nil || installmentProducts.count == 0 || block == nil)
    {
        return nil;
    }
    
    return [B2WAPIInstallment installmentsWithPaymentId:paymentId
                                                  total:total
                                    installmentProducts:installmentProducts
                                                  block:^(id result, NSError *error) {
        
        if (error)
        {
            block(nil, error);
        }
        if (result)
        {
            NSArray *installmentDictArray = (NSArray *) result;
            NSMutableArray *installmentArray = [[NSMutableArray alloc] initWithCapacity:installmentDictArray.count];
            for (NSDictionary *result in installmentDictArray) {
                B2WInstallment *installment = [[B2WInstallment alloc] initWithInstallmentDictionary:result];
                [installmentArray addObject:installment];
            }
            block(installmentArray, nil);
        }
    }];
}

+ (AFHTTPRequestOperation *)installmentsWithPaymentId:(NSString *)paymentId
												total:(NSString *)total
								  installmentProducts:(NSArray *)installmentProducts
												block:(B2WAPICompletionBlock)block
{
    NSString *baseURLString = [B2WAPIClient baseURLString];
    baseURLString = [baseURLString stringByReplacingOccurrencesOfString:@"www" withString:@"sacola"];
    baseURLString = [baseURLString stringByAppendingString:B2WAPIInstallmentPath];
    
    NSString *parameters = [NSString stringWithFormat:@"?paymentId=%@", paymentId];
    parameters = [NSString stringWithFormat:@"%@&total=%@", parameters, [total priceStringWithoutFormat]];
	
	if ([B2WAPIClient OPNString] != nil || [B2WAPIClient OPNString].length > 0)
    {
        parameters = [NSString stringWithFormat:@"%@&opn=%@", parameters, [B2WAPIClient OPNString]];
    }
    
    for (B2WInstallmentProduct *installmentProduct in installmentProducts)
	{
        NSString *encodedeJsonParam = @"";
        parameters = [parameters stringByAppendingString:@"&product="];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[installmentProduct dictionaryValue]
														   options:NSJSONWritingPrettyPrinted error:nil];
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
		NSMutableArray *installments = [[NSMutableArray alloc] initWithArray:responseObject];
		
		/*if (installments.count > 0)
		{
			B2WInstallment *twoTimes = [[B2WInstallment alloc] initWithInstallmentDictionary:installments[0]];
			
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			formatter.numberStyle = NSNumberFormatterDecimalStyle;
			NSNumber *total = [formatter numberFromString:twoTimes.total];
			
			NSDictionary *cashInstallment = @{ @"quantity" : [NSNumber numberWithInteger:1],
											   @"value" : total,
											   @"interestRate" : [NSNumber numberWithInteger:0],
											   @"interestAmount" : [NSNumber numberWithInteger:0],
											   @"annualCET" : @"0",
											   @"total" : total };
			
			[installments insertObject:cashInstallment atIndex:0];
			
			block(installments, nil);
		}
		else
		{*/
			block(responseObject, nil);
		//}
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
				if ([response isKindOfClass:[NSArray class]])
				{
					NSMutableArray *installments = [[NSMutableArray alloc] initWithArray:response];
					
					if(installments.count == 0)
					{
						// Empty valid installment array,
						// meaning this checkout has no option to split, but 1x
						block(response, nil);
						return;
					}
				}
				else
				{
					block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
												   code:B2WAPIServiceError
											   userInfo:@{NSLocalizedDescriptionKey : response}]);
				}
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

+ (NSArray *)installmentProductsWithCartProducts:(NSArray *)cartProducts
{
    NSMutableArray *installmentProducts = [NSMutableArray new];
    for (B2WCartProduct *product in cartProducts)
    {
        B2WInstallmentProduct *installmentProduct = [[B2WInstallmentProduct alloc] initWithItemId:product.productId storeId:product.storeId];
        [installmentProducts addObject:installmentProduct];
    }
    
    return installmentProducts.copy;
}

@end
