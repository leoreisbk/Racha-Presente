//
//  B2WSearchController.m
//  B2WKit
//
//  Created by Thiago Peres on 22/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WSearchController.h"

// Networking
#import "B2WAPIClient.h"

// Models
#import "B2WSearchResults.h"

@interface B2WSearchController ()

@property (nonatomic, strong) NSString               *initialQuery;
@property (nonatomic, assign) NSUInteger             initialResultsPerPage;
@property (nonatomic, assign) B2WAPISearchSortType   initialSortType;
@property (nonatomic, assign) NSUInteger             currentPage;
@property (nonatomic, strong) AFHTTPRequestOperation *currentRequestOperation;

@end


@implementation B2WSearchController

- (id)initWithQuery:(NSString *)query
     resultsPerPage:(NSUInteger)resultsPerPage
           sortType:(enum B2WAPISearchSortType)sortType
{
    self = [super init];
    if (self)
    {
        self.initialQuery          = query;
        self.initialResultsPerPage = resultsPerPage;
        self.initialSortType       = sortType;
    }
    return self;
}

#pragma mark - Properties

- (NSString *)query
{
    return self.initialQuery;
}

- (void)setSortType:(enum B2WAPISearchSortType)sortType
{
    _sortType = sortType;
    [self requestFirstPage];
}

- (void)setFacetItem:(B2WFacetItem *)facetItem
{
    _facetItem = facetItem;
    [self requestFirstPage];
}

#pragma mark - Paging

- (BOOL)hasMoreResults
{
    if (self.lastSearchResults.products.count < self.initialResultsPerPage)
    {
        return NO;
    }
    
    return YES;
}

- (void)requestFirstPage
{
    [self _requestSearchResultsWithPage:0];
}

- (void)requestNextPage
{
    [self _requestSearchResultsWithPage:++self.currentPage];
}

- (void)resetPaging
{
    _facetItem = nil;
    _sortType = self.initialSortType;
    [self requestFirstPage];
}

#pragma mark - Private Methods

- (B2WAPICompletionBlock)_searchResultsCompletionBlock
{
    return ^(B2WSearchResults *results, NSError *error) {
        _lastSearchResults = results;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didLoadResults:error:page:)])
        {
            [self.delegate didLoadResults:results error:error page:self.currentPage];
        }
    };
}

- (void)_requestSearchResultsWithPage:(NSUInteger)page
{
    self.currentPage = page;
	
    self.currentRequestOperation = [B2WAPISearch requestWithQuery:self.query
                                                        facetOrFacetItem:self.facetItem
                                                             page:page
                                                   resultsPerPage:self.initialResultsPerPage
                                                         sortType:self.sortType
                                                            block:[self _searchResultsCompletionBlock]];
}

@end
