//
//  NSArray+ProductSorting.h
//  Americanas
//
//  Created by Flavio Caetano on 1/6/14.
//  Copyright (c) 2014 Ideais. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (B2WKit)

- (NSArray *)sortedProductArrayUsingReference:(NSArray *)referenceArray;

- (NSArray*)sanitizedArray;

@end
