//
//  B2WCartManager.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WCartManager.h"
#import "B2WAPIClient.h"

#define _kACOMCartManagerUserDefaultsKey @"kACOMCartManagerUserDefaultsKey"
#define _kSUBACartManagerUserDefaultsKey @"kSUBACartManagerUserDefaultsKey"
#define _kSHOPCartManagerUserDefaultsKey @"kSHOPCartManagerUserDefaultsKey"

#define _kB2WCartManagerMaximumNumberOfProducts 100
#define _kB2WCartManagerSkuIdPrefix @"codItemFusion"
#define _kB2WCartManagerStoreIdPrefix @"storeId"
#define _kB2WCartManagerStoreIdIphonePrefix @"loja"

@implementation NSString (Substring)

- (BOOL)containsSubstring:(NSString*)substring
{
	return ([self rangeOfString:substring].location != NSNotFound);
}

@end

@implementation B2WCartManager

+ (NSString *)userDefaultsKeyForBrand
{
	if ([[B2WAPIClient brandCode] isEqualToString:@"ACOM"])
	{
		return _kACOMCartManagerUserDefaultsKey;
	}
	else if ([[B2WAPIClient brandCode] isEqualToString:@"SUBA"])
	{
		return _kSUBACartManagerUserDefaultsKey;
	}
	else if ([[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
	{
		return _kSHOPCartManagerUserDefaultsKey;
	}
	return nil;
}

+ (NSArray *)skusAndStoreIds
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:[B2WCartManager userDefaultsKeyForBrand]];
}

+ (NSString *)skuAndStoreIdWithSku:(NSString *)sku andStoreId:(NSString *)storeId
{
	//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	//    {
	NSString *skuAndStoreId = sku;
	if (storeId && storeId.length > 0)
	{
		skuAndStoreId = [NSString stringWithFormat:@"%@(%@=%@)", skuAndStoreId, _kB2WCartManagerStoreIdIphonePrefix, storeId];
	}
	return skuAndStoreId;
	//    }
	//    else
	//    {
	//        if (storeId == nil || [storeId isEqualToString:@""])
	//        {
	//            storeId = @"undefined";
	//        }
	//        return [NSString stringWithFormat:@"%@=%@&%@=%@", _kB2WCartManagerSkuIdPrefix, sku, _kB2WCartManagerStoreIdPrefix, storeId];
	//    }
}

+ (NSString *)addParamsInURLString:(NSString *)urlString
{
	NSMutableArray *skusAndStoreIds = [B2WCartManager skusAndStoreIds];
	
	if (skusAndStoreIds)
	{
		urlString = [urlString stringByAppendingString:@"?"];
		for (NSString *skuAndStoreId in skusAndStoreIds)
		{
			urlString = [urlString stringByAppendingString:skuAndStoreId];
			if ([skusAndStoreIds indexOfObject:skuAndStoreId] < skusAndStoreIds.count-1)
			{
				urlString = [urlString stringByAppendingString:@"&"];
			}
		}
	}
	return urlString;
}

+ (void)addSku:(NSString *)sku andStoreId:(NSString *)storeId
{
	if ([B2WCartManager isAlreadyAddedSku:sku andStoreId:storeId])
	{
		return;
	}
	
	NSString *skuAndStoreId = [B2WCartManager skuAndStoreIdWithSku:sku andStoreId:storeId];
	
	NSArray *skusAndStoreIds = [[NSUserDefaults standardUserDefaults] objectForKey:[B2WCartManager userDefaultsKeyForBrand]];
	
	NSMutableArray *mutable = [NSMutableArray arrayWithArray:skusAndStoreIds];
	
	[mutable removeObject:skuAndStoreId];
	[mutable insertObject:skuAndStoreId atIndex:0];
	
	while (mutable.count > _kB2WCartManagerMaximumNumberOfProducts)
	{
		[mutable removeObjectAtIndex:mutable.count - 1];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:mutable forKey:[B2WCartManager userDefaultsKeyForBrand]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)canAddSkuAndStoreId:(NSString *)skuAndStoreId
{
	if (skuAndStoreId == nil || [skuAndStoreId isEqualToString:@""])
	{
		return NO;
	}
	
	return YES;
}

+ (BOOL)isAlreadyAddedSku:(NSString *)sku andStoreId:(NSString *)storeId
{
	NSString *skuAndStoreId = [B2WCartManager skuAndStoreIdWithSku:sku andStoreId:storeId];
	NSArray *skusAndStoreIds = [[NSUserDefaults standardUserDefaults] objectForKey:[B2WCartManager userDefaultsKeyForBrand]];
	for (NSString *string in skusAndStoreIds)
	{
		if ([string isEqualToString:skuAndStoreId])
		{
			return YES;
		}
	}
	
	return NO;
}

+ (void)clearSkusAndStoreIds
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:[B2WCartManager userDefaultsKeyForBrand]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)changeCartBadgeInWindow:(UIWindow *)window
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		UITabBarController *tabBarController = (UITabBarController *) window.rootViewController;
		
		NSInteger cartTabBarIndex = 2;
		if ([[B2WAPIClient brandCode] isEqualToString:@"ACOM"])
		{
			cartTabBarIndex = 2;
		}
		else if ([[B2WAPIClient brandCode] isEqualToString:@"SUBA"] || [[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
		{
			cartTabBarIndex = 3;
		}
		
		UITabBarItem *cartTab = (UITabBarItem *) [tabBarController.tabBar.items objectAtIndex:cartTabBarIndex];
		cartTab.badgeValue = ([B2WCartManager skusAndStoreIds].count) > 0 ? @" " : nil;
	}
}

+ (void)changeCartBadgeInBarButton:(UIBarButtonItem *)barButton
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		NSString *brandImageName;
		if ([[B2WAPIClient brandCode] isEqualToString:@"ACOM"])
		{
			brandImageName = ([B2WCartManager skusAndStoreIds].count) > 0 ? @"icn_cestaOFF_badge.png" : @"icn_cestaOFF.png";
		}
		else if ([[B2WAPIClient brandCode] isEqualToString:@"SUBA"])
		{
			brandImageName = ([B2WCartManager skusAndStoreIds].count) > 0 ? @"icn_cart_disabled_badge.png" : @"TabCart";
		}
		else if ([[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
		{
			brandImageName = ([B2WCartManager skusAndStoreIds].count) > 0 ? @"shoptimeNavBarCarrinhoBadge.png" : @"shoptimeNavBarCarrinho.png";
		}
		barButton.image = [UIImage imageNamed:brandImageName];
	}
}

@end
