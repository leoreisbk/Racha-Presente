//
//  B2WCartCustomer.m
//  B2WKit
//
//  Created by rodrigo.fontes on 31/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WCartCustomer.h"

@implementation B2WCartCustomer

- (instancetype)initWithIdentifier:(NSString *)identifier
							 token:(NSString *)token;
//							 guest:(BOOL) isGuest
{
	self = [self init];
	if (self)
	{
		_identifier = identifier;
		_token = token;
		_guest = NO;
	}
	return self;
}

- (instancetype)initWithCartCustomerDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self)
    {
        _identifier = dictionary[@"id"];
        _token = dictionary[@"token"];
        _guest = dictionary[@"guest"];
    }
    return self;
}

- (NSDictionary *)dictionaryValue
{
	return @{ @"id" : _identifier,
			  @"token" : _token,
			  @"guest" : @(_guest) };
	
}

+ (NSDictionary *)emptyDictionaryValue
{
	return @{ @"id" : @"",
			  @"token" : @"",
			  @"guest" : @(NO) };
}

@end
