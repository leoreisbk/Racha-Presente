//
//  B2WPostalCodeHistoryManager.h
//  B2WKit
//
//  Created by Eduardo Callado on 6/24/15.
//
//

#import <Foundation/Foundation.h>

@interface B2WPostalCodeHistoryManager : NSObject

/**
 *  Returns an array containing postal codes. Objects will be ordered in LIFO (last in, first out) fashion.
 *
 *  @return An array object containing NSString objects in the order in which they were added to the queue.
 */
+ (NSArray *)history;

/**
 *  Adds the specified postal code to the receiver.
 *  After addition, postal code history will be persisted on NSUserDefaults.
 *
 *  @param postal code The postal code to be added.
 */
+ (void)addPostalCode:(NSString *)postalCode;

@end
