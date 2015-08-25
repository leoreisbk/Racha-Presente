//
//  B2WBreadcrumb.m
//  B2WKit
//
//  Created by rodrigo.fontes on 08/01/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WBreadcrumb.h"

@implementation B2WBreadcrumb

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
        _label = dictionary[@"_label"];
        _link  = dictionary[@"_link"];
    }
    return self;
}

@end