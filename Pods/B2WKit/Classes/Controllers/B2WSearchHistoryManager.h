//
//  B2WSearchHistoryManager.h
//  B2WKit
//
//  Created by Thiago Peres on 06/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const B2WSearchHistoryManagerDidAddSearchTermNotification;

@interface B2WSearchHistoryManager : NSObject

/**
 Returns an array containing strings that represent past searches.
 Results will be ordered in LIFO (last in, first out) fashion.
 */
+ (NSArray*)history;

/**
 Inserts a given search term at the beginning of the search history.
 
 @param searchTerm The search term to add at the beginning of the search history.
 This value must not be nil or empty.
 */
+ (void)addSearchTerm:(NSString*)searchTerm;

+ (void)addSearchTermArray:(NSArray *)searchTermArray;

@end
