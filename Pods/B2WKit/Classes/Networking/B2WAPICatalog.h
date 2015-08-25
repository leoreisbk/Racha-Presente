//
//  B2WAPICatalog.h
//  B2WKit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WAPIClient.h"

typedef NS_ENUM(NSUInteger, B2WAPICatalogOrderType) {
    B2WAPICatalogOrderAscending,
    B2WAPICatalogOrderDescending
};

typedef NS_ENUM(NSUInteger, B2WAPICatalogEnvironment) {
    B2WAPICatalogEnvironmentDefault,
    B2WAPICatalogEnvironmentStaging,
    B2WAPICatalogEnvironmentAWS
};

extern NSString *const B2WAPICatalogSortName;
extern NSString *const B2WAPICatalogSortReleaseDate;
extern NSString *const B2WAPICatalogSortPrice;
extern NSString *const B2WAPICatalogSortBestSellers;

@interface B2WAPICatalog : NSObject

+ (void)setEnvironment:(B2WAPICatalogEnvironment)environment;
+ (B2WAPICatalogEnvironment)environment;

/**
 *  Requests a single product object.
 *
 *  @param identifier A string containing the product's catalog identifier. This parameter must not be nil.
 *  @param block      The completion handler block that processes the result.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestProductWithIdentifier:(NSString*)identifier
                                                  block:(B2WAPICompletionBlock)block;

/**
 *  Requests an array of products.
 *
 *  @param identifiers An array containing product identifier strings.
 *  @param block       The completion handler block that processes the result.
 *
 *  @return The opration queue responsible for the request.
 */
+ (NSArray*)requestProductsWithIdentifiers:(NSArray*)identifiers
                                     block:(B2WAPICompletionBlock)block;

/**
 *  Requests a single product object.
 *
 *  @param string A string containing the product's EAN code. This parameter must not be nil.
 *  @param block  The completion handler block that processes the results.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestProductWithEANString:(NSString*)string
                                                 block:(B2WAPICompletionBlock)block;

/**
 *  Requests an array of products.
 *
 *  @param identifier      A string containing the department identifier.
 *  @param facetItemsArray The array of selected facet items to filter the request.
 *  @param orderType       The order type indicating how products should be ordered. Defaults to descending if an invalid value is provided.
 *  @param sortType        The sort string indicating how products should be sorted. Defaults to best-seller sorting if an invalid value is provided.
 *  @param page            An unsigned integer containing the desired page. Starts at zero.
 *  @param resultsPerPage  An unsigned integer containing the number of desired results per page. Must be greater than zero.
 *  @param block           The completion handler block that processes results, containing a B2WSearchResult object.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestProductsWithDepartmentIdentifier:(NSString *)identifier
                                                selectedFacetItems:(NSArray *)facetItemsArray
                                                             order:(B2WAPICatalogOrderType)orderType
                                                              sort:(NSString*)sortType
                                                              page:(NSUInteger)page
                                                    resultsPerPage:(NSUInteger)resultsPerPage
                                                             block:(B2WAPICompletionBlock)block;

/**
 *  Requests an array of featured products by department identifier.
 *  If no identifier is supplied, an array of home featured products will be requested.
 *
 *  @param identifier A string containing the department identifier.
 *  @param block      The completion handler block that processes the results.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestFeaturedProductsWithDepartmentIdentifier:(NSString*)identifier
                                                                     block:(B2WAPICompletionBlock)block;

/**
 *  Requests the product lists for the featured view.
 *
 *  @param block The completion handler block that processes the results.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation *)requestFeaturedProductsListsWithBlock:(B2WAPICompletionBlock)block;

/**
 *  Requests the current daily offer product.
 *
 *  @param block The completion handler block that processes the results.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestDailyOfferProductWithBlock:(B2WAPICompletionBlock)block;

/**
 *  Requests an array of departments by department identifier.
 *  If no identifier is supplied, the base/root departments will be requested.
 *
 *  @param identifier A string containing the department identifier.
 *  @param block      The completion handler block that processes the results.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestDepartmentsWithIdentifier:(NSString*)identifier
                                                      block:(B2WAPICompletionBlock)block;

/**
 *  Requests an array of filters with the given department identifier.
 *
 *  @param identifier A string containing the department identifier. Required.
 *  @param facetItems An array containing B2WFacet objects. Optional.
 *  @param block      The completion handler block that processes the results.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation *)requestFacetsForDepartmentWithIdentifier:(NSString *)identifier
                                                  selectedFacetItems:(NSArray*)facetItems
                                                               block:(B2WAPICompletionBlock)block;

+ (AFHTTPRequestOperation*)requestProductsWithGroup:(NSString*)group
                                                tag:(NSString*)tag
                                              order:(B2WAPICatalogOrderType)orderType
                                               sort:(NSString*)sortType
                                               page:(NSUInteger)page
                                     resultsPerPage:(NSUInteger)resultsPerPage
                                              block:(B2WAPICompletionBlock)block;

/**
 *  Requests a marketplace partner with the given name.
 *
 *  @param partnerName The name of a marketplace partner. Required.
 *  @param block      The completion handler block that processes the results.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation *)requestMarketplacePartnerByName:(NSString *)partnerName
                                                      block:(B2WAPICompletionBlock)block;

/**
 *  Requests a marketplace partner's products with the given name.
 *
 *  @param partnerName      The name of a marketplace partner. Required.
 *  @param orderType        The order type indicating how products should be ordered. Defaults to descending if an invalid value is provided.
 *  @param sortType         The sort string indicating how products should be sorted. Defaults to best-seller sorting if an invalid value is provided.
 *  @param page             An unsigned integer containing the desired page. Starts at zero.
 *  @param resultsPerPage   An unsigned integer containing the number of desired results per page. Must be greater than zero.
 *  @param block            The completion handler block that processes results, containing a B2WSearchResult object.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation *)requestProductsFromMarketplacePartnerWithName:(NSString *)partnerName
                                                                    order:(B2WAPICatalogOrderType)orderType
                                                                     sort:(NSString*)sortType
                                                                     page:(NSUInteger)page
                                                           resultsPerPage:(NSUInteger)resultsPerPage
                                                                    block:(B2WAPICompletionBlock)block;

/**
 *  Request a marketplace partner's products with the given name, filtering by the given query.
 *
 *  @param partnerName      The name of a marketplace partner. Required.
 *  @param searchQuery      A search query to filter the partner's products.
 *  @param orderType        The order type indicating how products should be ordered. Defaults to descending if an invalid value is provided.
 *  @param sortType         The sort string indicating how products should be sorted. Defaults to best-seller sorting if an invalid value is provided.
 *  @param page             An unsigned integer containing the desired page. Starts at zero.
 *  @param resultsPerPage   An unsigned integer containing the number of desired results per page. Must be greater than zero.
 *  @param block            The completion handler block that processes results, containing a B2WSearchResult object.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation *)requestProductsFromMarketplacePartnerWithName:(NSString *)partnerName
                                                              searchQuery:(NSString *)searchQuery
                                                                    order:(B2WAPICatalogOrderType)orderType
                                                                     sort:(NSString*)sortType
                                                                     page:(NSUInteger)page
                                                           resultsPerPage:(NSUInteger)resultsPerPage
                                                                    block:(B2WAPICompletionBlock)block;

/**
 *  Requests a breadcrumbs for a product object.
 *
 *  @param identifier A string containing the product's catalog identifier. This parameter must not be nil.
 *  @param block      The completion handler block that processes the result.
 *
 *  @return The operation object responsible for the request.
 */
+ (AFHTTPRequestOperation*)requestProductBreadcrumbsWithIdentifier:(NSString*)identifier
                                                             block:(B2WAPICompletionBlock)block;

@end
