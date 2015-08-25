//
//  ACOMPlaceholderView.m
//  Americanas
//
//  Created by Rodrigo Fontes on 1/7/14.
//  Copyright (c) 2014 Ideais. All rights reserved.
//

#define kBUTTON_CORNER_RADIUS  5
#define kBORDER_WIDTH          1
#define kBUTTON_DEFAULT_TITLE  @"tentar novamente"

#import "IDMContentUnavailableView.h"

@implementation IDMContentUnavailableView

- (id)initWithFrame:(CGRect)frame
{
    UINib *nib = [UINib nibWithNibName:@"IDMContentUnavailableView" bundle:nil];
    NSArray *array = [nib instantiateWithOwner:self options:nil];
    self = [array firstObject];
    self.frame = frame;
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.reloadButton.layer.cornerRadius = kBUTTON_CORNER_RADIUS;
	self.reloadButton.layer.borderWidth = kBORDER_WIDTH;
    
    UIColor *globalColor = [UIApplication sharedApplication].keyWindow.tintColor;
    self.reloadButton.tintColor = globalColor;
    self.reloadButton.layer.borderColor = globalColor.CGColor;
}

- (IBAction)reloadButtonTouched
{
    if (self.reloadButtonPressedBlock)
    {
        self.reloadButtonPressedBlock();
    }
}

- (void)setSuperviewScrollEnabled:(BOOL)enabled
{
    if ([self.superview isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *scrollView = (UIScrollView*)self.superview;
        [scrollView setScrollEnabled:enabled];
    }
}

- (void)showWithTitle:(NSString *)title message:(NSString *)message reloadButtonPressedBlock:(IDMReloadButtonPressedBlock)block
{
	[self showWithTitle:title message:message buttonTitle:nil reloadButtonPressedBlock:block];
}

- (void)showWithTitle:(NSString*)title message:(NSString*)message buttonTitle:(NSString *)buttonTitle reloadButtonPressedBlock:(IDMReloadButtonPressedBlock)block
{
    self.titleLabel.text = title;
    self.messageLabel.text = message;
	
	[self.reloadButton setTitle:(buttonTitle ?: kBUTTON_DEFAULT_TITLE) forState:UIControlStateNormal];
	
    if (block == nil)
    {
        [self.reloadButton setHidden:YES];
    }
    else
    {
        self.reloadButtonPressedBlock = [block copy];
    }
	
    [self show];
}

- (void)show
{
    [self setHidden:NO];
    [self.superview bringSubviewToFront:self];
    [self setSuperviewScrollEnabled:NO];
}

- (void)dismiss
{
    [self setHidden:YES];
    [self setSuperviewScrollEnabled:YES];
}

@end
