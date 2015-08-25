//
//  B2WPagingProtocol.h
//  B2WKit
//
//  Created by Thiago Peres on 22/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;

@protocol B2WPagingResultsDelegate <NSObject>

/**
 *  Tells the delegate that new results were loaded.
 *
 *  @param results The results object.
 *  @param error   If an error occurred, this parameter contains an error object with information about the type of failure.
 *  @param page    An integer indicating the current page.
 */
- (void)didLoadResults:(id)results error:(NSError*)error page:(NSUInteger)page;

@end

@protocol B2WPagingProtocol

@required

/**
 *  Set's the receiver's delegate.
 */
- (void)setDelegate:(id<B2WPagingResultsDelegate>)delegate;

/**
 *  Resets pagins to its original values.
 */
- (void)resetPaging;

/**
 *  Requests the first page of the current parameter selection.
 */
- (void)requestFirstPage;

/**
 *  Requests the next page of the current parameter selection.
 */
- (void)requestNextPage;

/**
 *  Returns a boolean value indicating wheter the receiver has more search results to be requested.
 *
 *  @return YES if there are more search results to be requested; otherwise, NO.
 */
- (BOOL)hasMoreResults;

@optional

/**
 *  Returns the current operation object responsible for the request.
 *
 *  @return The current operation object responsible for the request.
 */
- (AFHTTPRequestOperation*)currentRequestOperation;

@end
