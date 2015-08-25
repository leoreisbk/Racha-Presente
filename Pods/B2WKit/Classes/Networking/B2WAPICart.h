//
//  B2WAPICart.h
//  B2WKit
//
//  Created by Eduardo Callado on 3/18/15.
//  Copyright (c) 2015 Ideais. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "B2WAPIClient.h"
#import "B2WCart.h"
#import "B2WCartProduct.h"
#import "B2WCartCustomer.h"

#import "UICKeyChainStore.h"

typedef NS_ENUM(NSInteger, B2WAPICartError) {
    B2WAPICartErrorCouponExpired,
    B2WAPICartErrorCouponNotFound,
    B2WAPICartErrorCouponUsed,
	B2WAPICartErrorCouponGeneric
};

FOUNDATION_EXPORT NSString *const B2WAPICartErrorDomain;

//
// http://api-portal.ideais.com.br/#/project/cart-api/v2
//

@interface B2WAPICart : NSObject

//
// Get the ID from a previous created cart
//
// Returns nil if no cart created
//
+ (NSString *)cartID;

//
// Set the ID from a new cart
//
+ (void)setCartID:(NSString *)cartID;

//
// Remove a saved cart ID
//
+ (void)resetCartID;

//
// Create a new cart
//
+ (AFHTTPRequestOperation*)requestCreateNewCartWithBlock:(B2WAPICompletionBlock)block;

//
// Get information from a previous created cart
//
// Returns nil if no cart created
//
+ (AFHTTPRequestOperation*)requestCartWithBlock:(B2WAPICompletionBlock)block;

//
// Add a product to cart
//
+ (AFHTTPRequestOperation *)requestAddProduct:(B2WCartProduct *)product
										block:(B2WAPICompletionBlock)block;

//
// Add an array of products to cart
//
+ (AFHTTPRequestOperation*)requestAddProducts:(NSArray *)products
                                        block:(B2WAPICompletionBlock)block;


//
// Update a product previous added to the cart
//
+ (AFHTTPRequestOperation *)requestUpdateProduct:(B2WCartProduct *)product
										   block:(B2WAPICompletionBlock)block;

//
// Delete a product form cart
//
+ (AFHTTPRequestOperation *)requestRemoveProduct:(B2WCartProduct *)product
										   block:(B2WAPICompletionBlock)block;

//
// Update cart with customer
//
+ (AFHTTPRequestOperation *)requestUpdateCartWithCustomer:(B2WCartCustomer *)customer
                                                    block:(B2WAPICompletionBlock)block;
//
// Remove customer from cart
//
+ (AFHTTPRequestOperation *)requestRemoveCustomerFromCartWithBlock:(B2WAPICompletionBlock)block;

//
// Add a coupon to cart
//
+ (AFHTTPRequestOperation *)requestAddCouponWithID:(NSString *)couponID
											 block:(B2WAPICompletionBlock)block;

//
// Remove coupon form cart
//
+ (AFHTTPRequestOperation *)requestRemoveCouponWithBlock:(B2WAPICompletionBlock)block;

//
// Get coupon from cart
//
+ (AFHTTPRequestOperation *)requestGetCouponWithBlock:(B2WAPICompletionBlock)block;

//
// Add OPN and EPar to cart
//
+ (AFHTTPRequestOperation *)requestAddOPNEParWithblock:(B2WAPICompletionBlock)block;

///////////////////////////////////////////////////////////////
// New API Methods
///////////////////////////////////////////////////////////////

+ (AFHTTPRequestOperation *)createCartWithBlock:(B2WAPICompletionBlock)block;

+ (AFHTTPRequestOperation*)cartWithID:(NSString *)cartID block:(B2WAPICompletionBlock)block;

+ (AFHTTPRequestOperation *)addProduct:(B2WCartProduct *)product cartID:(NSString *)cartID block:(B2WAPICompletionBlock)block;

+ (AFHTTPRequestOperation *)setCustomer:(B2WCartCustomer *)customer cartID:(NSString *)cartID block:(B2WAPICompletionBlock)block;

@end
