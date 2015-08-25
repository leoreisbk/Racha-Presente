//
//  B2WMarketplacePartnerTableViewCell.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WMarketplacePartnerTableViewCell.h"

#import "B2WAPIClient.h"

@implementation B2WMarketplacePartnerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    if ([[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
    {
        UIFont *currentTitleLabelFont = self.titleLabel.font;
        UIFont *newTitleLabelFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Regular",currentTitleLabelFont.fontName] size:currentTitleLabelFont.pointSize];
        self.titleLabel.font = newTitleLabelFont;
        
        UIFont *currentTextViewFont = self.textView.font;
        UIFont *newTextViewFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Regular",currentTextViewFont.fontName] size:currentTextViewFont.pointSize];
        self.textView.font = newTextViewFont;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
