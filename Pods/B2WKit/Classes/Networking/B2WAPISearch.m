//
//  B2WAPISearch.m
//  B2WKit
//
//  Created by Thiago Peres on 11/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WAPISearch.h"
#import "B2WFacetItem.h"
#import "B2WSearchResults.h"
#import "B2WAPIRecommendation.h"
#import "B2WKitUtils.h"
#import "B2WFacet.h"

#import "NSURL+B2WKit.h"
#import <NSAttributedStringMarkdownParser/NSAttributedStringMarkdownParser.h>
#import "B2WCatalogParser.h"

#define _kB2WMaximumNumberOfSearchTerms 10

@implementation B2WAPISearch (internal)

+ (void (^)(AFHTTPRequestOperation *operation, id responseObject))_searchResultSuccessBlockWithBlock:(B2WAPICompletionBlock)block
{
    return ^(AFHTTPRequestOperation *op, id obj){
        if (![obj containsObjectForKey:@"products"])
        {
            if (block)
            {
                block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                               code:B2WAPIInvalidResponseError
                                           userInfo:@{NSLocalizedDescriptionKey: kB2WAPIInvalidResponseErrorLocalizedDescriptionString}]);
            }
            return;
        }
        
        if (block)
        {
            block([[B2WSearchResults alloc] initWithDictionary:obj], nil);
        }
    };
}

+ (AFHTTPRequestOperation*)_GET:(NSString*)path
                     parameters:(NSDictionary*)params
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          error:(B2WAPICompletionBlock)errorBlock
{
    NSString *urlString = [NSURL URLStringWithSubdomain:@"busca" options:0 path:@"%@", path];
    
    NSError *reqError;
    NSURLRequest *request = [[[B2WAPIClient sharedClient] requestSerializer] requestWithMethod:@"GET"
                                                                                     URLString:urlString
                                                                                    parameters:params
                                                                                         error:&reqError];
    if (reqError && errorBlock)
    {
        errorBlock(nil, reqError);
    }
    
    AFHTTPRequestOperation *op = [[B2WAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                                      success:success
                                                                                      failure:[B2WAPIClient errorBlockWithBlock:errorBlock]];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [[[B2WAPIClient sharedClient] operationQueue] addOperation:op];
    return op;
}

@end

@implementation B2WAPISearch

/*+ (AFHTTPRequestOperation*)requestWithQuery:(NSString *)query
                                  facetItem:(B2WFacetItem *)facetItem
                                       page:(NSUInteger)page
                             resultsPerPage:(NSUInteger)resultsPerPage
                                   sortType:(enum B2WAPISearchSortType)sortType
                                      block:(B2WAPICompletionBlock)block
{
    if (query == nil || query.length == 0 || block == nil)
    {
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
                    format:@"Results per page should be greater than zero (Received: %lu.)", (unsigned long)resultsPerPage];
    }
    //
    // For convention purposes, paging on B2WKit start at 0, on the search API requests it starts at 1
    // so we need to adjust accordingly.
    //
    page++;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (facetItem)
    {
        [params addEntriesFromDictionary:facetItem.parameters];
    }
    
    [params addEntriesFromDictionary:@{@"query" : query,
                                       @"results_per_page" : @(resultsPerPage),
                                       @"page" : @(page),
                                       @"sort_type" : @((int)sortType),
                                       @"format" : @"json"}];

    return [B2WAPISearch _GET:@"mobile_search_v2"
                   parameters:params
                      success:[B2WAPISearch _searchResultSuccessBlockWithBlock:block]
                        error:[B2WAPIClient errorBlockWithBlock:block]];
}

+ (AFHTTPRequestOperation*)requestWithQuery:(NSString *)query
									  facet:(B2WFacet *)facet
									   page:(NSUInteger)page
							 resultsPerPage:(NSUInteger)resultsPerPage
								   sortType:(enum B2WAPISearchSortType)sortType
									  block:(B2WAPICompletionBlock)block
{
	if (query == nil || query.length == 0 || block == nil)
	{
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
					format:@"Results per page should be greater than zero (Received: %lu.)", (unsigned long)resultsPerPage];
	}
	//
	// For convention purposes, paging on B2WKit start at 0, on the search API requests it starts at 1
	// so we need to adjust accordingly.
	//
	page++;
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	
	if (facet)
	{
		[params addEntriesFromDictionary:facet.parameters];
	}
	
	[params addEntriesFromDictionary:@{@"query" : query,
									   @"results_per_page" : @(resultsPerPage),
									   @"page" : @(page),
									   @"sort_type" : @((int)sortType),
									   @"format" : @"json"}];
	
	return [B2WAPISearch _GET:@"mobile_search_v2"
				   parameters:params
					  success:[B2WAPISearch _searchResultSuccessBlockWithBlock:block]
						error:[B2WAPIClient errorBlockWithBlock:block]];
}*/

+ (AFHTTPRequestOperation*)requestWithQuery:(NSString *)query
						   facetOrFacetItem:(id)facetOrFacetItem
									   page:(NSUInteger)page
							 resultsPerPage:(NSUInteger)resultsPerPage
								   sortType:(enum B2WAPISearchSortType)sortType
									  block:(B2WAPICompletionBlock)block
{
	if (query == nil || query.length == 0 || block == nil)
	{
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
					format:@"Results per page should be greater than zero (Received: %lu.)", (unsigned long)resultsPerPage];
	}
	//
	// For convention purposes, paging on B2WKit start at 0, on the search API requests it starts at 1
	// so we need to adjust accordingly.
	//
	page++;
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	
	if (facetOrFacetItem)
	{
		if ([facetOrFacetItem isKindOfClass:[B2WFacet class]])
		{
			B2WFacet *facet = (B2WFacet *)facetOrFacetItem;
			[params addEntriesFromDictionary:facet.parameters];
		}
		else if ([facetOrFacetItem isKindOfClass:[B2WFacetItem class]])
		{
			B2WFacetItem *facetItem = (B2WFacetItem *)facetOrFacetItem;
			[params addEntriesFromDictionary:facetItem.parameters];
		}
	}
	
	[params addEntriesFromDictionary:@{@"query" : query,
									   @"results_per_page" : @(resultsPerPage),
									   @"page" : @(page),
									   @"sort_type" : @((int)sortType),
									   @"format" : @"json"}];
    
    if ([B2WAPIClient OPNString] != nil || [B2WAPIClient OPNString].length > 0)
    {
        [params setObject:[B2WAPIClient OPNString] forKey:@"opn"];
    }
	
	return [B2WAPISearch _GET:@"mobile_search_v2"
				   parameters:params
					  success:[B2WAPISearch _searchResultSuccessBlockWithBlock:block]
						error:[B2WAPIClient errorBlockWithBlock:block]];
}

+ (AFHTTPRequestOperation*)requestSuggestionsWithQuery:(NSString*)query
                                                 block:(B2WAPICompletionBlock)block
{
    if (query == nil || query.length == 0 || block == nil)
    {
        return nil;
    }
	
    return [B2WAPISearch _GET:@"autocomplete.php"
                   parameters:@{@"term":query, @"origem":@"mobile"}
                      success:^(AFHTTPRequestOperation *op, NSArray *suggestions){
                          
                          //
                          // Checks if response format is correct
                          //
                          for (NSString *sug in suggestions)
                          {
                              if ( ![sug isKindOfClass:[NSString class]])
                              {
                                  if (block)
                                  {
                                      block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                                                     code:B2WAPIInvalidResponseError
                                                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Response contains unexpected object of class %@, should be %@", [sug class], [NSString class]]}]);
                                  }
                                  return;
                              }
                          }
                          
                          if (block)
                          {
                              block(suggestions, nil);
                          }
                      } error:[B2WAPIClient errorBlockWithBlock:block]];
}

+ (AFHTTPRequestOperation*)requestDesktopSearchHistoryWithBlock:(B2WAPICompletionBlock)block
{
    NSMutableDictionary *recDict = [NSMutableDictionary dictionaryWithDictionary:@{ @"type" : @"historico-usuario",
                                                                                    @"enableMainProduct" : [NSNumber numberWithBool:false],
                                                                                    @"gid" : @"1",
                                                                                    @"vid" : @"5",
                                                                                    @"enableMainProductRefresh" : [NSNumber numberWithBool:false],
                                                                                    @"minResult" : @0,
                                                                                    @"maxResult" : @_kB2WMaximumNumberOfSearchTerms }];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{ @"storeId" : [B2WKitUtils mainAppDisplayName].lowercaseString,
                                                                                   @"recList" : @[recDict] }];
    
    
    [B2WAPIRecommendation addB2WUID:params];
    
    return [B2WAPISearch _requestDesktopSearchHistoryWithParameters:@{ @"j" : [params base64EncodedJSONString],
                                                                    @"json" : @1 }
                                                             completionBlock: block];
}

+ (AFHTTPRequestOperation*)_requestDesktopSearchHistoryWithParameters:(NSDictionary*)params completionBlock:(B2WAPICompletionBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"http://raas-%@.neemu.com/scripts/rec_server.php", [[B2WAPIClient brandCode] lowercaseString]];
    NSError *error;
    NSMutableURLRequest *request = [[[B2WAPIClient sharedClient] requestSerializer] requestWithMethod:@"GET"
                                                                                            URLString:urlString
                                                                                           parameters:params
                                                                                                error:&error];
    
    if (error)
    {
        block(nil, error);
        return nil;
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (![responseObject containsObjectForKey:@"recList"])
        {
            if (block)
            {
                block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                               code:B2WAPIInvalidResponseError
                                           userInfo:nil]);
            }
            return;
        }
        
        NSMutableArray *recommendations = [NSMutableArray arrayWithArray:responseObject[@"recList"]];
        if (recommendations && recommendations.count > 0)
        {
            NSMutableArray *queryList = [[recommendations valueForKeyPath:@"queryList.@distinctUnionOfArrays.query"] mutableCopy];
            if (queryList && queryList.count > 0)
            {
                queryList = [[queryList reverseObjectEnumerator] allObjects];
                while (queryList.count > _kB2WMaximumNumberOfSearchTerms)
                {
                    [queryList removeObjectAtIndex:0];
                }
                block(queryList, nil);
            }
        }
        
    } failure:[B2WAPIClient errorBlockWithBlock:block]];
    
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves];
    NSMutableSet *ct = [serializer.acceptableContentTypes mutableCopy];
    [ct addObject:@"text/html"];
    serializer.acceptableContentTypes = ct;
    [operation setResponseSerializer:serializer];
    [[[B2WAPIClient sharedClient] operationQueue] addOperation:operation];
    
    return operation;
}

@end
