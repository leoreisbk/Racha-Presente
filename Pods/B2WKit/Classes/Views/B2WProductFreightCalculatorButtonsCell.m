//
//  B2WProductFreightCalculatorButtonsCell.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WProductFreightCalculatorButtonsCell.h"

@implementation B2WProductFreightCalculatorButtonsCell

- (void)awakeFromNib
{
    [self.calculateButton setTitleColor:[UIWindow appearance].tintColor forState:UIControlStateNormal];
    [self.calculateButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
}

- (IBAction)calculateButtonPressed:(id)sender
{
    if (self.delegate)
    {
        [self.delegate didPressFreightCalculatorCalculateButton:sender];
    }
}

- (IBAction)recalculateButtonPressed:(id)sender
{
    if (self.delegate)
    {
        [self.delegate didPressFreightCalculatorRecalculateButton:sender];
    }
}

@end
