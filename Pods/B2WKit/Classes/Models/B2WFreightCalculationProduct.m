//
//  B2WFreightCalculationProduct.m
//  B2WKit
//
//  Created by rodrigo.fontes on 18/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WFreightCalculationProduct.h"

@implementation B2WFreightCalculationProduct

- (instancetype)initWithDictionary:(NSDictionary *)dict resultType:(B2WAPIFreightCalculationResultType)resultType
{
    self = [super init];
    if (self)
    {
        _resultType = resultType;
		
		// _storeId = ((dict[@"storeId"] != [NSNull null]) && (dict[@"storeId"] != nil)) ? dict[@"storeId"] : @"";
		if ( dict[@"storeId"] != [NSNull null] && dict[@"storeId"] != nil )
		{
			_storeId = dict[@"storeId"];
		}
		else
		{
			_storeId = @"";
		}
        
        _sku = dict[@"sku"];
        
        _days = [dict[@"freightTime"] integerValue];
        
        NSString *freightValue = dict[@"freightPrice"];
        
        if ([freightValue floatValue] == 0.0f)
        {
            _priceString = @"Frete Grátis";
        }
        else
        {
            NSNumber *price = [dict valueForKeyPath:@"freightPrice"];
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            formatter.numberStyle = NSNumberFormatterCurrencyStyle;
            formatter.locale = [NSLocale localeWithLocaleIdentifier:@"pt-BR"];
            NSString *newPriceString = [formatter stringFromNumber:price];
            _priceString = [newPriceString stringByReplacingOccurrencesOfString:@"$" withString:@"$ "];
        }
        
        _decision = [dict valueForKeyPath:@"decision"];
        
        _warningKey = [dict valueForKeyPath:@"warning.key"];
        
        _warningQuantity = [dict valueForKeyPath:@"warning.quantity"];
        
        if (_warningKey && [_warningKey isEqualToString:@"STOCK"] && _warningQuantity && [_warningQuantity integerValue] == 0)
        {
            _resultType = B2WAPIFreightCalculationResultNoStock;
        }
        if (_warningKey && [_warningKey isEqualToString:@"MARKETPLACE"])
        {
            _resultType = B2WAPIFreightCalculationResultNoStock;
        }
    }
    
    return self;
}

- (instancetype)initWithStoreId:(NSString *)storeId resultType:(B2WAPIFreightCalculationResultType)resultType
{
    self = [super init];
    if (self)
    {
        _resultType = resultType;
        _storeId = storeId;
    }
    
    return self;
}

- (NSString *)daysString
{
    if (self.days <= 1)
    {
        return @"Um dia útil";
    }
    return [NSString stringWithFormat:@"%lu dias úteis", (unsigned long)self.days];
}

@end