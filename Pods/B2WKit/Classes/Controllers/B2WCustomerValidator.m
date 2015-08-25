//
//  B2WCustomerValidator.m
//  B2WKit
//
//  Created by Thiago Peres on 12/8/12.
//  Copyright (c) 2012 Eduardo Callado. All rights reserved.
//

#import "B2WCustomerValidator.h"

#import "B2WValidatorConstants.h"

#import "B2WValidator.h"

@implementation NSString (CustomerMasks)

/*- (NSString *)maskedEmail
{
    NSString *s = self;
    
    if (s.length > kEMAIL_FIELD_MAX_CHARS)
    {
        return [s substringToIndex:s.length-1];
    }
	
    return s;
}*/

/*- (NSString *)maskedPassword
{
    NSString *s = self;
    
    if (s.length > kPASSWORD_FIELD_MAX_CHARS)
    {
        return [s substringToIndex:s.length-1];
    }
	
    return s;
}*/

/*- (NSString *)maskedName
{
    NSString *s = self;
    
    if (s.length > kNAME_FIELD_MAX_CHARS)
    {
        return [s substringToIndex:s.length-1];
    }
	
    return s;
}*/

- (NSString *)maskedCPFString
{
    NSString *s = self;

    s = [s stringByRemovingMask];
    
    if (s.length > 3)
    {
        s = [NSString stringWithFormat:@"%@.%@", [s substringToIndex:3], [s substringFromIndex:3]];
    }
    if (s.length > 7)
    {
        s = [NSString stringWithFormat:@"%@.%@", [s substringToIndex:7], [s substringFromIndex:7]];
    }
    if (s.length > 11)
    {
        s = [NSString stringWithFormat:@"%@-%@", [s substringToIndex:11], [s substringFromIndex:11]];
    }
    
	if (s.length > 14)
    {
        return [s substringToIndex:14];
    }
	
    return s;
}

- (NSString *)maskedCNPJString
{
    NSString *s = self;
    
    s = [s stringByRemovingMask];
    
    if (s.length > 2)
    {
        s = [NSString stringWithFormat:@"%@.%@", [s substringToIndex:2], [s substringFromIndex:2]];
    }
    if (s.length > 6)
    {
        s = [NSString stringWithFormat:@"%@.%@", [s substringToIndex:6], [s substringFromIndex:6]];
    }
    if (s.length > 10)
    {
        s = [NSString stringWithFormat:@"%@/%@", [s substringToIndex:10], [s substringFromIndex:10]];
    }
    if (s.length > 15)
    {
        s = [NSString stringWithFormat:@"%@-%@", [s substringToIndex:15], [s substringFromIndex:15]];
    }
    
    if (s.length > 18)
    {
        return [s substringToIndex:18];
    }
    
    return s;
}

- (NSString *)maskedBirthDate
{
    NSString *s = self;
    
    s = [s stringByRemovingMask];
    
    if (s.length > 2)
    {
        s = [NSString stringWithFormat:@"%@/%@", [s substringToIndex:2], [s substringFromIndex:2]];
    }
    if (s.length > 5)
    {
        s = [NSString stringWithFormat:@"%@/%@", [s substringToIndex:5], [s substringFromIndex:5]];
    }
    
    if (s.length > 10)
    {
        return [s substringToIndex:10];
    }
    
    return s;
}

- (NSString *)maskedPhoneString
{
    NSString *s = self;
    s = [s stringByRemovingMask];

    NSString *firstNumber;
    BOOL isCellphoneWithExtraNumber = NO;

    if (s.length > 10)
    {
        firstNumber = [s substringWithRange:NSMakeRange(2, 1)];
        
        if ([firstNumber isEqualToString:@"9"])
            isCellphoneWithExtraNumber = YES;
    }
    else
    {
        isCellphoneWithExtraNumber = NO;
    }
    
    if (isCellphoneWithExtraNumber)
    {
        if (s.length > 2)
        {
            s = [NSString stringWithFormat:@"(%@) %@", [s substringToIndex:2], [s substringFromIndex:2]];
        }
        if (s.length > 9)
        {
            s = [NSString stringWithFormat:@"%@-%@", [s substringToIndex:10], [s substringFromIndex:10]];
        }
        
        if (s.length > 15)
        {
            return [s substringToIndex:15];
        }
    }
    else
    {
        if (s.length > 2)
        {
            s = [NSString stringWithFormat:@"(%@) %@", [s substringToIndex:2], [s substringFromIndex:2]];
        }
        if (s.length > 9)
        {
            s = [NSString stringWithFormat:@"%@-%@", [s substringToIndex:9], [s substringFromIndex:9]];
        }
        
        if (s.length > 14)
        {
            return [s substringToIndex:14];
        }
    }
    
    return s;
}

@end

@implementation NSString (CustomerValidations)

- (PasswordValidation)isValidPassword
{
    if (self.length < kPASSWORD_FIELD_MIN_CHARS)
        return PasswordValidationErrorTooShort;
    
    if (self.length > kPASSWORD_FIELD_MAX_CHARS)
        return PasswordValidationErrorTooLong;
    
    return PasswordValidationSucceded;
}

/*- (BOOL)isValidCPFString
{
    NSString *cpf = self;
    cpf = [cpf stringByRemovingMask];

    if (cpf == nil) return NO;

    NSUInteger i, firstSum, secondSum, firstDigit, secondDigit, firstDigitCheck, secondDigitCheck;
    
    if ([cpf length] != 11) return NO;
    if (([cpf isEqual:@"00000000000"]) || ([cpf isEqual:@"11111111111"]) || ([cpf isEqual:@"22222222222"]) || ([cpf isEqual:@"33333333333"]) || ([cpf isEqual:@"44444444444"]) || ([cpf isEqual:@"55555555555"]) || ([cpf isEqual:@"66666666666"]) || ([cpf isEqual:@"77777777777"]) || ([cpf isEqual:@"88888888888"]) || ([cpf isEqual:@"99999999999"])) return NO;
    
    firstSum = 0;
    for (i = 0; i <= 8; i++) {
        firstSum += [[cpf substringWithRange:NSMakeRange(i, 1)] intValue] * (10 - i);
    }
    
    if (firstSum % 11 < 2)
        firstDigit = 0;
    else
        firstDigit = 11 - (firstSum % 11);
    
    secondSum = 0;
    for (i = 0; i <= 9; i++) {
        secondSum = secondSum + [[cpf substringWithRange:NSMakeRange(i, 1)] intValue] * (11 - i);
    }
    
    if (secondSum % 11 < 2)
        secondDigit = 0;
    else
        secondDigit = 11 - (secondSum % 11);
    
    firstDigitCheck = [[cpf substringWithRange:NSMakeRange(9, 1)] intValue];
    secondDigitCheck = [[cpf substringWithRange:NSMakeRange(10, 1)] intValue];
    
    if ((firstDigit == firstDigitCheck) && (secondDigit == secondDigitCheck))
        return YES;
    
    return NO;
}

- (BOOL)isValidCNPJString
{
    NSString *cnpj = self;
    cnpj = [cnpj stringByRemovingMask];
    if (cnpj == nil) return NO;
    if ([cnpj length] != 14) return NO;
    return YES;
}

- (BOOL)isValidBirthDate
{
    NSString *s = self;
    
    if (s.length == 10)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSDate *date = [dateFormatter dateFromString:s];
        
        return (date != nil);
    }
    
    return NO;
}

- (BOOL)isValidPhoneNumber
{
    NSString *s = self;
    
    if ([s length] < 14 || [s length] > 15)
        return NO;
    else
        return YES;
}*/

@end
