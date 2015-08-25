//
//  B2WCatalogParser.m
//  B2WKit
//
//  Created by Flávio Caetano on 5/6/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WCatalogParser.h"

// Networking
#import "B2WAPIClient.h"

// Models
#import "B2WProduct.h"
#import "B2WProductList.h"
#import "B2WDepartmentGroup.h"
#import "B2WFacet.h"
#import "B2WFacetItem.h"
#import "B2WMarketplacePartner.h"
#import "B2WBreadcrumb.h"

// Categories
#import "NSObject+B2WKit.h"
#import "AFHTTPRequestOperation+B2WKit.h"
#import "NSArray+B2WKit.h"

static Class _parserClass;


@interface B2WCatalogParser ()

@end


@implementation B2WCatalogParser

#pragma mark Class Methods

+ (instancetype)sharedParser
{
    static B2WCatalogParser *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_parserClass)
        {
            _sharedInstance = [_parserClass new];
        }
        else
        {
            _sharedInstance = [B2WCatalogParser new];
        }
    });
    
    return _sharedInstance;
}

+ (void)registerParserClass:(Class)class
{
    assert([class isSubclassOfClass:[self class]]);
    _parserClass = class;
}

#pragma mark Instance Methods

- (B2WProduct *)parse__requestProductWithIdentifier__object:(id)object error:(NSError **)error
{
    return [object firstObject];
}

- (NSArray *)parse__requestProductsWithIdentifiers__operationsArray:(NSArray *)operations identifiers:(NSArray *)identifiers error:(NSError **)error
{
    NSArray *products = [self _parsedProductsForOperations:operations];
    
    //
    // Check if any of the requests contain errors
    //
    NSArray *errors = [operations valueForKeyPath:@"mutableUserInfo.errorKey"];
    for (id err in errors)
    {
        if (err == [NSNull null])
        {
            continue;
        }
        
        if (*error != NULL)
        {
            *error = err;
        }

        return nil;
    }
    
    return [products sortedArrayUsingComparator:^NSComparisonResult(B2WProduct *prd1, B2WProduct *prd2) {
        NSUInteger ind1 = [identifiers indexOfObject:prd1.identifier];
        NSUInteger ind2 = [identifiers indexOfObject:prd2.identifier];
        
        if (ind1 == ind2)
        {
            return NSOrderedSame;
        }
        
        return (ind1 < ind2 ? NSOrderedAscending : NSOrderedDescending);
    }];
}

- (B2WProduct *)parse__requestProductWithEANString__object:(id)object error:(NSError **)error
{
    if (![object containsObjectForKey:@"product"])
    {
        *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                     code:B2WAPIResourceNotFoundError
                                 userInfo:@{NSLocalizedDescriptionKey: @"Could not find a product with the given EAN"}];
        return nil;
    }
    
    return [[B2WProduct alloc] initWithDictionary:object[@"product"]];
}

- (NSArray *)parse__requestProductsWithDepartmentGroupOrTag__object:(id)object error:(NSError **)error
{
    if (![object isValidResponseObject] ||
        ![object containsObjectForKey:@"product"])
    {
        *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                     code:B2WAPIInvalidResponseError
                                 userInfo:@{NSLocalizedDescriptionKey: @"The server returned an empty or invalid response."}];
        return nil;
    }
    
    return [B2WProduct objectsWithDictionaryArray:[object arrayForKey:@"product"]];
}

- (NSArray *)parse__requestProductsWithDepartmentIdentifier_facetItems__object:(id)object error:(NSError *__autoreleasing *)error
{
    if (![object isValidResponseObject] ||
        ![object containsObjectForKey:@"product"])
    {
        *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                     code:B2WAPIInvalidResponseError
                                 userInfo:@{NSLocalizedDescriptionKey: @"The server returned an empty or invalid response."}];
        return nil;
    }
    
    return [B2WProduct objectsWithDictionaryArray:[object arrayForKey:@"product"]];
}

- (NSArray *)parse__requestFeaturedProductsWithDepartmentIdentifier__object:(id)object error:(NSError *__autoreleasing *)error
{
    if (![object isValidResponseObject] ||
        ![object containsObjectForKey:@"product"])
    {
        *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                     code:B2WAPIInvalidResponseError userInfo:@{NSLocalizedDescriptionKey: @"The server returned an empty or invalid response."}];
        return nil;
    }
    
    return [B2WProduct objectsWithDictionaryArray:object[@"product"]];
}


- (NSArray *)parse__requestFeaturedProductsLists__object:(id)object error:(NSError **)error
{
    if (![object isValidResponseObject] ||
        ![object containsObjectForKey:@"list"])
    {
        *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                     code:B2WAPIInvalidResponseError
                                 userInfo:@{NSLocalizedDescriptionKey: @"The server returned an empty or invalid response."}];
        return nil;
    }
    
    return [B2WProductList objectsWithDictionaryArray:[object arrayForKey:@"list"]];
}

- (B2WProduct *)parse__requestDailyOfferProductWithBlock__object:(id)object error:(NSError **)error
{
    if (![object isValidResponseObject] ||
        ![object containsObjectForKey:@"product"])
    {
        *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInvalidResponseError
                                       userInfo:@{NSLocalizedDescriptionKey: kB2WAPIInvalidResponseErrorLocalizedDescriptionString}];
        return nil;
    }
	
	return [[B2WProduct alloc] initWithDictionary:[[object arrayForKey:@"product"] firstObject]];
}

- (NSArray *)parse__requestDepartmentsWithIdentifier__object:(id)object error:(NSError **)error
{
    if (![object isValidResponseObject] ||
        ![object containsObjectForKey:@"parent"])
    {
        *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInvalidResponseError
                                 userInfo:@{NSLocalizedDescriptionKey: @"The server returned an empty or invalid response."}];
        return nil;
    }
    
    return [B2WDepartmentGroup objectsWithDictionaryArray:[object arrayForKey:@"parent"]];
}

- (NSArray *)parse__requestFacetsForDepartmentWithIdentifier__object:(id)object error:(NSError **)error
{
    if (![object isValidResponseObject] ||
        ![object containsObjectForKey:@"facetDepto"])
    {
        *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                     code:B2WAPIInvalidResponseError
                                 userInfo:@{NSLocalizedDescriptionKey: @"The server returned an empty or invalid response."}];
    }
    
    return [B2WFacet objectsWithDictionaryArray:[object arrayForKey:@"facetDepto"]];
}

- (B2WMarketplacePartner *)parse__requestMarketplacePartnerByName__object:(id)object error:(NSError *__autoreleasing *)error
{
    if (![object isValidResponseObject] ||
        ![object containsObjectForKey:@"partner"])
    {
        *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                     code:B2WAPIInvalidResponseError
                                 userInfo:@{NSLocalizedDescriptionKey: @"The server returned an empty or invalid response."}];
    }
    
    return [[B2WMarketplacePartner alloc] initWithDictionary:object[@"partner"]];
}

- (NSArray *)parse__requestProductsFromMarketplacePartnerWithName_searchQuery__object:(id)object error:(NSError *__autoreleasing *)error
{
    if (![object isValidResponseObject] ||
        ![object containsObjectForKey:@"product"])
    {
        *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                     code:B2WAPIInvalidResponseError
                                 userInfo:@{NSLocalizedDescriptionKey: @"The server returned an empty or invalid response."}];
    }
    
    return [B2WProduct objectsWithDictionaryArray:[object arrayForKey:@"product"]];
}

#pragma mark - Private Methods

- (NSArray *)_parsedProductsForOperations:(NSArray*)operations
{
    NSMutableArray *products = [NSMutableArray array];
    
    //
    // Parse responses at the end of all requests
    //
    for (AFHTTPRequestOperation *operation in operations)
    {
        if (operation.error)
        {
            operation.mutableUserInfo[_errorKey] = operation.error;
            break;
        }
        
        id responseObject = operation.responseObject;
//        NSInteger desiredProductArrayCount = [operation.mutableUserInfo[_desiredCountKey] integerValue];
        NSArray *parsedProducts;
        //
        // Check for invalid responses
        //
        if (![responseObject isValidResponseObject] ||
            ![responseObject containsObjectForKey:@"product"])
        {
            operation.mutableUserInfo[_errorKey] = [NSError errorWithDomain:B2WAPIErrorDomain
                                                                       code:B2WAPIInvalidResponseError
                                                                   userInfo:@{NSLocalizedDescriptionKey: @"The server returned an empty or invalid response."}];
            break;
        }
        
        //
        // Check if the number of returned products is equal to
        // the number of desired products for this request
        //
//        NSUInteger productArrayCount = [[responseObject arrayForKey:@"product"] count];
//        if (desiredProductArrayCount != productArrayCount)
//        {
//            NSString *description = [NSString stringWithFormat:@"The server return an incorrect number of products (should be %ld, is %lu).", (long)desiredProductArrayCount, (unsigned long)productArrayCount];
//            
//            operation.mutableUserInfo[_errorKey] = [NSError errorWithDomain:B2WAPIErrorDomain
//                                                                       code:B2WAPIInvalidResponseError
//                                                                   userInfo:@{NSLocalizedDescriptionKey: description}];
//            break;
//        }
        
        //
        // Add parsed products to global array
        //
        parsedProducts = [B2WProduct objectsWithDictionaryArray:[responseObject arrayForKey:@"product"]];
        
        [products addObjectsFromArray:parsedProducts];
    }
    
    return products;
}

- (NSArray *)parse__requestBreadcrumbsForProductWithIdentifier__object:(id)object error:(NSError **)error
{
    if (![object isValidResponseObject] ||
        ![object containsObjectForKey:@"breadcrumb"])
    {
        *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                     code:B2WAPIInvalidResponseError
                                 userInfo:@{NSLocalizedDescriptionKey: @"The server returned an empty or invalid response."}];
    }
    
    return [B2WBreadcrumb objectsWithDictionaryArray:[object arrayForKey:@"breadcrumb"]];
}

@end
