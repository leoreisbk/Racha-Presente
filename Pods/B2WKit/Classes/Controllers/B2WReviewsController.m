//
//  B2WReviewsController.m
//  B2WKit
//
//  Created by Thiago Peres on 09/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WReviewsController.h"
#import "B2WAPIReviews.h"
#import "B2WReviewResults.h"

@interface B2WReviewsController ()

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSString *productIdentifier;
@property (nonatomic, assign) NSUInteger resultsPerPage;

@end

@implementation B2WReviewsController

- (id)initWithProductIdentifier:(NSString*)identifier
                           sort:(NSString*)sortType
                 resultsPerPage:(NSUInteger)resultsPerPage
{
    self = [super init];
    if (self)
    {
        _sortType = sortType;
        self.productIdentifier = identifier;
        self.resultsPerPage = resultsPerPage;
    }
    return self;
}

- (void)setSortType:(NSString *)sortType
{
    _sortType = sortType;
    [self requestFirstPage];
}

- (void)_requestResultsWithPage:(NSUInteger)page
{
    self.currentPage = page;
    
    [B2WAPIReviews requestReviewsWithProductIdentifier:self.productIdentifier
                                           sort:self.sortType
                                           page:self.currentPage resultsPerPage:self.resultsPerPage block:^(B2WReviewResults *object, NSError *error) {
                                               if (object != nil)
                                               {
                                                   if (object.reviews.count != 0)
                                                   {
                                                       _lastResults = [object.reviews copy];
                                                   }
                                                   if ([object.reviewStatistics isKindOfClass:[NSDictionary class]]
                                                       && object.reviewStatistics.count != 0)
                                                   {
                                                       _reviewStatistics = [object.reviewStatistics copy];
                                                   }
                                               }
                                               
                                               if (self.delegate)
                                               {
                                                   [self.delegate didLoadResults:object error:error page:page];
                                               }
                                           }];
}

- (void)resetPaging
{
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

- (BOOL)hasMoreResults
{
    if (self.lastResults.count < self.resultsPerPage)
    {
        return NO;
    }
    return YES;
}

@end
