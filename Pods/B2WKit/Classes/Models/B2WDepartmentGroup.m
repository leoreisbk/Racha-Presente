//
//  B2WDepartmentGroup.m
//  B2WKit
//
//  Created by Thiago Peres on 18/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WDepartmentGroup.h"
#import "B2WDepartment.h"

@implementation B2WDepartmentGroup

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _name        = dictionary[@"_name"];
        _departments = [B2WDepartment objectsWithDictionaryArray:[dictionary arrayForKey:@"menuItem"]];
    }
    return self;
}

@end
