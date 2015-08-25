//
//  B2WProductCell.m
//  B2WKit
//
//  Created by Flávio Caetano on 3/28/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WProductCell.h"

@implementation B2WProductCell

#pragma mark - Public Methods

- (void)addSelectionBorder
{
    if (self.selectedProductBorderWidth)
    {
        self.layer.borderWidth = self.selectedProductBorderWidth.floatValue;
    }
    
    if (self.selectedProductBorderColor)
    {
        self.layer.borderColor = self.selectedProductBorderColor.CGColor;
    }
}

- (void)removeSelectionBorder
{
    self.layer.borderWidth = .0;
}

@end
