//
//  B2WAPIReviews.m
//  B2WKit
//
//  Created by Thiago Peres on 09/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WAPIReviews.h"
#import "B2WBVDelegateWrapper.h"
#import <objc/runtime.h>
#import "B2WReviewResults.h"

/**
 *  DSC - Descending order
 *  ASC - Ascending order
 */
NSString *const B2WAPIReviewsSortTypeMostUseful = @"HelpfulnessDSC";
NSString *const B2WAPIReviewsSortTypeMostComments = @"TotalCommentCountDSC";
NSString *const B2WAPIReviewsSortTypeNewest = @"SubmissionTimeDSC";
NSString *const B2WAPIReviewsSortTypeOldest = @"SubmissionTimeASC";
NSString *const B2WAPIReviewsSortTypeMostPositive = @"RatingDSC";
NSString *const B2WAPIReviewsSortTypeMostNegative = @"RatingASC";

@interface BVGet (block_support)

- (void)sendRequestWithCompletionBlock:(B2WAPICompletionBlock)block;

@end

@implementation BVGet (block_support)

static void * kDelegateKey = "kB2WDelegateKey";

- (void)sendRequestWithCompletionBlock:(B2WAPICompletionBlock)block
{
    B2WBVDelegateWrapper *wrapper = [B2WBVDelegateWrapper wrapperWithCompletionBlock:block];
    objc_setAssociatedObject(self, kDelegateKey, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self sendRequestWithDelegate:wrapper];
}

@end

@implementation B2WAPIReviews

BOOL _isAscendingOrderForReviewSortType(NSString* sortType)
{
    NSString *substring = [sortType substringFromIndex:sortType.length-3];
    
    return [[substring uppercaseString] isEqualToString:@"ASC"];
}

BOOL _isValidReviewSortType(NSString* sortType)
{
    NSArray *a = @[B2WAPIReviewsSortTypeMostUseful,
                   B2WAPIReviewsSortTypeMostComments,
                   B2WAPIReviewsSortTypeNewest,
                   B2WAPIReviewsSortTypeOldest,
                   B2WAPIReviewsSortTypeMostPositive,
                   B2WAPIReviewsSortTypeMostNegative];
    
    for (NSString *s in a)
    {
        if ([sortType isEqualToString:s])
        {
            return YES;
        }
    }
    
    return NO;
}

NSString* _reviewSortTypeString(NSString *sortType)
{
    return [sortType substringToIndex:sortType.length-3];
}

+ (void)setAPIKey:(NSString *)key staging:(BOOL)staging
{
    [[BVSettings instance] setPassKey:key];
    [[BVSettings instance] setStaging:staging];
    [[BVSettings instance] setBaseURL:@"api.bazaarvoice.com"];
}

+ (NSString*)APIKey
{
    return [[BVSettings instance] passKey];
}

+ (NSDictionary*)dictionaryByAssigningCommentsToReviews:(NSMutableDictionary*)dictionary
{
    if (![dictionary[@"Includes"] containsObjectForKey:@"Comments"])
    {
        return dictionary;
    }
    
    NSDictionary *comments = dictionary[@"Includes"][@"Comments"];
    
    for (id review in dictionary[@"Results"])
    {
        NSMutableArray *reviewComments = [NSMutableArray array];
        
        NSArray *commentsIds = review[@"CommentIds"];
        for (NSString *commentId in commentsIds)
        {
            [reviewComments addObject:comments[commentId]];
        }
        
        review[@"Comments"] = reviewComments;
    }
    
    return dictionary;
}

+ (void)requestReviewsWithProductIdentifier:(NSString*)identifier
                                sort:(NSString*)sortType
                                page:(NSUInteger)page
                      resultsPerPage:(NSUInteger)resultsPerPage
                               block:(B2WAPICompletionBlock)block
{
    if (identifier == nil || identifier.length == 0 || sortType == nil || sortType.length == 0 || block == nil)
    {
        if (block)
        {
            NSError *error = [NSError errorWithDomain:B2WAPIErrorDomain
                                                 code:B2WAPIInvalidParameterError
                                             userInfo:nil];
            block(nil, error);
        }
        return;
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
    if (!_isValidReviewSortType(sortType))
    {
        sortType = B2WAPIReviewsSortTypeMostUseful;
    }
	
	BVGet *request = [[BVGet alloc] initWithType:BVGetTypeReviews];
    [request setExcludeFamily:YES];
    [request setFilterForAttribute:@"ProductId" equality:BVEqualityEqualTo value:identifier];
    [request addStatsOn:BVIncludeStatsTypeReviews];
    [request setLimit:(int)resultsPerPage];
    [request setOffset:(int)(resultsPerPage * page)];
    [request addInclude:BVIncludeTypeProducts];
    [request addInclude:BVIncludeTypeComments];
    [request addSortForAttribute:_reviewSortTypeString(sortType) ascending:_isAscendingOrderForReviewSortType(sortType)];
    
    if (sortType == B2WAPIReviewsSortTypeMostNegative ||
        sortType == B2WAPIReviewsSortTypeMostPositive)
    {
        [request addSortForAttribute:_reviewSortTypeString(B2WAPIReviewsSortTypeNewest) ascending:NO];
    }
    
    [request sendRequestWithCompletionBlock:^(id object, NSError *error) {
        if (error)
        {
            if (block)
            {
                block(nil, error);
            }
            return;
        }
        
        if ([object isKindOfClass:[NSDictionary class]] && [object containsObjectForKey:@"HasErrors"])
        {
            if ([object[@"HasErrors"] boolValue])
            {
                id errorObj = object[@"Errors"][0];
                
                NSString *description = [NSString stringWithFormat:@"BazaarVoice API Error '%@': %@", errorObj[@"Code"], errorObj[@"Message"]];
                
                NSError *error = [[NSError alloc] initWithDomain:B2WAPIErrorDomain
                                                            code:B2WAPIInvalidResponseError
                                                        userInfo:@{NSLocalizedDescriptionKey: description}];
                
                if (block)
                {
                    block(nil, error);
                }
            }
            else
            {
                NSDictionary *dic = [B2WAPIReviews dictionaryByAssigningCommentsToReviews:[object mutableCopy]];
                
                block([[B2WReviewResults alloc] initWithDictionary:dic], nil);
            }
        }
    }];
}

+ (void)a
{
    BVPost *post = [[BVPost alloc] initWithType:BVPostTypeReview];
    post.productId = @"";
    post.action = BVActionSubmit;
    post.agreedToTermsAndConditions = YES;
    post.userId = @"";
    post.reviewText = @"";
    post.userNickname = @"";
}

@end
