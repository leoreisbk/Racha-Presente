//
//  B2WSKUInformation.m
//  B2WKit
//
//  Created by Thiago Peres on 14/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WSKUInformation.h"

@implementation B2WSKUInformation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _primaryColorString   = dictionary[@"_primaryColor"];
        _secondaryColorString = dictionary[@"_secundaryColor"];
        _sizeString           = dictionary[@"_size"];

        if ([dictionary containsObjectForKey:@"_name"])
        {
            _name = dictionary[@"_name"];
        }
        else if (_primaryColorString && _secondaryColorString && _sizeString)
        {
            _name = [NSString stringWithFormat:@"%@ %@ %@", _primaryColorString, _secondaryColorString, _sizeString];
        }

        if (dictionary[@"_value"])
        {
            _SKUIdentifier = dictionary[@"_value"];
        }
        else
        {
            _SKUIdentifier = dictionary[@"_sku"];
        }

        if ([dictionary containsObjectForKey:@"_image"])
        {
            _imageURL = [NSURL URLWithString:dictionary[@"_image"]];
        }
    }
    
    return self;
}

-(BOOL)isVisible
{
    if ([_name isEqualToString:@"DEFAULT"])
    {
        return FALSE;
    }
    
    return TRUE;
}

@end
