//
//  B2WMarketplaceProductPartnerCell.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WMarketplaceProductPartnerCell.h"
#import "B2WAPIClient.h"

@interface B2WMarketplaceProductPartnerCell()

@end

@implementation B2WMarketplaceProductPartnerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.partnerName.text = @"";
    self.productPrice.text = @"";
    self.productInstallment.text = @"";
    self.freightMessage.text = @"";
    
    self.freightResultErrorTitle = nil;
    self.freightResultErrorMessage = nil;
    
    self.freightMessageInfoButton.hidden = YES;
    [self.freightMessageInfoButton setTitle:[NSString stringWithFormat:@"\u26A0"] forState:UIControlStateNormal];
    
    self.buttonNameConstraintOriginalValue       = self.buttonNameConstraint.constant;
    self.labelPriceConstraintOriginalValue       = self.labelPriceConstraint.constant;
    self.labelInstallmentConstraintOriginalValue = self.labelInstallmentConstraint.constant;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.buttonNameConstraint.constant = (self.partnerName.text.length == 0) ? 0 : [self widthForPartnerNameWithText:self.partnerName.text];
    
    if (self.productInstallment.text.length == 0)
    {
        self.labelInstallmentConstraint.constant = 0;
        self.labelPriceConstraint.constant = 35.f;
    }
    else
    {
        self.labelPriceConstraint.constant       = self.labelPriceConstraintOriginalValue;
        self.labelInstallmentConstraint.constant = self.labelInstallmentConstraintOriginalValue;
    }
}

- (CGFloat)widthForPartnerNameWithText:(NSString *)text
{
    CGFloat width = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 240 : 420;
    
    CGRect textSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}
                                         context:nil];
    
    return MIN(width, ceil(textSize.size.width + 40));
}

- (void)setPartner:(B2WProductMarketplacePartner *)partner forBrand:(NSString *)brand
{
    _partner = partner;
    
    self.partnerName.text = self.partner.name;
    self.productPrice.text = self.partner.price;
    self.productInstallment.text = self.partner.installments[0];
    
    BOOL canHideInfo = [partner.name isEqualToString:brand] ? YES : NO;
    self.infoButton.hidden = canHideInfo;
    
    if (canHideInfo)
    {
        NSString *brandImageName;
        if ([[B2WAPIClient brandCode] isEqualToString:@"ACOM"])
        {
            brandImageName = @"marketplace_acom.png";
        }
        else if ([[B2WAPIClient brandCode] isEqualToString:@"SUBA"])
        {
            brandImageName = @"marketplace_suba.png";
        }
        else if ([[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
        {
            brandImageName = @"marketplace_shop.png";
        }
        self.infoImage.image = [UIImage imageNamed:brandImageName];
    }
    else
    {
        self.infoImage.image = [UIImage imageNamed:@"marketplace_info.png"];
    }
}

- (IBAction)buyButtonPressed
{
    if (!self.isFreightResultPartial)
    {
        if (self.delegate)
        {
            [self.delegate buyButtonPressedFoPartner:self.partner];
        }
    }
    else
    {
        [self showWarningAlertWithTitle:self.freightResultErrorTitle andMessage:self.freightResultErrorMessage];
    }
}

- (IBAction)freightMessageInfoButtonPressed
{
    NSString *title = [NSString stringWithFormat:@"\u26A0 %@", self.freightResultErrorTitle];
	
	[IDMAlertViewManager showAlertWithTitle:title message:self.freightResultErrorMessage];
}

+ (CGFloat)heigthForFreightMessageWithText:(NSString *)text forBrand:(NSString *)brand
{
    CGFloat width = 400;
    CGFloat fontSize = 16.0f;
    
    if ([brand isEqualToString:@"Americanas"])
    {
        width = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 270 : 400;
        fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 15.0f : 16.0f;
    }
    else if ([brand isEqualToString:@"Submarino"])
    {
        width = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 270 : 450;
        fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 15.0f : 17.0f;
    }
    
    CGRect textSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}
                                         context:nil];
    
    return MAX(26.0f, ceil(textSize.size.height + 10));
}

- (void)showWarningAlertWithTitle:(NSString *) title andMessage:(NSString *) message
{
    title = [NSString stringWithFormat:@"\u26A0 %@", title];
	
	[IDMAlertViewManager showAlertWithTitle:title
									message:message
								   priority:IDMAlertPriorityMedium
									success:^(NSUInteger selectedIndex) {
                                        
										if (self.isFreightResultPartial && self.delegate)
										{
											[self.delegate buyButtonPressedFoPartner:self.partner];
										}
									} failure:nil];
}

@end
