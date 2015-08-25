//
//  B2WCardValidator.h
//  B2WKit
//
//  Created by Thiago Peres on 12/8/12.
//  Copyright (c) 2012 Eduardo Callado. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CreditCardBrand) {
    CreditCardBrandVisa,
    CreditCardBrandMasterCard,
    CreditCardBrandDinersClub,
    CreditCardBrandAmex,
    CreditCardBrandDiscover,
    CreditCardBrandAura,
	CreditCardBrandHiperCard,
    CreditCardBrandUnknown
};

@interface B2WValidatorCard : NSObject

+ (CreditCardBrand)cardBrandWithNumber:(NSString *)cardNumber;
+ (NSString *)convertToString:(CreditCardBrand)brand;
+ (CreditCardBrand)convertToCreditCardBrand:(NSString *)brand;

@end

@interface NSString (CardMasks)

- (NSString *)maskedCardNumberString;
- (NSString *)maskedExpirationDateString;
- (NSString *)maskedCVVString;

@end

@interface NSString (CardValidations)

- (BOOL)isValidAura;
- (BOOL)isValidExpirationDate;
- (BOOL)isValidCVV;

@end
