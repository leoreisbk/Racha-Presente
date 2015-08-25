//
//  B2WCreditCard.m
//  B2WKit
//
//  Created by Mobile on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WCreditCard.h"

#import "B2WValidator.h"

@implementation B2WCreditCard

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _identifier = dictionary[@"id"];
        _number = dictionary[@"number"];
        _criptoNumber = dictionary[@"criptoNumber"];
        //_brand = dictionary[@"brand"];
        //_isB2WCard = [dictionary[@"isBrandCard"] boolValue];
        _holderName = dictionary[@"holderName"];
        
        if ([dictionary containsObjectForKey:@"verificationCode"])
        {
            _verificationCode = dictionary[@"verificationCode"];
        }
        
        NSString *expiration = dictionary[@"expirationDate"]; // CLL CLL
        //_expirationMonth = [[expiration substringToIndex:3] integerValue];
        //_expirationYear = [[expiration substringFromIndex:4] integerValue];
		_expirationMonth = [[[expiration substringFromIndex:5] substringToIndex:2] integerValue];
		_expirationYear = [[[expiration substringFromIndex:0] substringToIndex:4] integerValue];
    }
    return self;
}

- (NSDictionary*)dictionaryValue
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[@"number"] = [self.number stringByRemovingMask];
    dictionary[@"holderName"] = self.holderName;
    dictionary[@"verificationCode"] = self.verificationCode;
    //dictionary[@"isBrandCard"] = @(self.isB2WCard);
    //dictionary[@"brand"] = self.brand;
	dictionary[@"expirationDate"] = [NSString stringWithFormat:@"20%02lu-%02lu", self.expirationYear, self.expirationMonth]; // CLL CLL
	
    return dictionary;
}

- (AFHTTPRequestOperation *)addNewWithBlock:(B2WAPICompletionBlock)block
{
    return [B2WAPICustomer requestWithMethod:@"POST"
                                    resource:B2WAPICustomerResourceCreditCard
                          resourceIdentifier:nil
                                  parameters:[self dictionaryValue]
                                       block:block];
}

- (AFHTTPRequestOperation *)removeWithBlock:(B2WAPICompletionBlock)block
{
    if (self.identifier)
    {
        return [B2WAPICustomer requestWithMethod:@"DELETE"
                                        resource:B2WAPICustomerResourceCreditCard
                              resourceIdentifier:self.identifier
                                      parameters:nil
                                           block:block];
    }
    
    // TODO: Tratar erro
    NSError *error;
    if (block)
    {
        block(nil, error);
    }
    
    NSLog(@"%@", error);
    
    return nil;
}

- (AFHTTPRequestOperation *)updateWithBlock:(B2WAPICompletionBlock)block
{
    if (self.identifier)
    {
        return [B2WAPICustomer requestWithMethod:@"PUT"
										resource:B2WAPICustomerResourceCreditCard
							  resourceIdentifier:self.identifier
                                      parameters:[self dictionaryValue]
                                           block:block];
    }
	
    // TODO: Tratar erro
    NSError *error;
    if (block)
    {
        block(nil, error);
    }
	
	NSLog(@"%@", error);
    
    return nil;
}

@end
