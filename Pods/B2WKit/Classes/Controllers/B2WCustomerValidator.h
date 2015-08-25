//
//  B2WValidatorPerson.h
//  B2WKit
//
//  Created by Thiago Peres on 12/8/12.
//  Copyright (c) 2012 Eduardo Callado. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PasswordValidation) {
    PasswordValidationErrorTooShort,
    PasswordValidationErrorTooLong,
    PasswordValidationSucceded
};

@interface NSString (CustomerMasks)

//- (NSString *)maskedEmail;
//- (NSString *)maskedPassword;
//- (NSString *)maskedName;
- (NSString *)maskedCPFString;
- (NSString *)maskedCNPJString;
- (NSString *)maskedBirthDate;
- (NSString *)maskedPhoneString;

@end

@interface NSString (CustomerValidations)

- (PasswordValidation)isValidPassword;
/*- (BOOL)isValidCPFString;
- (BOOL)isValidCNPJString;
- (BOOL)isValidBirthDate;
- (BOOL)isValidPhoneNumber;*/

@end
