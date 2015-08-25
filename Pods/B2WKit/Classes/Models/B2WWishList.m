//
//  B2WWishList.m
//  B2WKit
//
//  Created by Thiago Peres on 01/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#define kINTERVAL_TIME 1800 // 30min

// Networking
#import "B2WAPICatalog.h"

// Controllers
#import "B2WWishlistManager.h"

// Models
#import "B2WWishList.h"
#import "B2WWishListItem.h"
#import "B2WProduct.h"

@interface B2WWishList ()

@property (nonatomic, strong) NSMutableArray *internalItems;
@property (nonatomic, strong) NSArray        *cachedProducts;

@property (nonatomic, strong) NSDate         *lastRequestDate;

@end


@implementation B2WWishList

- (NSArray *)items
{
    return self.internalItems;
}

- (NSArray *)itemIdentifiers
{
    return [self.internalItems valueForKeyPath:@"productIdentifier"];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _name              = name;
        _creationDate      = [NSDate date];
        self.internalItems = [NSMutableArray array];
    }
    
    return self;
}

- (B2WWishListItem *)itemWithIdentifier:(NSString *)productIdentifier
{
    for (int i = 0; i < self.internalItems.count; i++)
    {
        B2WWishListItem *item = self.internalItems[i];
        
        if ([item.productIdentifier isEqualToString:productIdentifier])
        {
            return item;
        }
    }
    
    return nil;
}

- (void)setName:(NSString *)name
{
    [self willChangeValueForKey:@"items"];
    
    _name = name;
    
    [self didChangeValueForKey:@"items"];
}

- (void)removeProductIdentifier:(NSString *)identifier
{
    [self willChangeValueForKey:@"items"];
    
    B2WWishListItem *item = [self itemWithIdentifier:identifier];
    
    if (item)
    {
        [self.internalItems removeObject:item];
    }
    
    _lastModifiedDate = [NSDate date];
    
    [self didChangeValueForKey:@"items"];
}

- (BOOL)addProduct:(B2WProduct *)product
{
    if ([self itemWithIdentifier:product.identifier])
    {
        return NO;
    }
    
    [self willChangeValueForKey:@"items"];
    
    [self.internalItems addObject:[[B2WWishListItem alloc] initWithProduct:product]];
    _lastModifiedDate = [NSDate date];
    
    [self didChangeValueForKey:@"items"];
    
    return YES;
}

- (NSArray *)requestProducts:(B2WAPICompletionBlock)block
{
    [self requestProducts:block shouldForceRequest:NO];
    
    return nil;
}

- (NSArray *)requestProducts:(B2WAPICompletionBlock)block shouldForceRequest:(BOOL)forceRequest
{
    NSArray *identifiersArray = [self.cachedProducts valueForKey:@"identifier"];
    
    if (forceRequest || self.lastRequestDate == nil || [self.lastRequestDate timeIntervalSinceNow] > kINTERVAL_TIME || ! [identifiersArray isEqualToArray:self.itemIdentifiers])
    {
        self.lastRequestDate = [NSDate new];
        return [B2WAPICatalog requestProductsWithIdentifiers:self.itemIdentifiers block:^(id object, NSError *error) {
            self.cachedProducts = [object sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSUInteger ind1 = [self.itemIdentifiers indexOfObject:[obj1 identifier]];
                NSUInteger ind2 = [self.itemIdentifiers indexOfObject:[obj2 identifier]];
                
                if (ind1 == ind2)
                {
                    return NSOrderedSame;
                }
                
                return (ind1 < ind2 ? NSOrderedAscending : NSOrderedDescending);
            }];
            
            if (block)
            {
                block(object, error);
            }
            
            // Updating wishlist items
            [self.cachedProducts enumerateObjectsUsingBlock:^(B2WProduct *product, NSUInteger idx, BOOL *stop) {
                B2WWishListItem *item = [self itemWithIdentifier:product.identifier];
                item.priceStoredValue = product.priceNumber;
                item.inStockStoredValue = product.inStock;
            }];
            
            [[B2WWishlistManager sharedManager] save];
        }];
    }
    else if (block)
    {
        block(self.cachedProducts, nil);
    }
    
    return nil;
}

#pragma mark - Deprecated Methods

- (BOOL)addProductIdentifier:(NSString *)identifier
{
    if ([self itemWithIdentifier:identifier])
    {
        return NO;
    }
    
    [self willChangeValueForKey:@"items"];
    
    [self.internalItems addObject:[[B2WWishListItem alloc] initWithProductIdentifier:identifier]];
    _lastModifiedDate = [NSDate date];
    
    [self didChangeValueForKey:@"items"];
    
    return YES;
}

@end
