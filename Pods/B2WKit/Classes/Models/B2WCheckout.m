//
//  B2WCheckout.m
//  B2WKit
//
//  Created by rodrigo.fontes on 30/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WCheckout.h"

#import "B2WAPICheckout.h"
#import "B2WVoucher.h"

@implementation B2WCheckout

/*- (instancetype)initWithBillingAddressId:(NSDictionary *)billingAddressId
					   deliveryAddressId:(NSDictionary *)deliveryAddressId
						  purchaseReason:(NSDictionary *)purchaseReason
								 freight:(B2WCheckoutFreight *)freight
{
	self = [self init];
	if (self)
	{
		_billingAddressId = billingAddressId;
		
		_deliveryAddressId = deliveryAddressId;
		
		_purchaseReason = purchaseReason;
		
		if (freight != nil)
		{
			_freight = [[B2WCheckoutFreight alloc] initWithCheckoutFreightDictionary:freight];
		}
	}
	return self;
}*/

- (instancetype)initWithCheckoutDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self)
    {
        _identifier = dictionary[@"id"];
        
		_cartId = dictionary[@"cartId"];
		
        _billingAddressId = dictionary[@"billingAddressId"];
        
        _deliveryAddressId = dictionary[@"deliveryAddressId"];
        
        _purchaseReason = dictionary[@"purchaseReason"];
		
		_total = dictionary[@"total"];
		
		_amountDue = dictionary[@"amountDue"];
		
		if (dictionary[@"freight"] != nil)
		{
            _freight = [[B2WCheckoutFreight alloc] initWithCheckoutFreightDictionary:dictionary[@"freight"]];
        }
		
		if (dictionary[@"vouchers"] != nil)
		{
			_vouchers = [B2WVoucher objectsWithDictionaryArray:dictionary[@"vouchers"]];
		}
    }
    return self;
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (_billingAddressId)
    {
        [dict setValue:_billingAddressId forKey:@"billingAddressId"];
    }
    if (_deliveryAddressId)
    {
        [dict setValue:_deliveryAddressId forKey:@"deliveryAddressId"];
    }
    if (_purchaseReason)
    {
        [dict setValue:_purchaseReason forKey:@"purchaseReason"];
    }
    if (_freight)
    {
        [dict setValue:[_freight dictionaryValue] forKey:@"freight"];
    }
    
    return dict;
}

#pragma mark - Manager

+ (void)createNewCheckoutWithBlock:(B2WAPICompletionBlock)block;
{
	[B2WAPICheckout requestCreateNewCheckoutWithBlock:^(id object, NSError *error) {
		NSLog(@"\n\nNew Checkout ID = %@\n\n", [B2WAPICheckout checkoutID]);
		
		//
		// FIXME: Sometimes Checkout ID is empty here
		// TODO: Test solution below
		//
		if (block && error)
		{
			block(object, error);
		}
		else
		{
			[B2WAPICheckout requestCheckoutWithBlock:^(B2WCheckout *checkout, NSError *error) {
				NSLog(@"\n\n\nNew checkout created = %@\n\n\n", checkout.description);
				
				if (block)
				{
					block(checkout, error);
				}
			}];
		}
	}];
}

@end
