//
//  B2WFacet.m
//  B2WKit
//
//  Created by Thiago Peres on 14/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WFacet.h"

// Models
#import "B2WFacetItem.h"
#import "NSDictionary+QueryString.h"

@implementation B2WFacet

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _title      = dictionary[@"title"];
        _parameters = [NSDictionary dictionaryWithQueryString:dictionary[@"params"]];

        _type = B2WFacetTypeNormal;
        if ([dictionary containsObjectForKey:@"type"])
        {
            if ([dictionary[@"type"] isEqualToString:@"range"])
            {
                _type = B2WFacetTypeRange;
            }
        }
        
		_items = [B2WFacetItem objectsWithDictionaryArray:dictionary[@"facet_items"]];
		
		_selected = [dictionary[@"selected"] boolValue];
	}
    return self;
}

- (NSUInteger)hash
{
    return self.title.hash;
}

- (BOOL)isEqual:(B2WFacet *)object
{
    if (! [object isKindOfClass:[B2WFacet class]])
    {
        return NO;
    }
    
    return [object.title isEqualToString:self.title];
}

@end
