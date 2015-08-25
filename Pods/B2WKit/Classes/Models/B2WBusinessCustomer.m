//
//  B2WBusinessCustomer.m
//  B2WKit
//
//  Created by Mobile on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WBusinessCustomer.h"
#import "B2WAPICustomer.h"
#import "B2WAddress.h"
#import "B2WCustomerValidator.h"
#import "B2WValidator.h"

@implementation B2WBusinessCustomer

+ (B2WBusinessCustomerIERecipient)ieRecipientFromString:(NSString *)string
{
    if (string == nil)
    {
        return B2WBusinessCustomerIERecipientUnknown;
    }
	
	if ([string isEqualToString:@"TAX_PAYER"])
    {
        return B2WBusinessCustomerIERecipientTaxPayer;
    }
    else if ([string isEqualToString:@"NON_TAX_PAYER"])
    {
        return B2WBusinessCustomerIERecipientNonTaxPayer;
    }
	else if ([string isEqualToString:@"EXEMPT_FROM_TAXES"])
	{
		return B2WBusinessCustomerIERecipientExemptFromTaxes;
	}
	
    return B2WBusinessCustomerIERecipientUnknown;
}

+ (NSString *)stringFromIERecipient:(B2WBusinessCustomerIERecipient)recipient
{
	if (recipient == B2WBusinessCustomerIERecipientTaxPayer)
	{
		return @"TAX_PAYER";
	}
	else if (recipient == B2WBusinessCustomerIERecipientNonTaxPayer)
	{
		return @"NON_TAX_PAYER";
	}
	else if (recipient == B2WBusinessCustomerIERecipientExemptFromTaxes)
	{
		return @"EXEMPT_FROM_TAXES";
	}
	
	return @"";
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _corporateName = dictionary[@"corporateName"];
        _responsibleName = dictionary[@"responsibleName"];
        _cnpj = [dictionary[@"cnpj"] maskedCNPJString];
        _stateInscription = dictionary[@"stateInscription"];
        _IERecipientindicator = [B2WBusinessCustomer ieRecipientFromString:dictionary[@"indicatorIERecipient"]];
		
		super.oneClickEnabled = [dictionary[@"oneClick"] boolValue];
    }
    return self;
}

- (NSDictionary *)dictionaryValueForUpdatingAccount
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryValue]];
	
	if (self.IERecipientindicator == B2WBusinessCustomerIERecipientTaxPayer ||
	   self.IERecipientindicator == B2WBusinessCustomerIERecipientNonTaxPayer)
	{
		dictionary[@"type"] = @{@"pj": @{@"corporateName": self.corporateName,
										 @"responsibleName": self.responsibleName,
										 //@"cnpj": [self.cnpj stringByRemovingMask],
										 @"stateInscription": [self.stateInscription stringByRemovingMask],
										 @"indicatorIERecipient": [B2WBusinessCustomer stringFromIERecipient:self.IERecipientindicator]}};
	}
	else if(self.IERecipientindicator == B2WBusinessCustomerIERecipientExemptFromTaxes)
	{
		dictionary[@"type"] = @{@"pj": @{@"corporateName": self.corporateName,
										 @"responsibleName": self.responsibleName,
										 //@"cnpj": [self.cnpj stringByRemovingMask],
										 @"indicatorIERecipient": [B2WBusinessCustomer stringFromIERecipient:self.IERecipientindicator]}};
	}
	
	return dictionary;
}

- (NSDictionary *)dictionaryValueForCreatingNewAccount
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryValue]];
	
	if(self.IERecipientindicator == B2WBusinessCustomerIERecipientTaxPayer ||
	   self.IERecipientindicator == B2WBusinessCustomerIERecipientNonTaxPayer)
	{
		dictionary[@"type"] = @{@"pj": @{@"corporateName": self.corporateName,
										 @"responsibleName": self.responsibleName,
										 @"cnpj": [self.cnpj stringByRemovingMask],
										 @"stateInscription": [self.stateInscription stringByRemovingMask],
										 @"indicatorIERecipient": [B2WBusinessCustomer stringFromIERecipient:self.IERecipientindicator]}};
	}
	else if (self.IERecipientindicator == B2WBusinessCustomerIERecipientExemptFromTaxes)
	{
		dictionary[@"type"] = @{@"pj": @{@"corporateName": self.corporateName,
										 @"responsibleName": self.responsibleName,
										 @"cnpj": [self.cnpj stringByRemovingMask],
										 @"indicatorIERecipient": [B2WBusinessCustomer stringFromIERecipient:self.IERecipientindicator]}};
	}
	
	return dictionary;
}

- (AFHTTPRequestOperation *)createWithAddress:(B2WAddress *)address block:(B2WAPICompletionBlock)block
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryValueForCreatingNewAccount]];
    
    if (address)
    {
        dictionary[@"address"] = [address dictionaryValue];
    }
    
    return [B2WAPICustomer createCustomerWithCustomerDictionary:dictionary block:block];
}

- (AFHTTPRequestOperation *)updateWithBlock:(B2WAPICompletionBlock)block
{
    if (self.identifier)
    {
        return [B2WAPICustomer requestWithMethod:@"POST"
                                        resource:B2WAPICustomerResourceNone
                              resourceIdentifier:self.identifier
                                      parameters:[self dictionaryValue]
                                           block:block];
    }
    
    return [B2WAPICustomer createCustomerWithCustomerDictionary:[self dictionaryValueForUpdatingAccount] block:block];
}

@end
