//
//  B2WAddressValidator.m
//  B2WKit
//
//  Created by Thiago Peres on 12/8/12.
//  Copyright (c) 2012 Eduardo Callado. All rights reserved.
//

#import "B2WAddressValidator.h"

#import "B2WValidatorConstants.h"

#import "B2WCustomerValidator.h"

#import "B2WValidator.h"

@implementation NSString (AddressMasks)

- (NSString *)maskedPostalCodeString
{
    NSString *s = self;
    
    s = [s stringByRemovingMask];
    
    if (s.length > 5)
    {
        s = [NSString stringWithFormat:@"%@-%@",  [s substringToIndex:5], [s substringFromIndex:5]];
    }
    
    if (s.length > 9)
    {
        return [s substringToIndex:9];
    }
        
    return s;
}

@end

@implementation NSString (AddressValidations)

/*- (BOOL)isValidPostalCodeString
{
    NSString *postalCode = self;
    postalCode = [postalCode stringByRemovingMask];
    if (postalCode == nil) return NO;
    if ([postalCode length] != kPOSTALCODE_FIELD_MAX_CHARS-1) return NO;
    return YES;
}*/

@end
