//
//  B2WInstallment.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WInstallment : B2WObject

@property (nonatomic, readonly) NSInteger quantity;
@property (nonatomic, readonly) CGFloat value;
@property (nonatomic, readonly) CGFloat interestRate;
@property (nonatomic, readonly) CGFloat interestAmount;
@property (nonatomic, readonly) CGFloat annualCET;
@property (nonatomic, readonly) CGFloat total;

- (instancetype)initWithQuantity:(NSInteger)quantity
						   value:(CGFloat)value
					interestRate:(CGFloat)interestRate
				  interestAmount:(CGFloat)interestAmount
					   annualCET:(CGFloat)annualCET
						   total:(CGFloat)total;

- (instancetype)initWithInstallmentDictionary:(NSDictionary*)dictionary;

@end
