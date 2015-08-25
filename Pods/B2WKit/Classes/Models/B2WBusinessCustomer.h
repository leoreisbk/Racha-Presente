//
//  B2WBusinessCustomer.h
//  B2WKit
//
//  Created by Mobile on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "B2WCustomer.h"

typedef NS_ENUM(NSInteger, B2WBusinessCustomerIERecipient)
{
    B2WBusinessCustomerIERecipientTaxPayer,
	B2WBusinessCustomerIERecipientNonTaxPayer,
    B2WBusinessCustomerIERecipientExemptFromTaxes,
    B2WBusinessCustomerIERecipientUnknown
};

@interface B2WBusinessCustomer : B2WCustomer

@property (nonatomic, strong) NSString *corporateName;

@property (nonatomic, strong) NSString *responsibleName;

@property (nonatomic, strong) NSString *cnpj;

@property (nonatomic, strong) NSString *stateInscription;

@property (nonatomic, assign) B2WBusinessCustomerIERecipient IERecipientindicator;

@end
