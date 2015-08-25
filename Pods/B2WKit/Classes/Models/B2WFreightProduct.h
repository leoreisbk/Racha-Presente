//
//  B2WFreightProduct.h
//  B2WKit
//
//  Created by Eduardo Callado on 4/2/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WObject.h"

@interface B2WFreightProduct : B2WObject

@property (nonatomic, readonly) NSString *SKU;
@property (nonatomic, readonly) NSNumber *quantity;
@property (nonatomic, readonly) NSString *storeId;
@property (nonatomic, readonly) NSNumber *promotionedPrice;

@property (nonatomic, readonly) BOOL repackaged;
@property (nonatomic, readonly) BOOL pickUpInStore;

- (instancetype)initWithItemSku:(NSString *)SKU
					   quantity:(NSNumber *)quantity
						storeId:(NSString *)storeId
			   promotionedPrice:(NSNumber *)promotionedPrice;

+ (NSArray *)freightProductsWithCartProducts:(NSArray *)cartProducts;

- (NSDictionary *)dictionaryValue;

@end
