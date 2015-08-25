//
//  B2WCart.m
//  B2WKit
//
//  Created by Eduardo Callado on 3/19/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WCart.h"

#import "B2WCartProduct.h"
#import "B2WAPICart.h"
#import "B2WAPIAccount.h"
#import "B2WAccountManager.h"

@implementation B2WCart

- (instancetype)initWithCartDictionary:(NSDictionary*)dictionary
{
	self = [self init];
	if (self)
	{
		_cartID = dictionary[@"id"];
		
		NSNumber *totalPriceNumber = dictionary[@"total"];
		_total = totalPriceNumber;
		
		_lines = [NSMutableArray new];
		_discount = 0;
		
		_promotions = [NSMutableArray new];
		
		NSArray *lines = dictionary[@"lines"];
		for (NSDictionary *product in lines)
		{
			[_lines addObject:[[B2WCartProduct alloc] initWithCartProductDictionary:product]];
			
			if ([product.allKeys containsObject:@"promotions"])
			{
				NSDictionary *promotions = product[@"promotions"];
				
				for (NSDictionary *promotion in promotions)
				{
					NSNumber *promotionValue = promotion[@"discountValue"];
					NSNumber *sum = [NSNumber numberWithFloat:([_discount floatValue] + [promotionValue floatValue])];
					_discount = sum;
					
					[_promotions addObject:promotion];
				}
			}
		}
		
		_discount = [self multiplyA:_discount withB:@(-1)];
		
		if ([dictionary.allKeys containsObject:@"customer"])
		{
			_customer = [[B2WCartCustomer alloc] initWithCartCustomerDictionary:dictionary[@"customer"]];
		}
		
		if ([dictionary.allKeys containsObject:@"coupon"])
		{
			_coupon = dictionary[@"coupon"][@"id"];
		}
	}
	return self;
}

#pragma mark - Helpers

- (NSNumber *)multiplyA:(NSNumber *)a withB:(NSNumber *)b
{
	float number1 = [a floatValue];
	float number2 = [b floatValue];
	float product = number1 * number2;
	return [NSNumber numberWithFloat:product];
}

#pragma mark - Manager

+ (void)setupNewCartWithCompletion:(B2WAPICompletionBlock)block
{
	[B2WAPICart resetCartID];
	[B2WCart setupCartWithCompletion:block];
}

+ (void)setupCartWithCompletion:(B2WAPICompletionBlock)block
{
	if (! [B2WAPICart cartID])
	{
		NSLog(@"[CART] : Will create new cart\n");
		
		[B2WAPICart requestCreateNewCartWithBlock:^(id object, NSError *error) {
			[B2WAPICart requestCartWithBlock:^(B2WCart *cart, NSError *error) {
				if ([B2WAPIAccount isLoggedIn])
				{
					NSLog(@"[CART] : New cart created with customer = %@\n", cart.description);
				}
				else
				{
					NSLog(@"[CART] : New cart created without customer = %@\n", cart.description);
				}
				
				if (block)
				{
					block(cart, error);
				}
			}];
		}];
	}
	else
	{
		[B2WAPICart requestCartWithBlock:^(B2WCart *cart, NSError *error) {
			NSLog(@"[CART] : Cart previously created = %@\n", cart.description);
			
			if (block)
			{
				block(cart, error);
			}
		}];
	}
}

+ (void)setupNewCart
{
	[B2WCart setupNewCartWithCompletion:^(id object, NSError *error) {
		[B2WCheckoutManager clearProduct];
	}];
}

+ (void)setupCart
{
	[B2WCart setupCartWithCompletion:nil];
}

+ (void)updateCartWithCurrentLoggedInCustomerWithCompletion:(B2WAPICompletionBlock)block
{
	if (! [B2WAPIAccount isLoggedIn])
	{
		return;
	}
	
	[B2WAccountManager requestCustomerInformationWithCompletion:^{
		[B2WAPICart requestCartWithBlock:^(B2WCart *cart, NSError *error) {
			// NSLog(@"[CART] : Cart previously created = %@\n", cart.description);
			
			//if (cart.customer == nil)
			{
				B2WCartCustomer *cartCustomer = [[B2WCartCustomer alloc] initWithIdentifier:[B2WAccountManager currentCustomer].identifier
																					  token:[B2WAPIAccount token]];
				
				[B2WAPICart requestUpdateCartWithCustomer:cartCustomer block:^(id object, NSError *error) {
					[B2WAPICart requestCartWithBlock:^(B2WCart *cart, NSError *error) {
						NSLog(@"[CART] : Cart updated with customer = %@\n", cart.description);
						
						if (block)
						{
							block(cart, error);
						}
					}];
				}];
			}
			/*else
			{
				NSLog(@"[CART] : Cart previously created = %@\n", cart.description);
			}*/
		}];
	}];
}

+ (void)updateCartWithCurrentLoggedInCustomer
{
	[self updateCartWithCurrentLoggedInCustomerWithCompletion:nil];
}


+ (void)removeCustomerFromCartWithCompletion:(B2WAPICompletionBlock)block
{
	[B2WAPICart requestCartWithBlock:^(B2WCart *cart, NSError *error) {
        if (cart && cart.customer && cart.customer.identifier)
        {
            [B2WAPICart requestRemoveCustomerFromCartWithBlock:^(id object, NSError *error) {
                [B2WAPICart requestCartWithBlock:^(B2WCart *cart, NSError *error) {
                    NSLog(@"[CART] : Cart with customer removed = %@\n", cart.description);
					
					if (block)
					{
						block(cart, error);
					}
                }];
            }];
        }
	}];
}

+ (void)removeCustomerFromCart
{
	[self removeCustomerFromCartWithCompletion:nil];
}

@end
