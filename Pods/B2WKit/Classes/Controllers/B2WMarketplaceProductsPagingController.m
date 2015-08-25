//
//  B2WMarketplaceProductsPagingController.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WMarketplaceProductsPagingController.h"

@interface B2WMarketplaceProductsPagingController ()

@property (nonatomic, strong) NSString               *partnerName;
@property (nonatomic, assign) NSUInteger             initialResultsPerPage;
@property (nonatomic, strong) NSString               *initialSortType;
@property (nonatomic, assign) NSUInteger             currentPage;
@property (nonatomic, strong) AFHTTPRequestOperation *currentRequestOperation;

@property (nonatomic, strong) NSArray *lastRequestResults;

@end


@implementation B2WMarketplaceProductsPagingController

- (id)initWithPartnerName:(NSString *)partnerName
                    query:(NSString *)query
           resultsPerPage:(NSUInteger)resultsPerPage
                 sortType:(NSString *)sortType
{
    self = [super init];
    if (self)
    {
        self.partnerName           = partnerName;
        self.query                 = query;
        self.initialResultsPerPage = resultsPerPage;
        self.initialSortType       = sortType;
    }
    return self;
}

#pragma mark - Properties

- (void)setSortType:(NSString *)sortType
{
    _sortType = sortType;
}

- (void)setOrderType:(B2WAPICatalogOrderType)orderType
{
    _orderType = orderType;
}

#pragma mark - Paging

- (BOOL)hasMoreResults
{
    if (self.lastRequestResults.count < self.initialResultsPerPage)
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
    _sortType = self.initialSortType;
    [self requestFirstPage];
}

#pragma mark - Private Methods

- (B2WAPICompletionBlock)_completionBlock
{
    return ^(NSArray *results, NSError *error) {
        self.lastRequestResults = results;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didLoadResults:error:page:)])
        {
            [self.delegate didLoadResults:results error:error page:self.currentPage];
        }
    };
}

- (void)_requestSearchResultsWithPage:(NSUInteger)page
{
    self.currentPage = page;
    
    self.currentRequestOperation = [B2WAPICatalog requestProductsFromMarketplacePartnerWithName:self.partnerName
                                                                                    searchQuery:self.query
                                                                                          order:self.orderType
                                                                                           sort:self.sortType
                                                                                           page:self.currentPage
                                                                                 resultsPerPage:self.initialResultsPerPage
                                                                                          block:[self _completionBlock]];
}

@end
