//
//  B2WIndividualCustomer.h
//  B2WKit
//
//  Created by Mobile on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "B2WCustomer.h"

typedef NS_ENUM(NSInteger, B2WIndividualCustomerGender)
{
    B2WIndividualCustomerGenderMale,
    B2WIndividualCustomerGenderFemale
};

@interface NSString (DateString)

- (NSString *)formattedDateStringWithHyphen;
- (NSString *)formattedDateStringWithSlash;

@end

@interface B2WIndividualCustomer : B2WCustomer

@property (nonatomic, strong) NSString *fullName;

@property (nonatomic, strong) NSString *nickname;

@property (nonatomic, strong) NSString *cpf;

@property (nonatomic, assign) B2WIndividualCustomerGender gender;

@property (nonatomic, strong) NSString *birthDate;

@end
