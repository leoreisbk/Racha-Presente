//
//  B2WSearchResult.h
//  B2WKit
//
//  Created by Thiago Peres on 16/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WSearchResults : B2WObject

/// An array containing B2WDepartmentFacet objects.
@property (nonatomic, readonly) NSArray *departmentFacets;

/// An array containing B2WFacet objects.
@property (nonatomic, readonly) NSArray *facets;

/// An array containing B2WProduct objects.
@property (nonatomic, readonly) NSArray *products;

@property (nonatomic, readonly) NSString *totalResultCount;

@end
