//
//  B2WFacet.h
//  B2WKit
//
//  Created by Thiago Peres on 14/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

typedef NS_ENUM(NSUInteger, B2WFacetType) {
    B2WFacetTypeNormal,
    B2WFacetTypeRange
};

@interface B2WFacet : B2WObject

/// The facet's title.
@property (nonatomic, readonly) NSString *title;

/// The facet's parameters.
@property (nonatomic, readonly) NSDictionary *parameters;

@property (nonatomic, readonly) B2WFacetType type;

/// An array containing B2WFacetItem objects.
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, readonly) BOOL selected;

@end
