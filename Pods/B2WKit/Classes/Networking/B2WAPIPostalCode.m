//
//  B2WAPIPostalCode.m
//  B2WKit
//
//  Created by Thiago Peres on 15/04/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WAPIPostalCode.h"
#import "NSURL+B2WKit.h"

@implementation B2WAPIPostalCode

+ (AFHTTPRequestOperation*)requestAddressInformationWithPostalCode:(NSString*)postalCode
                                                             block:(B2WAPICompletionBlock)block
{
    if (postalCode == nil || postalCode.length == 0)
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInvalidParameterError
                                       userInfo:@{NSLocalizedDescriptionKey: @"You must provide a postal code."}]);
        }
        return nil;
    }
    
    postalCode = [postalCode stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *path = [NSURL URLStringWithSubdomain:@"carrinho"
                                           options:B2WAPIURLOptionsUsesHTTPS | B2WAPIURLOptionsAddCorporateKey
                                              path:@"api/v1/cep/%@", postalCode];
    
    AFHTTPRequestOperation *op = [[B2WAPIClient sharedClient] GET:path
                                                       parameters:nil
                                                          success:[B2WAPIClient completionBlockWithBlock:block]
                                                          failure:[B2WAPIClient errorBlockWithBlock:block]];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return op;
}

+ (AFHTTPRequestOperation*)requestPostalCodeWithStreet:(NSString*)street
                                                  city:(NSString*)city
                                                 state:(NSString*)state
                                                 block:(B2WAPICompletionBlock)block
{
    //
    // Clean input from special accents (e.g é ç ã)
    // as of api v1 any queries with this kind of ponctuation
    // won't return any results
    //
    NSData *data = [street dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    street = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    data = [city dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    city = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    data = [state dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    state = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSString *path = [NSURL URLStringWithSubdomain:@"carrinho"
                                           options:B2WAPIURLOptionsUsesHTTPS | B2WAPIURLOptionsAddCorporateKey
                                              path:@"api/v1/cep/"];
    
    AFHTTPRequestOperation *op = [[B2WAPIClient sharedClient] GET:path
                                                       parameters:@{@"address" : street,
                                                                    @"city" : city,
                                                                    @"state" : state}
                                                          success:[B2WAPIClient completionBlockWithBlock:block]
                                                          failure:[B2WAPIClient errorBlockWithBlock:block]];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return op;
}

+ (void)cancelAllRequests
{
    NSString *path = @"api/v1/cep/";
    
    [[B2WAPIClient sharedClient].operationQueue.operations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        AFHTTPRequestOperation *request = obj;
        
		DLog(@"%@", request.request.URL.relativePath);
		if ([request.request.URL.relativePath isEqualToString:path])
		{
			[request cancel];
		}
    }];
}

@end
