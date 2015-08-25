//
//  B2WWishListItem.h
//  B2WKit
//
//  Created by Thiago Peres on 01/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@class B2WProduct;


@interface B2WWishListItem : MTLModel <NSCoding>

/// The item's product's catalog identifier.
@property (nonatomic, readonly) NSString *productIdentifier;

/// The item's date of creation.
@property (nonatomic, readonly) NSDate *dateAdded;

/// The item's stored price value.
@property (nonatomic, strong) NSNumber *priceStoredValue;

/// The item's stored inStock value.
@property (nonatomic, readwrite) BOOL inStockStoredValue;

#pragma mark - Methods

/**
 *  Initializes the wishlist item with the given product.
 *
 *  @param product A B2WProduct object.
 *
 *  @return A B2WWishlistItem object.
 */
- (instancetype)initWithProduct:(B2WProduct *)product;

#pragma mark - Deprecated Methods

/**
 *  Initializes the wishlist item with the given product's catalog identifier.
 *
 *  @param identifier A product's catalog identifier.
 *
 *  @return A B2WWishlistItem object.
 */
- (id)initWithProductIdentifier:(NSString *)identifier B2W_DEPRECATED("use initWithProduct: instead");

@end
