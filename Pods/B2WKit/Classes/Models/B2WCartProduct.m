//
//  B2WCartProduct.m
//  B2WKit
//
//  Created by Eduardo Callado on 3/20/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WCartProduct.h"

@implementation B2WCartProduct

#pragma mark - Initialization

- (instancetype)initWithCartProductDictionary:(NSDictionary*)dictionary
{
	self = [self init];
	if (self)
	{
		_productId = dictionary[@"productId"];
		_lineId = dictionary[@"id"];
		_sku = dictionary[@"productSku"];
		// _sku = dictionary[@"product"][@"sku"];
		
		_name = dictionary[@"product"][@"name"];
		
		NSString *urlString = dictionary[@"product"][@"image"];
		
		if ([urlString hasPrefix:@"//"]  && [urlString length] > 2)
		{
			urlString = [urlString substringFromIndex:2];
			urlString = [NSString stringWithFormat:@"http://%@", urlString];
		}
		
		_imageURL = [NSURL URLWithString:urlString];
		_quantity = dictionary[@"quantity"];
		
		_storeId = dictionary[@"product"][@"store"][@"id"];
		_storeName = dictionary[@"product"][@"store"][@"name"];
		_storeImageURL = [NSURL URLWithString:dictionary[@"product"][@"store"][@"image"]];
		
		NSNumber *priceNumber = dictionary[@"product"][@"price"];
		_price = priceNumber;
		
		NSNumber *originalPriceNumber = dictionary[@"product"][@"originalPrice"];
		_originalPrice = originalPriceNumber;
		
		NSNumber *unitSalesPriceNumber = dictionary[@"unitSalesPrice"];
		_unitSalesPrice = unitSalesPriceNumber;
		
		NSNumber *salesPriceNumber = dictionary[@"salesPrice"];
		_salesPrice = salesPriceNumber;
		
		_isMarketplace = _storeId ? YES : NO;
		
		NSString *isLargeString = [dictionary[@"product"][@"isLarge"] stringValue];
		_isLarge = [isLargeString isEqualToString:@"1"] ? YES : NO;
		
		//_warranties = dictionary[@"quantity"];
		//_repackaged = dictionary[@"quantity"];
		//_isKit = dictionary[@"quantity"];
	}
	return self;
}

- (instancetype)initWithProductSKU:(NSString *)sku quantity:(NSInteger)quantity storeID:(NSString *)storeID
{
	self = [self init];
	if (self)
	{
		_sku = sku;
		_quantity = [NSNumber numberWithInteger:quantity];
		_storeId = storeID;
	}
	return self;
}

#pragma mark - General

- (void)setQuantity:(NSInteger)quantity
{
	_quantity = [NSNumber numberWithInteger:quantity];
}

- (void)setSalesPrice:(NSNumber *)salesPrice
{
    _salesPrice = salesPrice;
}

- (NSDictionary *)dictionaryValue
{
	_isMarketplace = _storeId ? YES : NO;
	
	if (!_sku || !_quantity)
	{
		return nil;
	}
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{ @"sku" : _sku,
																				   @"quantity" : _quantity }];
	
	if (_isMarketplace)
	{
		if (_storeId)
		{
			[dict setValue:_storeId forKey:@"storeId"];
			return dict;
		}
		else
		{
			return nil;
		}
	}
	else
	{
		return dict;
	}
}

@end
