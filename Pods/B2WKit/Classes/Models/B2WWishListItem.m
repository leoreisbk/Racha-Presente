//
//  B2WWishListItem.m
//  B2WKit
//
//  Created by Thiago Peres on 01/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WWishListItem.h"

// Models
#import "B2WProduct.h"

@implementation B2WWishListItem

- (instancetype)initWithProduct:(B2WProduct *)product
{
    if (self = [self init])
    {
        _productIdentifier = product.identifier;
        _inStockStoredValue = product.inStock;
        _priceStoredValue = product.priceNumber;
        _dateAdded = [NSDate date];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [self init])
    {
        _productIdentifier = [coder decodeObjectForKey:@"productIdentifier"];
        _inStockStoredValue = [coder decodeBoolForKey:@"inStockStoredValue"];
        _priceStoredValue = [coder decodeObjectForKey:@"priceStoredValue"];
        _dateAdded = [coder decodeObjectForKey:@"dateAdded"];
    }
    
    return self;
}

#pragma mark - Deprecated Methods

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.productIdentifier forKey:@"productIdentifier"];
    [coder encodeBool:self.inStockStoredValue forKey:@"inStockStoredValue"];
    [coder encodeObject:self.priceStoredValue forKey:@"priceStoredValue"];
    [coder encodeObject:self.dateAdded forKey:@"dateAdded"];
}

#pragma mark - Deprecated Methods

- (id)initWithProductIdentifier:(NSString*)identifier
{
    self = [super init];
    if (self)
    {
        _productIdentifier = identifier;
        _dateAdded         = [NSDate date];
    }
    return self;
}

@end
