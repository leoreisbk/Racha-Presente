//
//  B2WSegmentedControl.m
//  B2WKit
//
//  Created by Thiago Peres on 23/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WSegmentedControl.h"

@interface B2WSegmentedControl ()

@property (nonatomic, assign) NSInteger current;

@end

@implementation B2WSegmentedControl

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.current = self.selectedSegmentIndex;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (self.current == self.selectedSegmentIndex)
    {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
