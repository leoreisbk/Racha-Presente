//
//  B2WSearchController.h
//  B2WKit
//
//  Created by Thiago Peres on 22/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

// Protocols
#import "B2WPagingProtocol.h"

// Networking
#import "B2WAPISearch.h"

@class B2WSearchResults;
@class B2WFacetItem;


@interface B2WSearchController : NSObject <B2WPagingProtocol>

/**
 A B2WSearchResults object fetched on the last request.
 */
@property (nonatomic, readonly) B2WSearchResults *lastSearchResults;

/**
 The search query.
 */
@property (nonatomic, readonly) NSString *query;

@property (nonatomic, strong) B2WFacetItem *facetItem;

/**
 The sort type indicating how results should be ordered.
 */
@property (nonatomic, assign) B2WAPISearchSortType sortType;

/**
 The delegate object to receive update events.
 */
@property (nonatomic, weak) id <B2WPagingResultsDelegate> delegate;

/**
 *  Returns a Search Controller initialized with the given initial search parameters. You must call - requestFirstPage in order to start the search.
 *
 *  @param query          A string containing the desired search term.
 *  @param resultsPerPage An unsigned integer containing the number of desired results per page. Must be greater than zero.
 *  @param sortType       The sort type indicating how results should be sorted.
 *
 *  @return A Search Controller initialized with the given initial search parameters.
 */
- (id)initWithQuery:(NSString *)query resultsPerPage:(NSUInteger)resultsPerPage sortType:(B2WAPISearchSortType)sortType;

@end
