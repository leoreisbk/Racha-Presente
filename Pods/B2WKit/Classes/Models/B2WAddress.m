//
//  B2WAddress.m
//  B2WKit
//
//  Created by Mobile on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WAddress.h"

#import "B2WValidator.h"

@implementation B2WAddress

+ (B2WAddressType)addressTypeFromString:(NSString *)string
{
    if (string == nil)
    {
        return B2WAddressTypePersonal;
    }
    
    if ([string isEqualToString:@"PERSONAL"])
    {
        return B2WAddressTypePersonal;
    }
    else if ([string isEqualToString:@"STORE"])
    {
        return B2WAddressTypeStore;
    }
    else if ([string isEqualToString:@"HEAD_OFFICE"])
    {
        return B2WAddressTypeHeadOffice;
    }
    else if ([string isEqualToString:@"WEDDING_LIST"])
    {
        return B2WAddressTypeWeddingList;
    }
    else if ([string isEqualToString:@"GIFT"])
    {
        return B2WAddressTypeGift;
    }
    
    return B2WAddressTypePersonal;
}

+ (NSString *)stringFromAddressType:(B2WAddressType)type
{
    switch (type)
    {
        case B2WAddressTypeGift: return @"GIFT";
            break;
        case B2WAddressTypeStore: return @"STORE";
            break;
        case B2WAddressTypeHeadOffice: return @"HEAD_OFFICE";
            break;
        case B2WAddressTypeWeddingList: return @"WEDDING_LIST";
            break;
        default:
            break;
    }
    
    return @"PERSONAL";
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _identifier = dictionary[@"id"];
        _name = dictionary[@"name"];
        _recipientName = dictionary[@"recipientName"];
        
        _address = dictionary[@"address"];
        _number = dictionary[@"number"];
        _additionalInfo = dictionary[@"additionalInfo"];
        _neighborhood = dictionary[@"neighborhood"];
        _reference = dictionary[@"reference"];
        _city = dictionary[@"city"];
        _state = dictionary[@"state"];
        _postalCode = dictionary[@"zipCode"];
        _main = [dictionary[@"main"] boolValue];
        
        _addressType = [B2WAddress addressTypeFromString:dictionary[@"addressType"]];
        
        if ([dictionary containsObjectForKey:@"active"])
        {
            _active = [dictionary[@"active"] boolValue];
        }
        
        if ([dictionary containsObjectForKey:@"blockDelivery"])
        {
            _blockedDelivery = [dictionary[@"blockDelivery"] boolValue];
        }
        
        if ([dictionary containsObjectForKey:@"warning"])
        {
            _warnings = dictionary[@"warning"];
        }
    }
    return self;
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[@"name"] = self.name;
    dictionary[@"address"] = self.address;
    dictionary[@"number"] = self.number;
	dictionary[@"recipientName"] = self.recipientName ?: @"";
    dictionary[@"city"] = self.city;
    dictionary[@"state"] = self.state;
    dictionary[@"zipCode"] = [self.postalCode stringByRemovingMask];
    dictionary[@"addressType"] = [B2WAddress stringFromAddressType:self.addressType];
    dictionary[@"main"] = @(self.main);
    dictionary[@"additionalInfo"] = self.additionalInfo;
    dictionary[@"neighborhood"] = self.neighborhood;
    dictionary[@"reference"] = self.reference;
    
    return dictionary;
}

- (AFHTTPRequestOperation *)addNewWithBlock:(B2WAPICompletionBlock)block
{
	return [B2WAPICustomer requestWithMethod:@"POST"
									resource:B2WAPICustomerResourceAddress
						  resourceIdentifier:nil
								   parameters:[self dictionaryValue]
									   block:block];
}

- (AFHTTPRequestOperation *)updateWithBlock:(B2WAPICompletionBlock)block
{
    if (self.identifier)
    {
        return [B2WAPICustomer requestWithMethod:@"PUT"
                                        resource:B2WAPICustomerResourceAddress
							  resourceIdentifier:self.identifier
                                      parameters:[self dictionaryValue]
                                           block:block];
    }
	
    // TODO: Tratar erro
    NSError *error;
    if (block)
    {
        block(nil, error);
    }
	
	NSLog(@"%@", error);
	
    return nil;
}

- (AFHTTPRequestOperation *)removeWithBlock:(B2WAPICompletionBlock)block
{
	if (self.identifier)
	{
		return [B2WAPICustomer requestWithMethod:@"DELETE"
										resource:B2WAPICustomerResourceAddress
							  resourceIdentifier:self.identifier
									  parameters:nil
										   block:block];
	}
	
	// TODO: Tratar erro
	NSError *error;
	if (block)
	{
		block(nil, error);
	}
	
	NSLog(@"%@", error);
	
	return nil;
}

- (AFHTTPRequestOperation *)setAsMainWithBlock:(B2WAPICompletionBlock)block
{
	if (self.identifier)
	{
		return [B2WAPICustomer requestWithMethod:@"PUT"
										resource:B2WAPICustomerResourceAddressAsMain
							  resourceIdentifier:self.identifier
									  parameters:nil
										   block:block];
	}
	
	// TODO: Tratar erro
	NSError *error;
	if (block)
	{
		block(nil, error);
	}
	
	NSLog(@"%@", error);
	
	return nil;
}

@end
