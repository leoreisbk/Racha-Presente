//
//  B2WWishlistController.m
//  B2WKit
//
//  Created by Thiago Peres on 01/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WWishlistManager.h"

// Models
#import "B2WProduct.h"
#import "B2WWishList.h"
#import "B2WWishListItem.h"

#define _kB2WWishListsUserDefaultsKey @"kB2WWishListsUserDefaultsKey"
#define kDEFAULT_PRICE_TRESHOLD 3.f

@interface B2WWishlistManager ()

@property (nonatomic, strong) NSMutableArray *internalWishLists;

@end


@implementation B2WWishlistManager

+ (instancetype)sharedManager
{
    static B2WWishlistManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[B2WWishlistManager alloc] init];
        [_sharedManager _load];
    });
    
    return _sharedManager;
}

- (NSArray *)wishlists
{
    return self.internalWishLists;
}

- (BOOL)addWishListNamed:(NSString *)wishListName
{
    if ([self wishListNamed:wishListName])
    {
        return NO;
    }
    
    [self willChangeValueForKey:@"wishlists"];
    
    [self.internalWishLists addObject:[[B2WWishList alloc] initWithName:wishListName]];
    
    [self didChangeValueForKey:@"wishlists"];
    
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"items"])
    {
		// [self _save];
    }
}

- (void)removeWishListNamed:(NSString *)wishListName
{
    B2WWishList *wishList = [self wishListNamed:wishListName];
    if (wishList)
    {
        [self willChangeValueForKey:@"wishlists"];
        
        [self.internalWishLists removeObject:wishList];
        
        [self didChangeValueForKey:@"wishlists"];
    }
}

- (B2WWishList*)wishListNamed:(NSString*)wishListName
{
    for (B2WWishList *wishList in self.internalWishLists)
    {
        if ([wishList.name isEqualToString:wishListName])
        {
            return wishList;
        }
    }
    
    return nil;
}

- (B2WWishList *)defaultWishlist
{
	[self addWishListNamed:_kB2WWishListsUserDefaultsKey];
	return [self wishListNamed:_kB2WWishListsUserDefaultsKey];
}

- (void)save
{
    //
    // NSUserDefaults only accepts default data types
    // so we need to convert our objects to NSData before saving
    //
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *tmp = [NSMutableArray new];
        [self.internalWishLists enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tmp addObject:[NSKeyedArchiver archivedDataWithRootObject:obj]];
        }];
        
		[[NSUserDefaults standardUserDefaults] setObject:tmp forKey:_kB2WWishListsUserDefaultsKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	});
}

- (void)fetchDefaultWishListInBackground:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    __block BOOL shouldNotifyPriceChanges = [userDefaults boolForKey:kUSER_DEFAULTS_PRICE_NOTIFICATION_SETTINGS];
    __block BOOL shouldNotifyStockChanges = [userDefaults boolForKey:kUSER_DEFAULTS_STOCK_NOTIFICATION_SETTINGS];
    
    self.defaultWishlist.betterPriceItemsIdentifiers = self.defaultWishlist.availableItemsIdentifiers = nil;
    
    if (! shouldNotifyPriceChanges && !shouldNotifyStockChanges)
    {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    
    DLog(@"Fetching wishlist in background");
    
    __block B2WWishList *defaultWishlist = self.defaultWishlist;
    [defaultWishlist requestProducts:^(id object, NSError *error) {
        if (error)
        {
            DLog(@"%@", error);
            completionHandler(UIBackgroundFetchResultFailed);
            return;
        }
        
        id infoSettingsTreshold = [[[NSBundle mainBundle] infoDictionary] objectForKey:kPriceDifferTreshold];
        CGFloat priceDifferTreshold = (infoSettingsTreshold != nil ? [infoSettingsTreshold floatValue] : kDEFAULT_PRICE_TRESHOLD);
        
        NSMutableArray *betterPriceArray = [NSMutableArray new];
        NSMutableArray *availableProductsArray = [NSMutableArray new];
        NSUInteger updatedProductsCounter = 0;
        B2WProduct *updatedProduct = nil;
        
        for (B2WProduct *newProduct in object)
        {
            B2WWishListItem *wishlistItem = [defaultWishlist itemWithIdentifier:newProduct.identifier];
            double storedPriceWithinTreshold = wishlistItem.priceStoredValue.doubleValue * (1 - (priceDifferTreshold / 100));
            BOOL didUpdateProduct = NO;
            
            if (shouldNotifyPriceChanges && newProduct.inStock && newProduct.priceNumber.doubleValue < storedPriceWithinTreshold)
            {
                updatedProduct = newProduct;
                [betterPriceArray addObject:newProduct.identifier];
                didUpdateProduct = YES;
            }
            
            if (shouldNotifyStockChanges && !wishlistItem.inStockStoredValue && newProduct.inStock)
            {
                updatedProduct = newProduct;
                [availableProductsArray addObject:newProduct.identifier];
                didUpdateProduct = YES;
            }
            
            updatedProductsCounter += didUpdateProduct;
        }
        
        if (updatedProductsCounter == 0)
        {
            // Nothing changed
            completionHandler(UIBackgroundFetchResultNoData);
            return;
        }
        
        NSString *message = nil;
        if (availableProductsArray.count == 1 && betterPriceArray.count == 0)
        {
            // Only updated one product and it's back in stock.
            NSString *productName = updatedProduct.name;
            if (productName.length >= 169)
            {
                productName = [productName substringToIndex:168];
                productName = [productName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                productName = [productName stringByAppendingString:@"…"];
            }
    
            message = [NSString stringWithFormat:@"Seu favorito \"%@\" está disponível", productName];
        }
        else if (availableProductsArray.count == 0 && betterPriceArray.count == 1)
        {
            // Only updated one product and it's price is lower.
            B2WWishListItem *wishlistItem = [defaultWishlist itemWithIdentifier:updatedProduct.identifier];
            float priceDifferPercentage = (1 - updatedProduct.priceNumber.floatValue / wishlistItem.priceStoredValue.floatValue) * 100;
            NSString *str1 = [NSString stringWithFormat:@"Seu favorito \""];
            NSString *str2 = [NSString stringWithFormat:@"\" caiu para %@ ▼%.0f\uFF05", updatedProduct.price, priceDifferPercentage];
            
            float maxLength = 200 - str1.length - str2.length;
            NSString *productName = updatedProduct.name;
            if (productName.length >= maxLength)
            {
                productName = [productName substringToIndex:maxLength-1];
                productName = [productName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                productName = [productName stringByAppendingString:@"…"];
            }
            
            message = [NSString stringWithFormat:@"%@%@%@", str1, productName, str2];
        }
        else if (betterPriceArray.count > 0)
        {
            updatedProduct = nil;
            if (betterPriceArray.count == 1)
            {
                message = [NSString stringWithFormat:@"Um dos seus produtos favoritos caiu de preço"];
            }
            else
            {
                message = [NSString stringWithFormat:@"%ld dos seus produtos favoritos caíram de preço", (unsigned long)betterPriceArray.count];
            }
            
            if (availableProductsArray.count == 1)
            {
                message = [message stringByAppendingFormat:@" e um está disponível"];
            }
            else if (availableProductsArray.count > 1)
            {
                message = [message stringByAppendingFormat:@" e %ld estão disponíveis", (unsigned long)availableProductsArray.count];
            }
        }
        else if (availableProductsArray.count > 1)
        {
            updatedProduct = nil;
            message = [NSString stringWithFormat:@"%ld dos seus produtos favoritos estão disponíveis", (unsigned long)availableProductsArray.count];
        }
        
        message = [message stringByAppendingString:@"!"];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        if (betterPriceArray)
        {
            userInfo[kB2WWishlistNotificationBetterPriceIdentifiers] = betterPriceArray;
            self.defaultWishlist.betterPriceItemsIdentifiers = betterPriceArray;
        }
        
        if (availableProductsArray)
        {
            userInfo[kB2WWishlistNotificationAvailableProductsIdentifiers] = availableProductsArray;
            self.defaultWishlist.availableItemsIdentifiers = availableProductsArray;
        }
        
        if (updatedProduct)
        {
            userInfo[kB2WWishlistNotificationProduct] = [NSKeyedArchiver archivedDataWithRootObject:updatedProduct];
        }
        
        // Firing local notification
        UILocalNotification *localNotification = [UILocalNotification new];
        localNotification.alertBody = message;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.userInfo = userInfo;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [UIApplication sharedApplication].applicationIconBadgeNumber += updatedProductsCounter;
        completionHandler(UIBackgroundFetchResultNewData);
    } shouldForceRequest:YES];
}

#pragma mark - Private Methods

- (void)_load
{
    //
    // NSUserDefaults only accepts default data types
    // so we need to decode our objects from NSData
    //
    NSMutableArray *archiveArray = [NSMutableArray array];
    
    NSArray *storedData = [[NSUserDefaults standardUserDefaults] objectForKey:_kB2WWishListsUserDefaultsKey];
    [storedData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [archiveArray addObject:[NSKeyedUnarchiver unarchiveObjectWithData:obj]];
    }];
    
    self.internalWishLists = archiveArray;
}

@end
