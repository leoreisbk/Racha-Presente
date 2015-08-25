//
//  B2WCheckoutManager.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WCheckoutManager.h"
#import "B2WAPIClient.h"

#define kB2WCheckoutManagerProductsKey @"kB2WCheckoutManagerProductsKey"

//#define kB2WCheckoutManagerMaximumNumberOfProducts 100
//#define kB2WCheckoutManagerSkuIdPrefix @"codItemFusion"
//#define kB2WCheckoutManagerStoreIdPrefix @"storeId"
//#define kB2WCheckoutManagerStoreIdIphonePrefix @"loja"

@implementation NSString (Substring)

- (BOOL)containsSubstring:(NSString*)substring
{
	return ([self rangeOfString:substring].location != NSNotFound);
}

@end

@implementation B2WCheckoutManager

+ (void)addProductWithSKU:(NSString *)SKU storeId:(NSString *)storeId
{
	if (storeId == nil)
	{
		storeId = @"";
	}
	
	NSMutableArray *productDicts = [NSMutableArray arrayWithArray:[B2WCheckoutManager products]];
	NSDictionary *productDict = @{@"SKU": SKU, @"storeId": storeId};
	
	[productDicts removeObject:productDict];
	[productDicts insertObject:productDict atIndex:0];
	
	/*while (productDicts.count > kB2WCheckoutManagerMaximumNumberOfProducts) {
		[productDicts removeObjectAtIndex:productDicts.count - 1];
	}*/
	
	[[NSUserDefaults standardUserDefaults] setObject:productDicts forKey:kB2WCheckoutManagerProductsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeProductWithSKU:(NSString *)SKU storeId:(NSString *)storeId
{
	if (storeId == nil)
	{
		storeId = @"";
	}
	
	NSMutableArray *productDicts = [NSMutableArray arrayWithArray:[B2WCheckoutManager products]];
	NSDictionary *productDict = @{@"SKU": SKU, @"storeId": storeId};
	
	[productDicts removeObject:productDict];
	[productDicts insertObject:productDict atIndex:0];
	
	/*while (productDicts.count > kB2WCheckoutManagerMaximumNumberOfProducts) {
		[productDicts removeObjectAtIndex:productDicts.count - 1];
	}*/
	
	[[NSUserDefaults standardUserDefaults] setObject:productDicts forKey:kB2WCheckoutManagerProductsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)containsProductWithSKU:(NSString *)SKU storeId:(NSString *)storeId
{
	if (storeId == nil)
	{
		storeId = @"";
	}
	
	NSDictionary *productDict = @{@"SKU": SKU, @"storeId": storeId};
	NSArray *productDicts = [B2WCheckoutManager products];
	
	return [productDicts containsObject:productDict];
}

+ (NSArray *)products
{
	NSArray *productDicts = [[NSUserDefaults standardUserDefaults] objectForKey:kB2WCheckoutManagerProductsKey];
	return productDicts ? productDicts : [NSArray array]; // never return nil
}

+ (void)clearProduct
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kB2WCheckoutManagerProductsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)updateCartTabBarBadge
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
		UITabBarController *tabBarController = (UITabBarController *) window.rootViewController;
		
		NSInteger cartTabBarIndex = 3;
		
		if ([[B2WAPIClient brandCode] isEqualToString:@"ACOM"])
		{
			cartTabBarIndex = 2;
		}
		else if ([[B2WAPIClient brandCode] isEqualToString:@"SUBA"])
		{
			cartTabBarIndex = 3;
		}
		
		UITabBarItem *cartTab = (UITabBarItem *) [tabBarController.tabBar.items objectAtIndex:cartTabBarIndex];

		if ([B2WCheckoutManager products].count == 0)
		{
			cartTab.badgeValue = nil;
		}
		else
		{
			cartTab.badgeValue = [NSString stringWithFormat:@"%d", [B2WCheckoutManager products].count];
		}
	}
}

+ (void)updateCartBadgeInBarButton:(UIBarButtonItem *)barButton
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		NSString *brandImageName;
		
		if ([[B2WAPIClient brandCode] isEqualToString:@"ACOM"])
		{
			brandImageName = ([B2WCheckoutManager products].count) > 0 ? @"icn_cestaOFF_badge.png" : @"icn_cestaOFF.png";
		}
		else if ([[B2WAPIClient brandCode] isEqualToString:@"SUBA"])
		{
			brandImageName = ([B2WCheckoutManager products].count) > 0 ? @"icn_cart_disabled_badge.png" : @"TabCart";
		}
		
		barButton.image = [UIImage imageNamed:brandImageName];
	}
}

@end
