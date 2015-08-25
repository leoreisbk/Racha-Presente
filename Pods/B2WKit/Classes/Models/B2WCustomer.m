//
//  B2WCustomer.m
//  B2WKit
//
//  Created by Mobile on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WCustomer.h"
#import "B2WIndividualCustomer.h"
#import "B2WBusinessCustomer.h"
#import "B2WAPICustomer.h"
#import "B2WAddress.h"
#import "B2WOneClickRelationship.h"
#import "B2WCreditCard.h"

#import "B2WIndividualCustomer.h"
#import "B2WBusinessCustomer.h"
#import "B2WCustomerValidator.h"

#import "B2WAccountManager.h"

#define MINIMUM_EXPECTED_PHONE_LENGTH 8

@implementation B2WCustomer

+ (NSString *)_phoneStringWithDictionary:(NSDictionary*)dic
{
    NSString *firstPart;
    NSString *secondPart;
    NSString *number = dic[@"number"];
    
    if (number.length < MINIMUM_EXPECTED_PHONE_LENGTH)
    {
        return [NSString stringWithFormat:@"%@ %@", dic[@"ddd"], number];
    }
    
    NSUInteger idx = [number length]-4;
    
    firstPart = [number substringToIndex:idx];
    secondPart = [number substringFromIndex:idx];
    
    return [NSString stringWithFormat:@"(%@) %@-%@", dic[@"ddd"], firstPart, secondPart];
}

+ (NSDictionary *)_dictionaryWithPhoneString:(NSString *)string
{
    if (string.length < 13)
        return @{@"ddd":@"", @"number":@""};
    
    NSString *ddd = [string substringWithRange:NSMakeRange(1, 2)];
    NSString *number = [[string substringWithRange:NSMakeRange(5, string.length-5)] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    return @{@"ddd":ddd,
             @"number":number};
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary[@"type"] containsObjectForKey:@"pf"])
    {
        self = [[B2WIndividualCustomer alloc] initWithDictionary:dictionary[@"type"][@"pf"]];
    }
    else if ([dictionary[@"type"] containsObjectForKey:@"pj"])
    {
        self = [[B2WBusinessCustomer alloc] initWithDictionary:dictionary[@"type"][@"pj"]];
    }
	
    if (self)
    {
        _identifier = dictionary[@"id"];
        _email = dictionary[@"email"];
		_optIn = dictionary[@"optIn"];
		_oneClickEnabled = [dictionary[@"oneClick"] boolValue];
        NSDictionary *phones = dictionary[@"telephones"];
        _mainPhone = [B2WCustomer _phoneStringWithDictionary:phones[@"main"]];
        
        if ([phones containsObjectForKey:@"secondary"])
        {
            _secondaryPhone = [B2WCustomer _phoneStringWithDictionary:phones[@"secondary"]];
        }
        
        if ([phones containsObjectForKey:@"business"])
        {
            _businessPhone = [B2WCustomer _phoneStringWithDictionary:phones[@"business"]];
        }
    }
    
    return self;
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
	dictionary[@"optIn"] = @{@"mailing" : @(false),
							 @"receiveSMS" : @(false),
							 @"mailingSoub" : @(false)};
	
	if (! [B2WAPIAccount isLoggedIn])
	{
		dictionary[@"account"] = @{@"id": self.email,
								   @"password": self.password ?: [B2WAPIAccount password]};
	}
	
	NSMutableDictionary *telephones = [NSMutableDictionary dictionary];
    [telephones setObject:[B2WCustomer _dictionaryWithPhoneString:self.mainPhone] forKey:@"main"];
    if (_secondaryPhone)
    {
        [telephones setObject:[B2WCustomer _dictionaryWithPhoneString:self.secondaryPhone] forKey:@"secundary"];
    }
    if (_businessPhone)
    {
        [telephones setObject:[B2WCustomer _dictionaryWithPhoneString:self.businessPhone] forKey:@"business"];
    }
    dictionary[@"telephones"] = telephones;
    
    return dictionary;
}

- (AFHTTPRequestOperation *)updateWithBlock:(B2WAPICompletionBlock)block
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (AFHTTPRequestOperation *)createWithAddress:(B2WAddress*)address block:(B2WAPICompletionBlock)block
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (AFHTTPRequestOperation *)addAddress:(B2WAddress*)address block:(B2WAPICompletionBlock)block
{
    return [B2WAPICustomer requestWithMethod:@"POST"
                                    resource:B2WAPICustomerResourceAddress
                          resourceIdentifier:nil
                                  parameters:[address dictionaryValue]
                                       block:block];
}

- (AFHTTPRequestOperation *)addCreditCard:(B2WCreditCard*)card block:(B2WAPICompletionBlock)block
{
    return [B2WAPICustomer requestWithMethod:@"POST"
                                    resource:B2WAPICustomerResourceCreditCard
                          resourceIdentifier:nil
                                  parameters:[card dictionaryValue]
                                       block:block];
}

//- (AFHTTPRequestOperation *)deleteCreditCard:(B2WCreditCard*)card block:(B2WAPICompletionBlock)block
- (AFHTTPRequestOperation *)deleteCreditCard:(NSString *)identifier block:(B2WAPICompletionBlock)block;
{
	return [B2WAPICustomer requestWithMethod:@"DELETE"
									resource:B2WAPICustomerResourceCreditCard
						  resourceIdentifier:identifier
								  parameters:nil
									   block:block];
}

- (AFHTTPRequestOperation *)associateCreditCard:(NSDictionary *)params block:(B2WAPICompletionBlock)block
{
	return [B2WAPICustomer requestWithMethod:@"POST"
									resource:B2WAPICustomerResourceCreditCardAssociate
						  resourceIdentifier:nil
								  parameters:params
									   block:block];
}

- (AFHTTPRequestOperation *)requestAddress:(NSString *)identifier withBlock:(B2WAPICompletionBlock)block
{
	return [B2WAPICustomer requestWithMethod:@"GET"
									resource:B2WAPICustomerResourceAddress
						  resourceIdentifier:identifier
								  parameters:nil
									   block:block];
}

- (AFHTTPRequestOperation *)requestAddressesWithBlock:(B2WAPICompletionBlock)block
{
    return [B2WAPICustomer requestWithMethod:@"GET"
                                    resource:B2WAPICustomerResourceAddress
                          resourceIdentifier:nil
                                  parameters:nil
                                       block:block];
}

- (AFHTTPRequestOperation *)requestCreditCard:(NSString *)identifier withBlock:(B2WAPICompletionBlock)block
{
	return [B2WAPICustomer requestWithMethod:@"GET"
									resource:B2WAPICustomerResourceCreditCard
						  resourceIdentifier:identifier
								  parameters:nil
									   block:block];
}

- (AFHTTPRequestOperation *)requestCreditCardsWithBlock:(B2WAPICompletionBlock)block
{
    return [B2WAPICustomer requestWithMethod:@"GET"
                                    resource:B2WAPICustomerResourceCreditCard
                          resourceIdentifier:nil
                                  parameters:nil
                                       block:block];
}

- (AFHTTPRequestOperation *)requestOneClickRelationshipsWithBlock:(B2WAPICompletionBlock)block
{
    return [B2WAPICustomer requestWithMethod:@"GET"
                                    resource:B2WAPICustomerResourceOneClick
                          resourceIdentifier:nil
                                  parameters:nil
                                       block:block];
}

@end
