//
//  B2WAPICustomer.h
//  B2WKit
//
//  Created by Thiago Peres on 15/04/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WAPIClient.h"

typedef NS_ENUM(NSInteger, B2WAPICustomerResource)
{
    B2WAPICustomerResourceNone,
    B2WAPICustomerResourceAddress,
    B2WAPICustomerResourceCreditCard,
    B2WAPICustomerResourceCreditCardAssociate,
    B2WAPICustomerResourceOneClick,
	B2WAPICustomerResourceAddressAsMain
};

@interface B2WAPICustomer : NSObject

+ (void)setStaging:(BOOL)staging;
+ (BOOL)isStaging;

+ (void)setPersistenceEnabled:(BOOL)shouldPersist;

+ (AFHTTPRequestOperation*)requestWithMethod:(NSString *)httpMethod
                                    resource:(B2WAPICustomerResource)resourceType
                          resourceIdentifier:(NSString *)resourceIdentifier
                                  parameters:(NSDictionary*)parameters
                                       block:(B2WAPICompletionBlock)block;

+ (AFHTTPRequestOperation*)createCustomerWithCustomerDictionary:(NSDictionary *)customer
                                                          block:(B2WAPICompletionBlock)block;

@end
