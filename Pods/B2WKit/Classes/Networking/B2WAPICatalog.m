//
//  B2WAPICatalog.m
//  B2WKit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#define kAPI_IDENTIFIRES_LIMIT	100

#import "B2WAPICatalog.h"

// Models
#import "B2WFacetItem.h"

// Categories
#import "NSURL+B2WKit.h"
#import "AFHTTPRequestOperation+B2WKit.h"
#import "B2WFacet.h"

// Parsers
#import "B2WCatalogParser.h"

NSString *const B2WAPICatalogSortBestSellers = @"rank";
NSString *const B2WAPICatalogSortReleaseDate = @"releaseDate";
NSString *const B2WAPICatalogSortName        = @"itemNameSort";
NSString *const B2WAPICatalogSortPrice       = @"salesPrice";

@interface B2WAPICatalog ()

@property (nonatomic, assign) B2WAPICatalogEnvironment currentEnvironment;

@end

@implementation B2WAPICatalog

+ (B2WAPICatalog *)_manager
{
    static B2WAPICatalog *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[B2WAPICatalog alloc] init];
    });
    
    return _sharedInstance;
}

+ (void)setEnvironment:(B2WAPICatalogEnvironment)environment
{
    if (environment == B2WAPICatalogEnvironmentStaging)
    {
        NSLog(@"B2WAPICatalog WARNING: You set the environment to staging. In order for this to work you'll either need to be in a correctly configured network or map your hosts file correctly.");
    }
    
    [[B2WAPICatalog _manager] setCurrentEnvironment:environment];
}

+ (B2WAPICatalogEnvironment)environment
{
	return [[B2WAPICatalog _manager] currentEnvironment];
}

+ (NSString*)_urlStringForPath:(NSString*)path
{
    if ([[B2WAPICatalog _manager] currentEnvironment] == B2WAPICatalogEnvironmentAWS)
    {
        return [NSURL URLStringWithSubdomain:@"produto" options:0 path:@"%@", path];
    }
    else if ([[B2WAPICatalog _manager] currentEnvironment] == B2WAPICatalogEnvironmentStaging)
    {
        return [NSURL URLStringWithSubdomain:@"staging.www" options:0 path:@"%@", path];
    }
    return path;
}

BOOL _sortTypeIsValid(NSString* sortType)
{
    NSArray *a = @[B2WAPICatalogSortReleaseDate,
                   B2WAPICatalogSortBestSellers,
                   B2WAPICatalogSortName,
                   B2WAPICatalogSortPrice];
    
    for (NSString *s in a)
    {
        if ([sortType isEqualToString:s])
        {
            return YES;
        }
    }
    
    return NO;
}

+ (NSURLRequest*)_requestWithIdentifiers:(NSArray*)identifiers
{
    NSError *error;
    
    NSString *identifiersString = [identifiers componentsJoinedByString:@" "];
    if (identifiers.count == 1)
    {
        identifiersString = [identifiersString stringByAppendingString:@" "];
    }
    
    NSDictionary *params = @{@"productIds": identifiersString};
    
    return [[[B2WAPIClient sharedClient] requestSerializer] requestWithMethod:@"GET"
                                                                    URLString:[B2WAPICatalog _urlStringForPath:@"mobile_products_by_identifiers"]
                                                                   parameters:params
                                                                        error:&error];
}

+ (NSArray*)requestProductsWithIdentifiers:(NSArray*)identifiers block:(B2WAPICompletionBlock)block
{
    if (identifiers == nil || identifiers.count <= 0)
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInvalidParameterError
                                       userInfo:@{NSLocalizedDescriptionKey: @"Identifiers array is either nil or empty."}]);
        }
        return nil;
    }
    NSCharacterSet *set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    for (NSString *identifier in identifiers)
    {
        if (![identifier isKindOfClass:[NSString class]] ||
            [identifier rangeOfCharacterFromSet:set].location != NSNotFound)
        {
            if (block)
            {
                block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                               code:B2WAPIInvalidParameterError
                                           userInfo:@{NSLocalizedDescriptionKey : @"Identifiers array must contain only numeric strings."}]);
            }
            return nil;
        }
    }
    
    NSArray *requestOperations = [B2WAPICatalog _requestOperationsForIdentifiers:identifiers block:block];
    
    //
    // Create a batch of request operations
    //
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:requestOperations progressBlock:nil completionBlock:^(NSArray *operations) {
        NSError *error;
        id result = [[B2WCatalogParser sharedParser] parse__requestProductsWithIdentifiers__operationsArray:operations identifiers:identifiers error:&error];
        
        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
    }];
    
    [[B2WAPIClient sharedClient].operationQueue addOperations:operations waitUntilFinished:NO];
    
    return operations;
}

+ (AFHTTPRequestOperation*)requestProductWithIdentifier:(NSString*)identifier block:(B2WAPICompletionBlock)block
{
    if (identifier == nil || identifier.length == 0)
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInvalidParameterError
                                       userInfo:@{NSLocalizedDescriptionKey: @"Product identifier is either nil or emtpy."}]);
        }
        return nil;
    }
    return [(NSArray*)[B2WAPICatalog requestProductsWithIdentifiers:@[identifier] block:^(id object, NSError *error) {
        id result = [[B2WCatalogParser sharedParser] parse__requestProductWithIdentifier__object:object error:nil];
        
        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
    }] firstObject];
}

+ (NSArray*)_requestOperationsForIdentifiers:(NSArray*)identifiers block:(B2WAPICompletionBlock)block
{
    NSMutableArray *requestOperations = [NSMutableArray array];
    NSMutableArray *mutableIdentifiers = [NSMutableArray arrayWithArray:identifiers];
    
    //
    // Slice identifiers array into several subarrays with at most 10 identifiers
    //
    while (mutableIdentifiers.count > 0)
    {
        NSRange range = NSMakeRange(0, MIN(mutableIdentifiers.count, kAPI_IDENTIFIRES_LIMIT));
        NSArray *identifiersSubarray = [mutableIdentifiers subarrayWithRange:range];
        [mutableIdentifiers removeObjectsInRange:range];
        //
        // Create request operation for identifiers
        //
        NSURLRequest *request = [B2WAPICatalog _requestWithIdentifiers:identifiersSubarray];
        
        AFHTTPRequestOperation *operation = [[B2WAPIClient sharedClient] HTTPRequestOperationWithRequest:request success:nil failure:nil];
        operation.mutableUserInfo[_desiredCountKey] = [NSNumber numberWithInteger:identifiersSubarray.count];
        [requestOperations addObject:operation];
    }
    
    return requestOperations;
}

+ (AFHTTPRequestOperation*)requestProductsWithDepartmentIdentifier:(NSString *)identifier
                                                selectedFacetItems:(NSArray *)facetItems
                                                             order:(B2WAPICatalogOrderType)orderType
                                                              sort:(NSString *)sortType
                                                              page:(NSUInteger)page
                                                    resultsPerPage:(NSUInteger)resultsPerPage
                                                             block:(B2WAPICompletionBlock)block
{
    if (identifier == nil   || identifier.length == 0   ||
        sortType == nil     || sortType.length == 0     ||
        block == nil)
    {
        if (block)
        {
            NSError *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                                 code:B2WAPIInvalidParameterError
                                             userInfo:nil];
            block(nil, error);
        }
        return nil;
    }
    
    if ((int)page < 0)
    {
        [NSException raise:NSRangeException
                    format:@"Invalid page %lu. Desired page should be equal or higher than zero.", (unsigned long)page];
    }
    if ((int)resultsPerPage <= 0)
    {
        [NSException raise:NSRangeException
                    format:@"Results per page should be greater than zero (Received: %lu).", (unsigned long)resultsPerPage];
    }
    if (!_sortTypeIsValid(sortType))
    {
        sortType = B2WAPICatalogSortBestSellers;
    }
    
    NSString *order = (orderType == B2WAPICatalogOrderAscending) ? @"asc" : @"desc";
    
    NSUInteger offset = page*resultsPerPage;
    
    /*NSDictionary *facetDictionary;
    if (facetItems.count > 0)
    {
        facetDictionary = [B2WFacet parameterDictionaryForFacetItems:facetItems filterSeparator:@"-"];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:facetDictionary];*/
	
	NSMutableDictionary *params = [NSMutableDictionary new];
    
    NSString *orderParam = (sortType == B2WAPICatalogSortBestSellers) ? sortType : [NSString stringWithFormat:@"%@%@", sortType, order];
    
	NSMutableDictionary *baseParams = [[NSMutableDictionary alloc] initWithDictionary:@{@"menuId" : identifier,
																						@"order" : orderParam,
																						@"offset" : @(offset),
																						@"limit" : @(resultsPerPage)}];
	
	// TODO: check if need this key/value
	/*if (sortType == B2WAPICatalogSortBestSellers)
	{
		[baseParams setValue:@"asc" forKey:@"sort"];
	}*/
	
	[params addEntriesFromDictionary:baseParams];

    return [[B2WAPIClient sharedClient] GET:[B2WAPICatalog _urlStringForPath:@"mobile_products_by_department_filtered"]
                                 parameters:params
                                    success:^(AFHTTPRequestOperation *op, id obj){
                                        NSError *error;
                                        id result = [[B2WCatalogParser sharedParser] parse__requestProductsWithDepartmentIdentifier_facetItems__object:obj error:&error];
                                        
                                        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
                                    } failure:[B2WAPIClient errorBlockWithBlock:block]];
    return nil;
}

+ (AFHTTPRequestOperation*)requestDailyOfferProductWithBlock:(B2WAPICompletionBlock)block
{
    NSString *brandUrl = [[[B2WAPIClient sharedClient] baseURL] domain];
    NSString *path = [NSString stringWithFormat:@"http://b2w-mobile-api.herokuapp.com/dailyOffer/getOffer?domain=%@", brandUrl];
        
    return [[B2WAPIClient sharedClient] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        id result = [[B2WCatalogParser sharedParser] parse__requestDailyOfferProductWithBlock__object:responseObject error:&error];
        
        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
    } failure:[B2WAPIClient errorBlockWithBlock:block]];
}

+ (AFHTTPRequestOperation*)requestProductWithEANString:(NSString*)string
                                                 block:(B2WAPICompletionBlock)block
{
    if (block == nil)
    {
        return nil;
    }
    if (string == nil || string.length == 0)
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInvalidParameterError
                                       userInfo:@{NSLocalizedDescriptionKey: @"The informed EAN code string is empty or nil."}]);
        }
        return nil;
    }
    
    return [[B2WAPIClient sharedClient] GET:[B2WAPICatalog _urlStringForPath:@"mobile_product_by_ean"]
                                 parameters:@{@"ean": string}
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        NSError *error;
                                        id result = [[B2WCatalogParser sharedParser] parse__requestProductWithEANString__object:responseObject error:&error];
                                        
                                        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
                                    }failure:[B2WAPIClient errorBlockWithBlock:block]];
}

+ (AFHTTPRequestOperation*)requestFeaturedProductsListsWithBlock:(B2WAPICompletionBlock)block
{
    if (block == nil)
    {
        return nil;
    }
    
    return [[B2WAPIClient sharedClient] GET:[B2WAPICatalog _urlStringForPath:@"mobile_product_home_list"]
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        NSError *error;
                                        id result = [[B2WCatalogParser sharedParser] parse__requestFeaturedProductsLists__object:responseObject error:&error];
                                        
                                        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
                                    } failure:[B2WAPIClient errorBlockWithBlock:block]];
}

+ (AFHTTPRequestOperation*)requestFeaturedProductsWithDepartmentIdentifier:(NSString*)identifier block:(B2WAPICompletionBlock)block
{
    if (block == nil || identifier == nil)
    {
        return nil;
    }
    
    return [[B2WAPIClient sharedClient] GET:[B2WAPICatalog _urlStringForPath:@"mobile_product_department_gallery"]
                                 parameters:@{@"menuId": identifier}
                                    success:^(AFHTTPRequestOperation *operation, id obj){
                                        NSError *error;
                                        id result = [[B2WCatalogParser sharedParser] parse__requestFeaturedProductsWithDepartmentIdentifier__object:obj error:&error];
                                        
                                        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
                                    } failure:[B2WAPIClient errorBlockWithBlock:block]];
}

+ (AFHTTPRequestOperation*)requestDepartmentsWithIdentifier:(NSString*)identifier block:(B2WAPICompletionBlock)block
{
    if (block == nil)
    {
        return nil;
    }
    
    if (identifier == nil || identifier.length == 0)
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInvalidParameterError
                                       userInfo:@{NSLocalizedDescriptionKey : @"You must provide a department identifier."}]);
        }
    }
    
    return [[B2WAPIClient sharedClient] GET:[B2WAPICatalog _urlStringForPath:[NSString stringWithFormat:@"mobile_departments/%@", identifier]]
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id obj){
                                        NSError *error;
                                        id result = [[B2WCatalogParser sharedParser] parse__requestDepartmentsWithIdentifier__object:obj error:&error];
                                        
                                        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
                                    }failure:[B2WAPIClient errorBlockWithBlock:block]];
}

+ (AFHTTPRequestOperation *)requestFacetsForDepartmentWithIdentifier:(NSString *)identifier
                                                  selectedFacetItems:(NSArray*)facetItems
                                                               block:(B2WAPICompletionBlock)block
{
//    if (block == nil) return nil;
//    
//    if (identifier == nil || identifier.length == 0)
//    {
//        if (block)
//        {
//            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
//                                           code:B2WAPIInvalidParameterError
//                                       userInfo:@{NSLocalizedDescriptionKey : @"You must provide a department identifier."}]);
//        }
//        
//        return nil;
//    }
//    
//    NSDictionary *params = (facetItems == nil || facetItems.count <= 0) ? nil : [B2WFacet parameterDictionaryForFacetItems:facetItems filterSeparator:@"-"];
//    
//    return [[B2WAPIClient sharedClient] GET:[B2WAPICatalog _urlStringForPath:[NSString stringWithFormat:@"mobile_department_filters/%@", identifier]]
//                                 parameters:params
//                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                        NSError *error;
//                                        id result = [[B2WCatalogParser sharedParser] parse__requestFacetsForDepartmentWithIdentifier__object:responseObject error:&error];
//                                        
//                                        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
//                                    } failure:[B2WAPIClient errorBlockWithBlock:block]];
    return nil;
}

+ (AFHTTPRequestOperation *)requestMarketplacePartnerByName:(NSString *)partnerName block:(B2WAPICompletionBlock)block
{
    if (block == nil) return nil;
    
    if (partnerName == nil || partnerName.length == 0)
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInvalidParameterError
                                       userInfo:@{NSLocalizedDescriptionKey : @"You must provide a partner name."}]);
        }
        
        return nil;
    }
    
    NSData *data = [partnerName dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];    
    return [[B2WAPIClient sharedClient] GET:[B2WAPICatalog _urlStringForPath:@"mobile_seller_by_name"]
                                 parameters:@{@"partnerName": [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]}
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        NSError *error;
                                        id result = [[B2WCatalogParser sharedParser] parse__requestMarketplacePartnerByName__object:responseObject error:&error];
                                        
                                        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
                                    } failure:[B2WAPIClient errorBlockWithBlock:block]];
}

+ (AFHTTPRequestOperation *)requestProductsFromMarketplacePartnerWithName:(NSString *)partnerName
                                                              searchQuery:(NSString *)searchQuery
                                                                    order:(B2WAPICatalogOrderType)orderType
                                                                     sort:(NSString *)sortType
                                                                     page:(NSUInteger)page
                                                           resultsPerPage:(NSUInteger)resultsPerPage
                                                                    block:(B2WAPICompletionBlock)block
{
    if (block == nil) return nil;
    
    if (partnerName == nil || partnerName.length == 0)
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInvalidParameterError
                                       userInfo:@{NSLocalizedDescriptionKey : @"You must provide a partner name."}]);
        }
        
        return nil;
    }
    
    if ((int)page < 0)
    {
        [NSException raise:NSRangeException
                    format:@"Invalid page %lu. Desired page should be equal or higher than zero.", (unsigned long)page];
    }
    if ((int)resultsPerPage <= 0)
    {
        [NSException raise:NSRangeException
                    format:@"Results per page should be greater than zero (Received: %lu).", (unsigned long)resultsPerPage];
    }
    
    if (!_sortTypeIsValid(sortType))
    {
        sortType = B2WAPICatalogSortBestSellers;
    }
    
    NSString *order = (orderType == B2WAPICatalogOrderAscending) ? @"asc" : @"desc";
    
    NSUInteger offset = page*resultsPerPage;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if (searchQuery != nil)
    {
        params[@"q"] = searchQuery;
    }
    
    NSData *data = [partnerName dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSDictionary *baseParams = @{@"partnerName" : [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding],
                                 @"order" : sortType,
                                 @"dir": order,
                                 @"offset" : @(offset),
                                 @"limit" : @(resultsPerPage)};
    
    [params addEntriesFromDictionary:baseParams];
    
    return [[B2WAPIClient sharedClient] GET:[B2WAPICatalog _urlStringForPath:@"mobile_products_by_seller"]
                                 parameters:params
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        NSError *error;
                                        id result = [[B2WCatalogParser sharedParser] parse__requestProductsFromMarketplacePartnerWithName_searchQuery__object:responseObject error:&error];
                                        
                                        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
                                    } failure:[B2WAPIClient errorBlockWithBlock:block]];
}

+ (AFHTTPRequestOperation *)requestProductsFromMarketplacePartnerWithName:(NSString *)partnerName
                                                                    order:(B2WAPICatalogOrderType)orderType
                                                                     sort:(NSString *)sortType
                                                                     page:(NSUInteger)page
                                                           resultsPerPage:(NSUInteger)resultsPerPage
                                                                    block:(B2WAPICompletionBlock)block
{
    return [B2WAPICatalog requestProductsFromMarketplacePartnerWithName:partnerName
                                                            searchQuery:nil
                                                                  order:orderType
                                                                   sort:sortType
                                                                   page:page
                                                         resultsPerPage:resultsPerPage
                                                                  block:block];
}

#pragma mark - Private Methods

+ (void)_callCompletionBlock:(B2WAPICompletionBlock)block withObject:(id)object error:(NSError *)error
{
    if (block)
    {
        if (error)
        {
            block(nil, error);
        }
        else
        {
            block(object, nil);
        }
    }
}

+ (AFHTTPRequestOperation*)requestProductsWithGroup:(NSString*)group
                                                tag:(NSString*)tag
                                              order:(B2WAPICatalogOrderType)orderType
                                               sort:(NSString*)sortType
                                               page:(NSUInteger)page
                                     resultsPerPage:(NSUInteger)resultsPerPage
                                              block:(B2WAPICompletionBlock)block
{
	// TODO: Rever/testar condição
	/*if (((group == nil   || group.length == 0) &&
		(tag == nil || tag.length == 0)) ||
        sortType == nil ||
		sortType.length == 0 ||
        block == nil)
    {
        if (block)
        {
            NSError *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                                 code:B2WAPIInvalidParameterError
                                             userInfo:nil];
            block(nil, error);
        }
        return nil;
    }*/
    
    if ((int)page < 0)
    {
        [NSException raise:NSRangeException
                    format:@"Invalid page %lu. Desired page should be equal or higher than zero.", (unsigned long)page];
    }
    if ((int)resultsPerPage <= 0)
    {
        [NSException raise:NSRangeException
                    format:@"Results per page should be greater than zero (Received: %lu).", (unsigned long)resultsPerPage];
    }
    if (!_sortTypeIsValid(sortType))
    {
        sortType = B2WAPICatalogSortBestSellers;
    }
    
    NSString *order = (orderType == B2WAPICatalogOrderAscending) ? @"asc" : @"desc";
    
    NSUInteger offset = page*resultsPerPage;
	
	NSDictionary *params;
	
	if (group)
	{
		params = @{@"id" : group,
				   //@"tag" : tag,
				   @"dir" : order,
				   @"order" : sortType,
				   @"offset" : @(offset),
				   @"limit" : @(resultsPerPage)};
	}
	else if (tag)
	{
		params = @{//@"id" : group,
				   @"tag" : tag,
				   @"dir" : order,
				   @"order" : sortType,
				   @"offset" : @(offset),
				   @"limit" : @(resultsPerPage)};
	}
    
    return [[B2WAPIClient sharedClient] GET:[B2WAPICatalog _urlStringForPath:@"mobile_products_by_department"]
                                 parameters:params
                                    success:^(AFHTTPRequestOperation *op, id obj){
                                        NSError *error;
                                        id result = [[B2WCatalogParser sharedParser] parse__requestProductsWithDepartmentGroupOrTag__object:obj error:&error];
                                        
                                        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
                                    } failure:[B2WAPIClient errorBlockWithBlock:block]];
}

+ (AFHTTPRequestOperation*)requestProductBreadcrumbsWithIdentifier:(NSString*)identifier block:(B2WAPICompletionBlock)block
{
    if (identifier == nil || identifier.length == 0)
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInvalidParameterError
                                       userInfo:@{NSLocalizedDescriptionKey: @"Product identifier is either nil or emtpy."}]);
        }
        return nil;
    }
    
    NSString *urlString = [B2WAPICatalog _urlStringForPath:@"/especial-produto/mobile_product_breadcrumbs"];
    urlString = [NSString stringWithFormat:@"%@/%@/", urlString, identifier];
    
    return [[B2WAPIClient sharedClient] GET:urlString
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *op, id obj){
                                        NSError *error;
                                        id result = [[B2WCatalogParser sharedParser] parse__requestBreadcrumbsForProductWithIdentifier__object:obj error:&error];
                                        
                                        [B2WAPICatalog _callCompletionBlock:block withObject:result error:error];
                                    } failure:[B2WAPIClient errorBlockWithBlock:block]];
}

@end
