//
//  B2WIndividualCustomer.m
//  B2WKit
//
//  Created by Mobile on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WIndividualCustomer.h"
#import "B2WAPICustomer.h"
#import "B2WAddress.h"
#import "B2WCustomerValidator.h"
#import "B2WValidator.h"

@implementation NSString (DateString)

- (NSString *)formattedDateStringWithSlash
{
    if (self.length == 0) return @"00/00/0000";
    
    NSString *myString = self;
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *yourDate = [dateFormatter dateFromString:myString];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [formatter stringFromDate:yourDate];
    
    return (stringFromDate ?: @"0001-13-01");
}

- (NSString *)formattedDateStringWithHyphen
{
	NSString *myString = self;
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *yourDate = [dateFormatter dateFromString:myString];
    
	NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:yourDate];
    
    return stringFromDate;
}

@end

@implementation B2WIndividualCustomer

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _fullName = dictionary[@"fullName"];
        _nickname = dictionary[@"nickname"];
        _cpf = [dictionary[@"cpf"] maskedCPFString];
        _gender = [dictionary[@"gender"] isEqualToString:@"M"] ? B2WIndividualCustomerGenderMale : B2WIndividualCustomerGenderFemale;
		_birthDate = [dictionary[@"birthday"] formattedDateStringWithHyphen];
		
		super.oneClickEnabled = [dictionary[@"oneClick"] boolValue];
    }
    return self;
}

- (NSDictionary *)dictionaryValueForUpdatingAccount
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryValue]];
    
    dictionary[@"type"] = @{@"pf": @{@"fullName": self.fullName,
                                     @"nickname": self.nickname,
                                     //@"cpf": [self.cpf stringByRemovingMask],
                                     @"gender": self.gender == B2WIndividualCustomerGenderMale ? @"M" : @"F",
									 @"birthday": [self.birthDate formattedDateStringWithSlash]}};
	
	return dictionary;
}

- (NSDictionary *)dictionaryValueForCreatingNewAccount
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryValue]];
	
	dictionary[@"type"] = @{@"pf": @{@"fullName": self.fullName,
									 @"nickname": self.nickname,
									 @"cpf": [self.cpf stringByRemovingMask],
									 @"gender": self.gender == B2WIndividualCustomerGenderMale ? @"M" : @"F",
									 @"birthday": [self.birthDate formattedDateStringWithSlash]}};
	
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
                                      parameters:[self dictionaryValueForUpdatingAccount]
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
