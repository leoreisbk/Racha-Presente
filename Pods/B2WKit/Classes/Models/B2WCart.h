//
//  B2WCart.h
//  B2WKit
//
//  Created by Eduardo Callado on 3/19/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WObject.h"

#import "B2WCartCustomer.h"

@interface B2WCart : B2WObject

@property (nonatomic, readonly) NSString *cartID;
@property (nonatomic, readonly) NSNumber *total;
@property (nonatomic, readonly) NSMutableArray *lines;

@property (nonatomic, readonly) B2WCartCustomer *customer;

@property (nonatomic, readonly) NSNumber *discount;
@property (nonatomic, readonly) NSMutableArray *promotions;

@property (nonatomic, readonly) NSString *coupon;

- (instancetype)initWithCartDictionary:(NSDictionary*)dictionary;

+ (void)setupNewCart;
+ (void)setupCart;

+ (void)setupNewCartWithCompletion:(B2WAPICompletionBlock)block;
+ (void)setupCartWithCompletion:(B2WAPICompletionBlock)block;

+ (void)updateCartWithCurrentLoggedInCustomerWithCompletion:(B2WAPICompletionBlock)block;
+ (void)updateCartWithCurrentLoggedInCustomer;

+ (void)removeCustomerFromCartWithCompletion:(B2WAPICompletionBlock)block;
+ (void)removeCustomerFromCart;

@end
