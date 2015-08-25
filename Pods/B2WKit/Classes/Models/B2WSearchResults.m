//
//  B2WSearchResult.m
//  B2WKit
//
//  Created by Thiago Peres on 16/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WSearchResults.h"
#import "B2WFacetItem.h"
#import "B2WFacet.h"
#import "B2WProduct.h"

@implementation B2WSearchResults

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _products         = [B2WProduct objectsWithDictionaryArray:dictionary[@"products"]];
        _facets           = [B2WFacet objectsWithDictionaryArray:dictionary[@"facets"]];
        _departmentFacets = [B2WFacet objectsWithDictionaryArray:dictionary[@"facets_departments"]];
		_totalResultCount = [dictionary[@"query_metadata"][@"total_result_count"] stringValue];
    }
    return self;
}

@end
