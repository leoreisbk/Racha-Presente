//
//  B2WSpecification.m
//  B2Wkit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WSpecification.h"

@implementation B2WSpecification

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _title                   = dictionary[@"_title"];

        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        for (id obj in [dictionary arrayForKey:@"specTec"])
        {
            dic[obj[@"_key"]] = obj[@"_value"];
        }
        
        _items = dic;
    }
    
    return self;
}

@end
