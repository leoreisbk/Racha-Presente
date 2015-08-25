//
//  B2WInstallmentProduct.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WInstallmentProduct.h"

@implementation B2WInstallmentProduct

#pragma mark - Initialization

- (instancetype)initWithItemId:(NSString *)itemId storeId:(NSString *)storeId
{
	self = [self init];
	if (self)
	{
		_itemId = itemId;
        _type = [self isMarketPlace] ? @"MARKET_PLACE" : @"B2W";
		_storeId = storeId;
	}
	return self;
}

- (instancetype)initWithInstallmentProductDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self)
    {
        _itemId = dictionary[@"itemId"];
        _type = dictionary[@"type"];
        _storeId = dictionary[@"storeId"];
    }
    return self;
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{ @"itemId" : _itemId,
                                                                                   @"type"   : _type }];
    
    if ([self isMarketPlace])
    {
        [dict setValue:_storeId forKey:@"storeId"];
    }
    
    return dict;
}

- (BOOL)isMarketPlace
{
    return _storeId && _storeId > 0 ? YES : NO;
}

@end
