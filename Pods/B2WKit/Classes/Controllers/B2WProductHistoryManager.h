//
//  B2WProductHistoryManager.h
//  B2WKit
//
//  Created by Thiago Peres on 01/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class B2WProduct;

@interface B2WProductHistoryManager : NSObject

/**
 *  Returns an array containing product identifiers. Objects will be ordered in LIFO (last in, first out) fashion.
 *
 *  @return An array object containing NSString objects in the order in which they were added to the queue.
 */
+ (NSArray*)history;

/**
 *  Adds the specified product to the receiver. 
 *  After addition, product history will be persisted on NSUserDefaults.
 *
 *  @param product The product object to be added.
 */
+ (void)addProductIdentifier:(NSString*)productIdentifier;

@end
