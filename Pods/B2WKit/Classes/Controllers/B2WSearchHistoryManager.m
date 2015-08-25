//
//  B2WSearchHistoryManager.m
//  B2WKit
//
//  Created by Thiago Peres on 06/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WSearchHistoryManager.h"

#define _kB2WSearchHistoryUserDefaultsKey @"kB2WSearchHistoryUserDefaultsKey"
#define _kB2WSearchHistoryMaximumNumberOfSearchTerms 20

NSString *const B2WSearchHistoryManagerDidAddSearchTermNotification = @"B2WSearchHistoryManagerDidAddSearchTermNotification";

@implementation B2WSearchHistoryManager

+ (NSArray*)history
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:_kB2WSearchHistoryUserDefaultsKey];
    return obj ? obj : @[];
}

+ (void)addSearchTerm:(NSString *)searchTerm
{
    if (searchTerm == nil || [searchTerm isEqualToString:@""])
    {
        return;
    }
    
    NSArray *searchTerms = [[NSUserDefaults standardUserDefaults] objectForKey:_kB2WSearchHistoryUserDefaultsKey];
    
    NSMutableArray *mutable = [NSMutableArray arrayWithArray:searchTerms];
    
    //
    // Remove any previous occurences of the product identifier
    // and moves it to the beginning of the list
    //
    [mutable removeObject:searchTerm];
    [mutable insertObject:searchTerm atIndex:0];
    
    while (mutable.count > _kB2WSearchHistoryMaximumNumberOfSearchTerms)
    {
        [mutable removeObjectAtIndex:mutable.count-1];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mutable forKey:_kB2WSearchHistoryUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:B2WSearchHistoryManagerDidAddSearchTermNotification object:searchTerm];
}

+ (void)addSearchTermArray:(NSArray *)searchTermArray
{
    if (searchTermArray == nil || [searchTermArray count] == 0)
    {
        return;
    }
    
    NSMutableArray *desktopSearchTerms = [[searchTermArray reverseObjectEnumerator] allObjects];
    NSMutableArray *appSearchTerms = [[NSUserDefaults standardUserDefaults] objectForKey:_kB2WSearchHistoryUserDefaultsKey];
    while (appSearchTerms.count > desktopSearchTerms.count)
    {
        [appSearchTerms removeObjectAtIndex:appSearchTerms.count-1];
    }
    
    NSMutableArray *appAndSiteSearchHistory = [NSMutableArray arrayWithArray:appSearchTerms];
    for (NSString *currentSearchTerm in desktopSearchTerms) {
        [appAndSiteSearchHistory removeObject:currentSearchTerm];
        [appAndSiteSearchHistory insertObject:currentSearchTerm atIndex:appAndSiteSearchHistory.count];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:appAndSiteSearchHistory forKey:_kB2WSearchHistoryUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
