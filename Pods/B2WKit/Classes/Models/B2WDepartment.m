//
//  B2WDepartment.m
//  B2Wkit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WDepartment.h"

@implementation B2WDepartment

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
        _name       = dictionary[@"_name"];
        _identifier = dictionary[@"_menuId"];
        _group      = [dictionary[@"_group"] stringByReplacingOccurrencesOfString:@"," withString:@""];
        _tag        = [dictionary[@"_tag"] stringByReplacingOccurrencesOfString:@"," withString:@""];
        
        _haveChildren = ([dictionary[@"_haveChildren"] isEqualToString:@"true"]);
    }
    return self;
}

@end
