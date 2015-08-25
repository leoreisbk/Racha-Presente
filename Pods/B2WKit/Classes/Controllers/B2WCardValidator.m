//
//  B2WCardValidator.m
//  B2WKit
//
//  Created by Thiago Peres on 12/8/12.
//  Copyright (c) 2012 Eduardo Callado. All rights reserved.
//

#import "B2WCardValidator.h"

#import "B2WValidatorConstants.h"
#import "B2WCustomerValidator.h"
#import "B2WValidator.h"

@implementation B2WValidatorCard

// FIXME: Diners não confere
+ (CreditCardBrand)cardBrandWithNumber:(NSString *)cardNumber
{
    if ([cardNumber length] < kNUMBER_FIELD_MIN_CHARS) return CreditCardBrandUnknown;
    
    CreditCardBrand cardType;
    NSRegularExpression *regex;
    NSError *error;
    
    for (NSUInteger i = 0; i < CreditCardBrandUnknown; ++i)
    {
        cardType = i;
        
        switch(i)
        {
            case CreditCardBrandVisa:
                regex = [NSRegularExpression regularExpressionWithPattern:kVISA_TYPE options:0 error:&error];
                break;
            case CreditCardBrandMasterCard:
                regex = [NSRegularExpression regularExpressionWithPattern:kMASTER_CARD_TYPE options:0 error:&error];
                break;
            case CreditCardBrandAmex:
                regex = [NSRegularExpression regularExpressionWithPattern:kAMEX_TYPE options:0 error:&error];
                break;
            case CreditCardBrandDinersClub:
                regex = [NSRegularExpression regularExpressionWithPattern:kDINERS_CLUB_TYPE options:0 error:&error];
                break;
            case CreditCardBrandDiscover:
                regex = [NSRegularExpression regularExpressionWithPattern:kDISCOVER_TYPE options:0 error:&error];
                break;
            case CreditCardBrandAura:
                if ([cardNumber isValidAura]) return cardType;
                break;
		}
        
		NSUInteger matches = [regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, 4)];
        if (matches == 1) return cardType;
	}
    
    return CreditCardBrandUnknown;
}

+ (NSString *)convertToString:(CreditCardBrand)brand
{
	NSString *result = nil;
	
	switch (brand)
	{
		case CreditCardBrandVisa:
			result = @"VISA";
			break;
		case CreditCardBrandMasterCard:
			result = @"MASTERCARD";
			break;
		case CreditCardBrandAmex:
			result = @"AMEX";
			break;
		case CreditCardBrandDinersClub:
			result = @"DINERS";
			break;
		case CreditCardBrandDiscover:
			result = @"DISCOVER";
			break;
		case CreditCardBrandAura:
			result = @"AURA";
			break;
		case CreditCardBrandHiperCard:
			result = @"HIPERCARD";
			break;
		case CreditCardBrandUnknown:
			result = @"Unknown";
			break;
	}
	
	// result = [NSString stringWithFormat:@"CARTAO_%@", result];
	
	return result;
}

+ (CreditCardBrand)convertToCreditCardBrand:(NSString *)brand
{
    if ([brand containsString:@"VISA"])
    {
        return CreditCardBrandVisa;
    }
    else if ([brand containsString:@"MASTERCARD"])
    {
        return CreditCardBrandMasterCard;
    }
    else if ([brand containsString:@"AMEX"])
    {
        return CreditCardBrandAmex;
    }
    else if ([brand containsString:@"DINERS"])
    {
        return CreditCardBrandDinersClub;
    }
    else if ([brand containsString:@"AURA"])
    {
        return CreditCardBrandAura;
    }
    else if ([brand containsString:@"HIPERCARD"])
    {
        return CreditCardBrandHiperCard;
    }
    
    return CreditCardBrandUnknown;
}

+ (NSString *)maskedGeneralCardNumberStringString:(NSString *)number
{
    number = [number stringByRemovingMask];
	
    if (number.length > 4)
    {
        number = [NSString stringWithFormat:@"%@ %@", [number substringToIndex:4], [number substringFromIndex:4]];
    }
    if (number.length > 9)
    {
        number = [NSString stringWithFormat:@"%@ %@", [number substringToIndex:9], [number substringFromIndex:9]];
    }
    if (number.length > 14)
    {
        number = [NSString stringWithFormat:@"%@ %@", [number substringToIndex:14], [number substringFromIndex:14]];
    }
    
    if (number.length > kCARD_NUMBER_FIELD_MAX_CHARS + 3)
    {
        return [number substringToIndex:kCARD_NUMBER_FIELD_MAX_CHARS + 3];
    }
    
    return number;
}

+ (NSString *)maskedAmexCardNumberString:(NSString *)number
{
    number = [number stringByRemovingMask];
    
    if (number.length > 4)
    {
        number = [NSString stringWithFormat:@"%@ %@", [number substringToIndex:4], [number substringFromIndex:4]];
    }
    if (number.length > 11)
    {
        number = [NSString stringWithFormat:@"%@ %@", [number substringToIndex:11], [number substringFromIndex:11]];
    }
    
    if (number.length > kCARD_AMEX_NUMBER_FIELD_MAX_CHARS + 2)
    {
        return [number substringToIndex:kCARD_AMEX_NUMBER_FIELD_MAX_CHARS + 2];
    }
    
    return number;
}

+ (NSString *)maskedDinersCardNumberString:(NSString *)number
{
	return [B2WValidatorCard maskedAmexCardNumberString:number];
}

+ (NSString *)maskedAuraCardNumberString:(NSString *)number
{
    number = [number stringByRemovingMask];
    
    if (number.length > 4)
    {
        number = [NSString stringWithFormat:@"%@ %@", [number substringToIndex:4], [number substringFromIndex:4]];
    }
    if (number.length > 9)
    {
        number = [NSString stringWithFormat:@"%@ %@", [number substringToIndex:9], [number substringFromIndex:9]];
    }
    if (number.length > 14)
    {
        number = [NSString stringWithFormat:@"%@ %@", [number substringToIndex:14], [number substringFromIndex:14]];
    }
    if (number.length > 19)
    {
        number = [NSString stringWithFormat:@"%@ %@", [number substringToIndex:19], [number substringFromIndex:19]];
    }
    
    if (number.length > kCARD_AURA_NUMBER_FIELD_MAX_CHARS + 4)
    {
        return [number substringToIndex:kCARD_AURA_NUMBER_FIELD_MAX_CHARS + 4];
    }
    
    return number;
}

@end

@implementation NSString (CardMasks)

- (NSString *)maskedCardNumberString
{
    CreditCardBrand brand = [B2WValidatorCard cardBrandWithNumber:self];
    
    if (brand == CreditCardBrandAmex)
	{
        return [B2WValidatorCard maskedAmexCardNumberString:self];
	}
	else if (brand == CreditCardBrandDinersClub)
	{
		return [B2WValidatorCard maskedDinersCardNumberString:self];
	}
    else if (brand == CreditCardBrandAura)
	{
        return [B2WValidatorCard maskedAuraCardNumberString:self];
	}
    else
	{
        return [B2WValidatorCard maskedGeneralCardNumberStringString:self];
	}
}

- (NSString *)maskedExpirationDateString
{
    NSString *s = self;
    
    s = [s stringByRemovingMask];
    
    if (s.length > 2)
    {
        s = [NSString stringWithFormat:@"%@/%@", [s substringToIndex:2], [s substringFromIndex:2]];
    }
    
    if (s.length > 5)
    {
        return [s substringToIndex:5];
    }
    
    return s;
}

- (NSString *)maskedCVVString
{
    NSString *s = self;
    
    s = [s stringByRemovingMask];
    
    if (s.length > 4)
    {
        return [s substringToIndex:4];
    }
    
    return s;
}

@end

@implementation NSString (CardValidations)

/*- (BOOL)isValidName
{
    NSString *name = self;
    if (name == nil) return NO;
    if (([name length] < kNAME_FIELD_MIN_CHARS) || ([name length] > kNAME_FIELD_MAX_CHARS)) return NO;
    
    return YES;
}*/

- (BOOL)isValidExpirationDate
{
    NSString *dateString = self;
    if (dateString == nil) return NO;
    if ([dateString length] == 5)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/yy"];
        NSDate *date = [dateFormatter dateFromString:dateString];
        
        return (date != nil);
    }
    
    return NO;
}

- (BOOL)isValidAura
{
    NSString *number = self;
    number = [number stringByRemovingMask];
    
    if ([number length] != kCARD_AURA_NUMBER_FIELD_MAX_CHARS)
        return NO;
    
    NSInteger lintSoma = 0;
    
    int lintDigito = [[number substringFromIndex:[number length] - 1] intValue];
    
    for (int i = 0; i < [number length] - 1; i++) {
        
        int lintMod = (i + 1) % 2;
        int lintNumAux = 0;
        NSString *caracter = [number substringWithRange:NSMakeRange(i,1)];
        
        if (lintMod==1) {
            lintNumAux = [caracter intValue] * 1;
        } else {
            lintNumAux = [caracter intValue] * 2;
        }
        
        int lintModAux = lintNumAux % 10;
        
        lintSoma = lintSoma + (lintNumAux / 10) + lintModAux;
        
    }
    
    int lIntResto = lintSoma % 10;
    int lIntDigitoCC = 10 - lIntResto;
    if (lIntDigitoCC == 10) {
        lIntDigitoCC = 0;
    }
    if (lIntDigitoCC != lintDigito) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isValidCVV
{
    NSString *cvv = self;
    if (cvv == nil) return NO;
    if ([cvv length] < kCVV_FIELD_MIN_CHARS) return NO;
 
    return YES;
}

@end
