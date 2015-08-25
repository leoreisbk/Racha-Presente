//
//  B2WProductFreightCalculatorNumberPadCell.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WProductFreightCalculatorNumberPadCell.h"

@implementation B2WProductFreightCalculatorNumberPadCell

- (void)awakeFromNib
{
	[super awakeFromNib];
    
    UIColor *selectedColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    
    for (UIView *view in self.contentView.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton*) view;
            [button addTarget:self action:@selector(freightCalculatorNumberPadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            if (button.tag < 10)
            {
                [button setBackgroundImage:[self imageWithColor:selectedColor] forState:UIControlStateHighlighted];
            }
            else if (button.tag == 1001)
            {
                [button setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
            }
        }
    }
}

- (IBAction)freightCalculatorNumberPadButtonPressed:(id)sender
{
    if (self.delegate)
    {
        [self.delegate didPressFreightCalculatorNumberPadButton:sender];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
