//
//  B2WCatalogParser.h
//  B2WKit
//
//  Created by Flávio Caetano on 5/6/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const _desiredCountKey = @"desiredCountKey";
static NSString *const _errorKey = @"errorKey";

@class B2WProduct;
@class B2WMarketplacePartner;

/**
 *  A parser class to handle B2WAPICatalog. Any subclasses must be registered with `registerParserClass:`.
 */
@interface B2WCatalogParser : NSObject

/**
 *  Returns the shared parser object.
 *
 *  @return The shared parser object.
 */
+ (instancetype)sharedParser;

/**
 *  Registers a subclass for parsing the requests.
 *
 *  @param class A subclass of B2WCatalogParser.
 */
+ (void)registerParserClass:(Class)class;

#pragma mark - Parsing

/**
 *  Parses `[B2WAPICatalog requestProductWithIdentifier:object:]`
 *
 *  @param object The request's resulting response object.
 *  @param error  A pointer to an error which may be thrown.
 *
 *  @return A B2WProduct object.
 */
- (B2WProduct *)parse__requestProductWithIdentifier__object:(id)object error:(NSError **)error;

/**
 *  Parses `[B2WAPICatalog requestProductsWithIdentifiers:object:]`
 *
 *  @param operations  An array of AFHTTPRequestOperations.
 *  @param identifiers The original array of identifiers to be requested.
 *  @param error  A pointer to an error which may be thrown.
 *
 *  @return An array of B2WProducts.
 */
- (NSArray *)parse__requestProductsWithIdentifiers__operationsArray:(NSArray *)operations identifiers:(NSArray *)identifiers error:(NSError **)error;

/**
 *  Parses `[B2WAPICatalog requestProductWithEANString:object:]`
 *
 *  @param object The request's resulting response object.
 *  @param error  A pointer to an error which may be thrown.
 *
 *  @return A B2WProduct object.
 */
- (B2WProduct *)parse__requestProductWithEANString__object:(id)object error:(NSError **)error;

/**
 *  Parses `[B2WAPICatalog requestProductsWithDepartmentGroupOrTag:order:sort:page:resultsPerPage:block:]`
 *
 *  @param object The request's resulting response object.
 *  @param error  A pointer to an error which may be thrown.
 *
 *  @return An array of B2WProducts.
 */
- (NSArray *)parse__requestProductsWithDepartmentGroupOrTag__object:(id)object error:(NSError **)error;

/**
*  Parses `[B2WAPICatalog requestProductsWithDepartmentIdentifier:selectedFacetItems:order:sort:page:resultsPerPage:block:]`
*
*  @param object The request's resulting response object.
*  @param error  A pointer to an error which may be thrown.
*
*  @return An array of B2WProducts.
*/
- (NSArray *)parse__requestProductsWithDepartmentIdentifier_facetItems__object:(id)object error:(NSError **)error;

/**
 *  Parses `[B2WAPICatalog requestFeaturedProductsWithDepartmentIdentifier:block:]`
 *
 *  @param object The request's resulting response object.
 *  @param error  A pointer to an error which may be thrown.
 *
 *  @return An array of B2WProducts.
 */
- (NSArray *)parse__requestFeaturedProductsWithDepartmentIdentifier__object:(id)object error:(NSError **)error;

/**
 *  Parses `[B2WAPICatalog requestFeaturedProductsListsWithBlock:]`
 *
 *  @param object The request's resulting response object.
 *  @param error  A pointer to an error which may be thrown.
 *
 *  @return An array of B2WProducts.
 */
- (NSArray *)parse__requestFeaturedProductsLists__object:(id)object error:(NSError **)error;

/**
 *  Parses `[B2WAPICatalog requestDailyOfferProductWithBlock:]`
 *
 *  @param object The request's resulting response object.
 *  @param error  A pointer to an error which may be thrown.
 *
 *  @return A B2WProduct object.
 */
- (B2WProduct *)parse__requestDailyOfferProductWithBlock__object:(id)object error:(NSError **)error;

/**
 *  Parses `[B2WAPICatalog requestDepartmentsWithIdentifier:block:]`
 *
 *  @param object The request's resulting response object.
 *  @param error  A pointer to an error which may be thrown.
 *
 *  @return An array of B2WProducts.
 */
- (NSArray *)parse__requestDepartmentsWithIdentifier__object:(id)object error:(NSError **)error;

/**
 *  Parses `[B2WAPICatalog requestFacetsForDepartmentWithIdentifier:block:]`
 *
 *  @param object The request's resulting response object.
 *  @param error  A pointer to an error which may be thrown.
 *
 *  @return An array of B2WFacets.
 */
- (NSArray *)parse__requestFacetsForDepartmentWithIdentifier__object:(id)object error:(NSError **)error;

/**
 *  Parses `[B2WAPICatalog requestMarketplacePartnerByName:block:]`
 *
 *  @param object The request's resulting response object.
 *  @param error  A pointer to an error which may be thrown.
 *
 *  @return A B2WMarketplacePartner object.
 */
- (B2WMarketplacePartner *)parse__requestMarketplacePartnerByName__object:(id)object error:(NSError **)error;

/**
 *  Parses `[B2WAPICatalog requestProductsFromMarketplacePartnerWithName:searchQuery:block:]`
 *
 *  @param object The request's resulting response object.
 *  @param error  A pointer to an error which may be thrown.
 *
 *  @return An array of B2WProducts.
 */
- (NSArray *)parse__requestProductsFromMarketplacePartnerWithName_searchQuery__object:(id)object error:(NSError **)error;

/**
 *  Parses `[B2WAPICatalog requestBreadcrumbsForProductWithIdentifier:block:]`
 *
 *  @param object The request's resulting response object.
 *  @param error  A pointer to an error which may be thrown.
 *
 *  @return An array of B2WBreadcrumbs.
 */
- (NSArray *)parse__requestBreadcrumbsForProductWithIdentifier__object:(id)object error:(NSError **)error;

@end
