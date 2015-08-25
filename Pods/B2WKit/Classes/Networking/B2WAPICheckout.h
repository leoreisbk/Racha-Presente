//
//  B2WAPICheckout.h
//  B2WKit
//
//  Created by Eduardo Callado on 3/25/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

//
// http://api-portal.ideais.com.br/#/project/checkout-api/v1
//

#import <Foundation/Foundation.h>
#import "B2WAPIClient.h"
#import "B2WCheckout.h"

typedef NS_ENUM(NSInteger, B2WAPICheckoutError) {
    B2WAPICheckoutErrorVoucherInvalid,
    B2WAPICheckoutErrorVoucherNotFound,
    B2WAPICheckoutErrorVoucherUsed,
    B2WAPICheckoutErrorVoucherExpired,
    B2WAPICheckoutErrorVoucherBlocked,
	B2WAPICheckoutErrorVoucherAlreadyAdded,
    B2WAPICheckoutErrorVoucherGeneric
};

FOUNDATION_EXPORT NSString *const B2WAPICheckoutErrorDomain;

@interface B2WAPICheckout : NSObject

//
// Get the ID from a previous created checkout
//
// Returns nil if no checkout created
//
+ (NSString *)checkoutID;

//
// Set the ID from a new checkout
//
+ (void)setCheckoutID:(NSString *)checkoutID;

//
// Remove a saved checkout ID
//
+ (void)resetCheckoutID;

//
// Create a new checkout
//
+ (AFHTTPRequestOperation*)requestCreateNewCheckoutWithBlock:(B2WAPICompletionBlock)block;
// new method, doesn't do anything else implicitly
+ (AFHTTPRequestOperation*)createCheckoutWithCartID:(NSString *)cartID block:(void (^)(NSString *checkoutID, NSError *error))block;

//
// Get information from a previous created checkout
//
// Returns nil if no checkout created
//
+ (AFHTTPRequestOperation*)requestCheckoutWithBlock:(B2WAPICompletionBlock)block;
// new method, doesn't do anything else implicitly
+ (AFHTTPRequestOperation*)checkoutWithID:(NSString *)checkoutID block:(void (^)(B2WCheckout *checkout, NSError *error))block;
//
// Add Payment
//

+ (AFHTTPRequestOperation *)requestAddPayment:(NSArray *)parameters
										block:(B2WAPICompletionBlock)block;
// new method, doesn't do anything else implicitly
+ (AFHTTPRequestOperation *)addPayment:(NSArray *)parameters checkoutID:(NSString *)checkoutID block:(B2WAPICompletionBlock)block;

//
// Get vouchers
//
+ (AFHTTPRequestOperation *)requestGetVouchersWithBlock:(B2WAPICompletionBlock)block;

//
// Add a voucher
//
+ (AFHTTPRequestOperation *)requestAddVoucherWithID:(NSString *)voucherID block:(B2WAPICompletionBlock)block;

//
// Remove a voucher
//
+ (AFHTTPRequestOperation *)requestRemoveVoucherWithID:(NSString *)voucherID block:(B2WAPICompletionBlock)block;

@end
