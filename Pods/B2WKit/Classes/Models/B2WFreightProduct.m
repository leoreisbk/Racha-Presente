//
//  B2WFreightProduct.m
//  B2WKit
//
//  Created by Eduardo Callado on 4/2/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WFreightProduct.h"

#import "B2WCartProduct.h"

@implementation B2WFreightProduct

- (instancetype)initWithItemSku:(NSString *)SKU
					   quantity:(NSNumber *)quantity
						storeId:(NSString *)storeId
			   promotionedPrice:(NSNumber *)promotionedPrice
{
	self = [self init];
	if (self)
	{
		_SKU = SKU;
		_quantity = quantity;
		_storeId = storeId;
		_promotionedPrice = promotionedPrice;
	}
	return self;
}

+ (NSArray *)freightProductsWithCartProducts:(NSArray *)cartProducts
{
	NSMutableArray *freightProducts = [NSMutableArray new];
	
	for (B2WCartProduct *cartProduct in cartProducts)
	{
		B2WFreightProduct *freightProduct = [[B2WFreightProduct alloc] initWithItemSku:cartProduct.sku
																			  quantity:cartProduct.quantity
																			   storeId:cartProduct.storeId
																	  promotionedPrice:cartProduct.price];
		
		[freightProducts addObject:freightProduct];
	}
	
	return freightProducts;
}

- (NSDictionary *)dictionaryValue
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{ @"sku" : _SKU,
																				   @"promotionedPrice" : _promotionedPrice ?: @(0),
																				   @"quantity" :  _quantity,
																				   @"repackaged" : @(0),
																				   @"pickUpInStore" : @(0)} ];

	if (_storeId)
	{
		[dict setValue:_storeId forKey:@"storeId"];
	}
	
	return dict;
}

@end
