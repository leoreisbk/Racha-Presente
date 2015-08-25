//
//  B2WAPISearch.h
//  B2WKit
//
//  Created by Thiago Peres on 11/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "B2WAPIClient.h"

typedef NS_ENUM(NSUInteger, B2WAPISearchSortType) {
    B2WAPISearchSortRelevance,
    B2WAPISearchSortPriceDescending,
    B2WAPISearchSortPriceAscending,
    B2WAPISearchSortNameAscending,
    B2WAPISearchSortNameDescending,
    B2WAPISearchSortBestRated,
    B2WAPISearchSortBestSellers = 6
};

@class B2WFacetItem;
@class B2WFacet;

@interface B2WAPISearch : NSObject

/**
 *  Requests an array of strings containing search suggestions.
 *
 *  @param string A string containing the desired search term.
 *  @param block  The completion handler block that processes the results.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestSuggestionsWithQuery:(NSString *)string
                                                 block:(B2WAPICompletionBlock)block;

/**
 *  Requests an array of department facets, facets and products.
 *
 *  @param query          A string containing the desired search term.
 *  @param facetItem      Optional. A B2WFacetItem object.
 *  @param page           An unsigned integer containing the desired page. Starts at zero.
 *  @param resultsPerPage An unsigned integer containing the number of desired results per page. Must be greater than zero.
 *  @param sortType       The sort type indicating how results should be sorted.
 *  @param block          The completion handler block that processes results, containing a B2WSearchResult object.
 *
 *  @return The operation object responsible for the request.
 */
/*+ (AFHTTPRequestOperation*)requestWithQuery:(NSString *)query
                                  facetItem:(B2WFacetItem*)facetItem
                                       page:(NSUInteger)page
                             resultsPerPage:(NSUInteger)resultsPerPage
                                   sortType:(enum B2WAPISearchSortType)sortType
                                      block:(B2WAPICompletionBlock)block;

+ (AFHTTPRequestOperation*)requestWithQuery:(NSString *)query
									  facet:(B2WFacet*)facet
									   page:(NSUInteger)page
							 resultsPerPage:(NSUInteger)resultsPerPage
								   sortType:(enum B2WAPISearchSortType)sortType
									  block:(B2WAPICompletionBlock)block;*/

+ (AFHTTPRequestOperation*)requestWithQuery:(NSString *)query
						   facetOrFacetItem:(id)facetOrFacetItem
									   page:(NSUInteger)page
							 resultsPerPage:(NSUInteger)resultsPerPage
								   sortType:(enum B2WAPISearchSortType)sortType
									  block:(B2WAPICompletionBlock)block;

/**
 *  Requests an array of desktop search history strings.
 *
 *  @param block The completion handler block that processes results.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestDesktopSearchHistoryWithBlock:(B2WAPICompletionBlock)block;

@end
