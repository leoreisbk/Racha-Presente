//
//  B2WWishList.h
//  B2WKit
//
//  Created by Thiago Peres on 01/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

#import "B2WAPIClient.h"

@class B2WWishListItem;
@class B2WProduct;


@interface B2WWishList : MTLModel

/// The wishlist's name.
@property (nonatomic, strong) NSString *name;

/// An array of B2WWishlistItem objects.
@property (nonatomic, readonly) NSArray *items;

/// An array containing the catalog identifiers of each item in the wishlist.
@property (nonatomic, readonly) NSArray *itemIdentifiers;


/// The date when the wishlist was created.
@property (nonatomic, readonly) NSDate *creationDate;

/// The date when the wishlist was last modified.
@property (nonatomic, readonly) NSDate *lastModifiedDate;

/// An array containing the catalog identifiers of each item in the wishlist that had it's price lowered.
@property (nonatomic, strong) NSMutableArray *betterPriceItemsIdentifiers;

/// An array containing the catalog identifiers of each item in the wishlist that it's available again.
@property (nonatomic, strong) NSMutableArray *availableItemsIdentifiers;

#pragma mark - Methods

/**
 *  Initializes a wishlist with the given name.
 *
 *  @param name The name of the new wishlist.
 *
 *  @return A B2WWishlist object.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Returns an wishlist item with a product that matches the given `productIdentifier`.
 *
 *  Returns nil if there's no product with the given identifier.
 *
 *  @param productIdentifier A product's catalog identifier.
 *
 *  @return A B2WWishlistItem or nil.
 */
- (B2WWishListItem *)itemWithIdentifier:(NSString *)productIdentifier;

/**
 *  Removes from the wishlist the product with the given identifier.
 *
 *  @param identifier A product's catalog identifier.
 */
- (void)removeProductIdentifier:(NSString *)identifier;

/**
 *  Adds to the wishlist the given product.
 *
 *  @param identifier A B2WProduct object.
 *
 *  @return Wether or not the product was added to the wishlist.
 */
- (BOOL)addProduct:(B2WProduct *)product;

/**
 *  Updates all products in the wishlist if it has changed or if 30 minutes had passed.
 *
 *  @param block The completion handler block that processes results, containing a B2WSearchResult object.
 *
 *  @return An array of AFNetworkOperation.
 */
- (NSArray *)requestProducts:(B2WAPICompletionBlock)block;

/**
 *  Updates all products in the wishlist if it has changed or if 30 minutes had passed.
 *
 *  @param block The completion handler block that processes results, containing a B2WSearchResult object.
 *  @param forceRequest Wether or not should force the URL request despite the cache policy.
 *
 *  @return An array of AFNetworkOperation.
 */
- (NSArray *)requestProducts:(B2WAPICompletionBlock)block shouldForceRequest:(BOOL)forceRequest;

#pragma mark - Deprecated Methods

/**
 *  Adds to the wishlist a product with the given identifier.
 *
 *  @param identifier A product's catalog identifier.
 */
- (BOOL)addProductIdentifier:(NSString *)identifier B2W_DEPRECATED("use addProduct: instead");

@end
