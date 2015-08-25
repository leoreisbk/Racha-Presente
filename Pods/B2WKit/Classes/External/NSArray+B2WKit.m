//
//  NSArray+ProductSorting.m
//  Americanas
//
//  Created by Flavio Caetano on 1/6/14.
//  Copyright (c) 2014 Ideais. All rights reserved.
//

#import "NSArray+B2WKit.h"
#import "B2WProduct.h"

@implementation NSArray (B2WKit)

- (NSArray *)sortedProductArrayUsingReference:(NSArray *)referenceArray
{
    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:referenceArray];
    for (int i = 0; i < referenceArray.count; i++)
    {
        for (B2WProduct *p in self)
        {
            id obj = [referenceArray[i] isKindOfClass:[NSString class]] ? referenceArray[i] : [referenceArray[i] stringValue];
            
            if ([p.identifier isEqualToString:obj])
            {
                [sortedArray replaceObjectAtIndex:i withObject:p];
                break;
            }
        }
    }
    
    return sortedArray;
}

- (NSArray*)sanitizedArray
{
    NSMutableArray *a = self.mutableCopy;
    for (int i = 0; i < a.count; i++)
    {
        if (a[i] == [NSNull null])
        {
            [a removeObjectAtIndex:i];
        }
    }
    
    return [a copy];
}

@end
