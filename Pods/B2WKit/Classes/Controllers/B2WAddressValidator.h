//
//  B2WAddressValidator.h
//  B2WKit
//
//  Created by Thiago Peres on 12/8/12.
//  Copyright (c) 2012 Eduardo Callado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AddressMasks)

- (NSString *)maskedPostalCodeString;

@end

@interface NSString (AddressValidations)

//- (BOOL)isValidPostalCodeString;

@end
