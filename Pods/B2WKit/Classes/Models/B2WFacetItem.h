//
//  B2WFacetItem.h
//  B2WKit
//
//  Created by Thiago Peres on 14/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@class B2WFacet;

@interface B2WFacetItem : B2WObject

/// The facet item's title.
@property (nonatomic, readonly) NSString *title;

/// The facet item's parameters.
@property (nonatomic, readonly) NSDictionary *parameters;

/**
 *  The number of products that match the facet criteria.
 */
@property (nonatomic, readonly) NSUInteger productCount;

@property (nonatomic, readonly) BOOL enabled;

@property (nonatomic, readonly) BOOL selected;

@end
