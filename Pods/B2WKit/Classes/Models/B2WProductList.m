//
//  B2WProductList.m
//  B2WKit
//
//  Created by Flávio Caetano on 12/20/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WProductList.h"

// Models
#import "B2WProduct.h"

@interface NSDictionary (B2WProductListExtensions)

typedef enum {
    B2WProductListDictionaryKindRecommendation,
    B2WProductListDictionaryKindCatalog,
} B2WProductListDictionaryKind;

@property (nonatomic, readonly) B2WProductListDictionaryKind productListKind;

@end

@implementation NSDictionary (B2WProductListExtensions)

- (B2WProductListDictionaryKind)productListKind
{
    if ([self containsObjectForKey:@"productList"])
    {
        return B2WProductListDictionaryKindRecommendation;
    }
    return B2WProductListDictionaryKindCatalog;
}

@end

@implementation B2WProductList

- (instancetype)_initWithRecommendationDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
		if ([dictionary containsObjectForKey:@"recTitle"])
        {
			// Removes "...e " prefix
			if ([dictionary[@"recTitle"] hasPrefix:@"...e "]) {
				self.title = [dictionary[@"recTitle"] stringByReplacingOccurrencesOfString:@"...e " withString:@""];
				
				//
				// Capitalizes first character of the sentence
				//
				self.title = [self.title stringByReplacingCharactersInRange:NSMakeRange(0,1)
																 withString:[[self.title substringToIndex:1] uppercaseString]];
			}
			else {
				self.title = dictionary[@"recTitle"];
			}
        }
		
        self.mainProductTitle = dictionary[@"mainProductTitle"];
        self.titlePrefix = dictionary[@"prefixTitle"];
        if ([dictionary containsObjectForKey:@"hint"])
        {
            self.titleHint = dictionary[@"hint"];
        }
        if ([dictionary containsObjectForKey:@"mainProduct"])
        {
            self.mainProduct = dictionary[@"mainProduct"];
        }
        self.identifier = dictionary[@"type"];
        self.items      = [dictionary arrayForKey:@"productList"];
    }
    return self;
}

- (instancetype)_initWithCatalogDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self)
    {
        self.title      = dictionary[@"_title"];
        self.identifier = self.title;
        self.items      = [B2WProduct objectsWithDictionaryArray:[dictionary arrayForKey:@"product"]];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    if (dictionary.productListKind == B2WProductListDictionaryKindCatalog)
    {
        return [self _initWithCatalogDictionary:dictionary];
    }
    else if (dictionary.productListKind == B2WProductListDictionaryKindRecommendation)
    {
        return [self _initWithRecommendationDictionary:dictionary];
    }
    return nil;
}

@end
