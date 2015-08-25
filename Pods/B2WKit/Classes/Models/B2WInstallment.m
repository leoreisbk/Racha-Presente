//
//  B2WInstallment.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WInstallment.h"

@implementation B2WInstallment

#pragma mark - Initialization

- (instancetype)initWithQuantity:(NSInteger)quantity
						   value:(CGFloat)value
					interestRate:(CGFloat)interestRate
				  interestAmount:(CGFloat)interestAmount
					   annualCET:(CGFloat)annualCET
						   total:(CGFloat)total
{
	self = [self init];
	if (self)
	{
		_quantity = quantity;
		_value = value;
		_interestRate = interestRate;
		_interestAmount = interestAmount;
		_annualCET = annualCET;
		_total = total;
	}
	return self;
}

- (instancetype)initWithInstallmentDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self)
    {
        _quantity = [dictionary[@"quantity"] integerValue];
        _value = [dictionary[@"value"] floatValue];
        _interestRate = [dictionary[@"interestRate"] floatValue];
        _interestAmount = [dictionary[@"interestAmount"] floatValue];
        _annualCET = [dictionary[@"annualCET"] floatValue];
        _total = [dictionary[@"total"] floatValue];
    }
    return self;
}

@end
