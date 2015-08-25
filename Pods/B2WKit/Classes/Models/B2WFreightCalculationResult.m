//
//  B2WFreightCalculationResult.m
//  B2WKit
//
//  Created by Thiago Peres on 27/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WFreightCalculationResult.h"

#import "B2WFreightCalculationProduct.h"
#import "B2WAddressValidator.h"

@implementation B2WFreightCalculationResult

- (instancetype)initWithDictionary:(NSDictionary *)dict postalCode:(NSString *)postalCode
{
    self = [super init];
    if (self)
    {
        NSString *errorMessage = dict[@"errorMessage"];
		
        if ([errorMessage isEqualToString:@"CEP_INEXISTENTE"])
        {
            _resultType = B2WAPIFreightCalculationResultInexistingPostalCode;
        }
        else if ([errorMessage isEqualToString:@"CEP_INEXISTENTE_MKT"])
        {
            _resultType = B2WAPIFreightCalculationResultBlockedDelivery;
        }
        else if ([errorMessage isEqualToString:@"ERRO_GENERICO"])
        {
            _resultType = B2WAPIFreightCalculationResultGenericError;
        }
        else if ([errorMessage isEqualToString:@"SEM_ESTOQUE"])
        {
            _resultType = B2WAPIFreightCalculationResultNoStock;
        }
        else
		{
            _resultType = B2WAPIFreightCalculationResultOK;
        }
        
//        NSString *riskAreaDeliveryString = dict[@"riskAreaDelivery"];
//        if ([riskAreaDeliveryString isEqualToString:@"blocked"])
//        {
//            _resultType = B2WAPIFreightCalculationResultBlockedDelivery;
//        }
//        if ([riskAreaDeliveryString isEqualToString:@"restricted"])
//        {
//            _resultType = B2WAPIFreightCalculationResultRestrictedDelivery;
//        }
//        if ([riskAreaDeliveryString isEqualToString:@"partial"])
//        {
//            _resultType = B2WAPIFreightCalculationResultPartial;
//        }
//        if ([riskAreaDeliveryString isEqualToString:@"normal"])
//        {
//            _resultType = B2WAPIFreightCalculationResultOK;
//        }
        
		_postalCode = [postalCode maskedPostalCodeString]; //[[dict[@"cep"] stringValue] maskedPostalCodeString];
		
        _deliveryAt = dict[@"deliveryAt"];
        
        if ([dict valueForKeyPath:@"freightOptions.contract"] != [NSNull null] &&
			[dict valueForKeyPath:@"freightOptions.contract"] != nil)
        {
            _contract = [[dict valueForKeyPath:@"freightOptions.contract"] firstObject];
        }
        
        if ([dict valueForKeyPath:@"freightOptions.default"] != [NSNull null] &&
			[dict valueForKeyPath:@"freightOptions.default"] != nil &&
			[[dict valueForKeyPath:@"freightOptions.default"] firstObject] != nil)
        {
            _isDefault = [[[dict valueForKeyPath:@"freightOptions.default"] firstObject] boolValue];
        }
        
        if ([dict valueForKeyPath:@"freightOptions.totalWeekdays"] != [NSNull null] &&
			[dict valueForKeyPath:@"freightOptions.totalWeekdays"] != nil)
        {
            _totalWeekdays = [[dict valueForKeyPath:@"freightOptions.totalWeekdays"] firstObject];
        }
        
        if ([dict valueForKeyPath:@"freightOptions.totalFreightPrice"] != [NSNull null] &&
			[dict valueForKeyPath:@"freightOptions.totalFreightPrice"] != nil &&
			[[dict valueForKeyPath:@"freightOptions.totalFreightPrice"] firstObject] != nil)
        {
			/*NSNumber *totalFreightPriceNumber = [[dict valueForKeyPath:@"freightOptions.totalFreightPrice"] firstObject];
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            formatter.numberStyle = NSNumberFormatterCurrencyStyle;
            formatter.locale = [NSLocale localeWithLocaleIdentifier:@"pt-BR"];
            NSString *totalFreightPriceString = [formatter stringFromNumber:totalFreightPriceNumber];
            _totalFreightPrice = [totalFreightPriceString stringByReplacingOccurrencesOfString:@"$" withString:@"$ "];*/
			
			_totalFreightPrice = [[[dict valueForKeyPath:@"freightOptions.totalFreightPrice"] firstObject] stringValue];
		}
		
		if ([dict valueForKeyPath:@"freightOptions.products"] != [NSNull null] &&
			[dict valueForKeyPath:@"freightOptions.products"] != nil &&
			[[dict valueForKeyPath:@"freightOptions.products"] firstObject] != nil)
        {
            NSArray *resultsDict = [[dict valueForKeyPath:@"freightOptions.products"] firstObject];
            NSMutableDictionary *freightResults = [[NSMutableDictionary alloc] initWithCapacity:resultsDict.count];
			
			_productCartResults = [NSMutableArray new];
			
			for (NSDictionary *result in resultsDict)
			{
                B2WFreightCalculationProduct *freightResult = [[B2WFreightCalculationProduct alloc] initWithDictionary:result
																											resultType:_resultType];
                [freightResults setObject:freightResult forKey:freightResult.storeId];
				
				[_productCartResults addObject:freightResult];
            }
			
            _productResults = freightResults;
        }
	}
	
	return self;
}

- (instancetype)initWithResultMessage:(NSString *)resultMessage productParamsArray:(NSArray *)productParamsArray
{
    self = [super init];
    if (self)
    {
        _resultType = B2WAPIFreightCalculationResultGenericError;
        if (resultMessage && [resultMessage isEqualToString:@"CEP_INVALID"])
        {
            _resultType = B2WAPIFreightCalculationResultInexistingPostalCode;
        }
		//else
		//{
			NSMutableDictionary *productResults = [[NSMutableDictionary alloc] initWithCapacity:productParamsArray.count];
			
			for (int i = 0; i < productParamsArray.count; i++)
			{
				B2WFreightCalculationProduct *productFreight = productParamsArray[i];
				B2WFreightCalculationProduct *freightResult = [[B2WFreightCalculationProduct alloc] initWithStoreId:productFreight.storeId resultType:_resultType];
				NSString *storeId = freightResult.storeId == nil ? @"" : freightResult.storeId;
				[productResults setObject:freightResult forKey:storeId];
			}
			
			_productResults = productResults;
		//}
    }
	
    return self;
}

@end