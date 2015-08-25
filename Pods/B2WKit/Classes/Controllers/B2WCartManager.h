//
//  B2WCartManager.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class B2WSKUInformation;

@interface B2WCartManager : NSObject

+ (NSArray *)skusAndStoreIds;

+ (NSString *)skuAndStoreIdWithSku:(NSString *)sku andStoreId:(NSString *)storeId;

+ (NSString *)addParamsInURLString:(NSString *)urlString;

+ (void)addSku:(NSString *)sku andStoreId:(NSString *)storeId;

+ (BOOL)canAddSkuAndStoreId:(NSString *)skuAndStoreId;

+ (BOOL)isAlreadyAddedSku:(NSString *)sku andStoreId:(NSString *)storeId;

+ (void)clearSkusAndStoreIds;

+ (void)changeCartBadgeInWindow:(UIWindow *)window;

+ (void)changeCartBadgeInBarButton:(UIBarButtonItem *)barButton;

@end
