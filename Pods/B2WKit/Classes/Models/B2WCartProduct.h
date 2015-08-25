//
//  B2WCartProduct.h
//  B2WKit
//
//  Created by Eduardo Callado on 3/20/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WObject.h"

#import "B2WProduct.h"

@interface B2WCartProduct : B2WObject

@property (nonatomic, readonly) NSString *productId;
@property (nonatomic, readonly) NSString *lineId;
@property (nonatomic, readonly) NSString *sku;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) NSNumber *quantity;

@property (nonatomic, readonly) NSString *storeId;
@property (nonatomic, readonly) NSString *storeName;
@property (nonatomic, readonly) NSURL *storeImageURL;

@property (nonatomic, readonly) NSNumber *price;
@property (nonatomic, readonly) NSNumber *originalPrice;

@property (nonatomic, readonly) NSNumber *unitSalesPrice;
@property (nonatomic, readonly) NSNumber *salesPrice;

@property (nonatomic, readonly) BOOL isMarketplace;

@property (nonatomic, readonly) BOOL isLarge;

//
// Init used for products retrieved from the API
//
- (instancetype)initWithCartProductDictionary:(NSDictionary*)dictionary;

//
// Init used for new products to add to a cart
//
- (instancetype)initWithProductSKU:(NSString *)sku quantity:(NSInteger)quantity storeID:(NSString *)storeID;

//
// Change the quantity when editing some product in the cart
//
- (void)setQuantity:(NSInteger)quantity;

- (void)setSalesPrice:(NSNumber *)salesPrice;

- (NSDictionary *)dictionaryValue;

@end
