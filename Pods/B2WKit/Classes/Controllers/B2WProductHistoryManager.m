//
//  B2WProductHistoryManager.m
//  B2WKit
//
//  Created by Thiago Peres on 01/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WProductHistoryManager.h"
#import "B2WProduct.h"

#define _kB2WProductHistoryUserDefaultsKey @"kB2WProductHistoryUserDefaultsKey"
#define _kB2WProductHistoryMaximumNumberOfProducts 100

@implementation B2WProductHistoryManager

+ (NSArray*)history
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:_kB2WProductHistoryUserDefaultsKey];
    return obj ? obj : @[];
}

+ (void)addProductIdentifier:(NSString*)productIdentifier
{
    if (productIdentifier == nil || [productIdentifier isEqualToString:@""])
    {
        return;
    }
    
    NSArray *products = [[NSUserDefaults standardUserDefaults] objectForKey:_kB2WProductHistoryUserDefaultsKey];
    
    NSMutableArray *mutable = [NSMutableArray arrayWithArray:products];
    
    //
    // Remove any previous occurences of the product identifier
    // and moves it to the beginning of the list
    //
    [mutable removeObject:productIdentifier];
    [mutable insertObject:productIdentifier atIndex:0];
    
    while (mutable.count > _kB2WProductHistoryMaximumNumberOfProducts)
    {
        [mutable removeObjectAtIndex:mutable.count-1];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mutable
                                              forKey:_kB2WProductHistoryUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
