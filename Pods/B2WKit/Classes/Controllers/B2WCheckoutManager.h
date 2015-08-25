//
//  B2WCheckoutManager.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class B2WSKUInformation;

@interface B2WCheckoutManager : NSObject

//
// A 'product dictionary' is a NSDictionary with "SKU" and "storeId" keys.
// (eg: NSDictionary *productDict = @{@"SKU": sku, @"storeId": storeId};)
//

+ (void)addProductWithSKU:(NSString *)SKU storeId:(NSString *)storeId;
+ (void)removeProductWithSKU:(NSString *)SKU storeId:(NSString *)storeId;
+ (BOOL)containsProductWithSKU:(NSString *)SKU storeId:(NSString *)storeId;

+ (NSArray *)products;

+ (void)clearProduct;

+ (void)updateCartTabBarBadge;
+ (void)updateCartBadgeInBarButton:(UIBarButtonItem *)barButton;

@end
