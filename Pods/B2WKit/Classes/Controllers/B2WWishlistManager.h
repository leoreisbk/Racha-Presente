//
//  B2WWishlistController.h
//  B2WKit
//
//  Created by Thiago Peres on 01/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@class B2WWishList;
static NSString *const kPriceDifferTreshold = @"B2WKitPriceDifferTreshold";
static NSString *const kB2WWishlistNotificationProduct = @"B2WWishlistNotificationProduct";
static NSString *const kB2WWishlistNotificationBetterPriceIdentifiers = @"B2WWishlistNotificationBetterPriceIdentifiers";
static NSString *const kB2WWishlistNotificationAvailableProductsIdentifiers = @"B2WWishlistNotificationAvailableProductsIdentifiers";


@interface B2WWishlistManager : MTLModel

/**
 *  An array containing all wish list objects.
 */
@property (nonatomic, readonly) NSArray *wishlists;

/**
 *  Returns the shared manager object.
 *
 *  @return The shared manager object.
 */
+ (instancetype)sharedManager;

/**
 *  Creates a new wish list object and adds it to the wish lists array. 
 *  After addition, the updated wish lists array will be persisted on NSUserDefaults.
 *
 *  @param wishListName A string containing the desired wish list name.
 */
- (BOOL)addWishListNamed:(NSString*)wishListName;

/**
 *  Removes the wish list containing the provided name.
 *  After addition, the updated wish lists array will be persisted on NSUserDefaults.
 *
 *  @param wishListName A string containing the wish list name.
 */
- (void)removeWishListNamed:(NSString*)wishListName;

/**
 *  Returns the wish list object with the provided name.
 *
 *  @param wishListName A string containing the wish list name.
 *
 *  @return The wish list object with the provided name.
 */
- (B2WWishList *)wishListNamed:(NSString*)wishListName;

/**
 *  The user's default wishlist.
 *
 *  @return The wish list object.
 */
- (B2WWishList *)defaultWishlist;

/**
 *  Asynchronously save the wishlist in NSUsersDefault.
 */
- (void)save;

/**
 *  Fetches the default wishlist to check for price or stock changes in the background.
 *  Must be called in app's delegate `application:performFetchWithCompletionHandler:`.
 *
 *  @param completionHandler The completion handler block sent to `application:performFetchWithCompletionHandler:`.
 */
- (void)fetchDefaultWishListInBackground:(void (^)(UIBackgroundFetchResult result))completionHandler;

@end