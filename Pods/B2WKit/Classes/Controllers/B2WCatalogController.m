//
//  B2WCatalogController.m
//  B2WKit
//
//  Created by Thiago Peres on 23/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WCatalogController.h"

// Models
#import "B2WDepartment.h"

@interface B2WCatalogController ()

@property (nonatomic, assign) enum B2WAPICatalogOrderType initialOrderType;
@property (nonatomic, strong) NSString * initialSortType;
@property (nonatomic, assign) NSUInteger initialResultsPerPage;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) AFHTTPRequestOperation *currentRequestOperation;
@property (nonatomic, strong) NSArray *currentRequestOperations;

// DEPRECATED
@property (nonatomic, strong) NSString *initialGroupOrTag B2W_DEPRECATED("use -departmentIdentifier instead");

@end


@implementation B2WCatalogController

- (id)initWithDepartment:(B2WDepartment *)department
				   order:(B2WAPICatalogOrderType)orderType
					sort:(NSString *)sortType
		  resultsPerPage:(NSUInteger)resultsPerPage
{
    self = [super init];
    if (self)
    {
        self.initialSortType = sortType;
        self.initialResultsPerPage = resultsPerPage;
        self.initialOrderType = orderType;
        self.orderType = orderType;
        self.sortType = sortType;
        self.department = department;
    }
    return self;
}

- (id)initWithGroups:(NSArray *)groups
			   order:(B2WAPICatalogOrderType)orderType
				sort:(NSString *)sortType
	  resultsPerPage:(NSUInteger)resultsPerPage
{
	self = [super init];
	if (self)
	{
		self.initialSortType = sortType;
		self.initialResultsPerPage = resultsPerPage;
		self.initialOrderType = orderType;
		self.orderType = orderType;
		self.sortType = sortType;
		self.groups = groups;
	}
	return self;
}

- (id)initWithTags:(NSArray *)tags
			 order:(B2WAPICatalogOrderType)orderType
			  sort:(NSString *)sortType
	resultsPerPage:(NSUInteger)resultsPerPage
{
	self = [super init];
	if (self)
	{
		self.initialSortType = sortType;
		self.initialResultsPerPage = resultsPerPage;
		self.initialOrderType = orderType;
		self.orderType = orderType;
		self.sortType = sortType;
		self.tags = tags;
	}
    return self;
}

- (id)initWithProductIdentifiers:(NSArray*)productIdentifiers
{
	self = [super init];
	if (self)
	{
//		self.initialSortType = sortType;
//		self.initialResultsPerPage = resultsPerPage;
//		self.initialOrderType = orderType;
//		self.orderType = orderType;
//		self.sortType = sortType;
        self.productIdentifiers = productIdentifiers;
        self.initialResultsPerPage = productIdentifiers.count + 1;
	}
    return self;
}

#pragma mark - Properties

- (BOOL)hasMoreResults
{
    if (self.lastResults.count < self.initialResultsPerPage)
    {
        return NO;
    }
    return YES;
}

- (void)setSortType:(NSString *)sortType
{
    _sortType = sortType;
}

- (void)setOrderType:(enum B2WAPICatalogOrderType)orderType
{
    _orderType = orderType;
}

#pragma mark - Public Methods

- (void)resetPaging
{
    _orderType = self.initialOrderType;
    _sortType = self.initialSortType;
    [self requestFirstPage];
}

- (void)requestFirstPage
{
    [self _requestResultsWithPage:0];
}

- (void)requestNextPage
{
    [self _requestResultsWithPage:++self.currentPage];
}

#pragma mark - Private Methods

- (B2WAPICompletionBlock)_catalogResultsCompletionBlock
{
    return ^(NSArray *results, NSError *error) {
        _lastResults = results;
        
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(didLoadResults:error:page:)])
        {
            [self.delegate didLoadResults:results error:error page:self.currentPage];
        }
    };
}

- (void)_requestResultsWithPage:(NSUInteger)page
{
    self.currentPage = page;
    
    if (page == 0)
    {
        if (self.currentRequestOperation.isExecuting)
        {
            self.currentRequestOperation = nil;
        }
    }
    
    if (self.department)
    {
        self.currentRequestOperation = [B2WAPICatalog requestProductsWithDepartmentIdentifier:self.department.identifier
                                                                           selectedFacetItems:self.selectedFacetItems
                                                                                        order:self.orderType
                                                                                         sort:self.sortType
                                                                                         page:self.currentPage
                                                                               resultsPerPage:self.initialResultsPerPage
                                                                                        block:[self _catalogResultsCompletionBlock]];
    }
	else if (self.groups)
	{
		self.currentRequestOperation = [B2WAPICatalog requestProductsWithGroup:[self.groups componentsJoinedByString:@" "]
																		   tag:nil
																		 order:self.orderType
																		  sort:self.sortType
																		  page:self.currentPage
																resultsPerPage:self.initialResultsPerPage
																		 block:[self _catalogResultsCompletionBlock]];
	}
    else if (self.tags)
    {
        self.currentRequestOperation = [B2WAPICatalog requestProductsWithGroup:nil
                                                                           tag:[self.tags componentsJoinedByString:@" "]
                                                                         order:self.orderType
                                                                          sort:self.sortType
                                                                          page:self.currentPage
                                                                resultsPerPage:self.initialResultsPerPage
                                                                         block:[self _catalogResultsCompletionBlock]];
    }
    else if (self.productIdentifiers)
    {
        self.currentRequestOperation = nil;
        self.currentRequestOperations = [B2WAPICatalog requestProductsWithIdentifiers:self.productIdentifiers block:[self _catalogResultsCompletionBlock]];
    }
}

@end
