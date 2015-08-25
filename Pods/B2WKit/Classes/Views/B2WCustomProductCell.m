//
//  B2WCustomProductCell.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WCustomProductCell.h"

// Views
#import <EDStarRating/EDStarRating.h>

// Controllers
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>

@interface B2WCustomProductCell()

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelOriginalPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelStock;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelPriceConstraint;
@property (readwrite, nonatomic) CGFloat labelPriceConstraintOriginalValue;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelInstallmentConstraint;
@property (readwrite, nonatomic) NSUInteger labelInstallmentConstraintOriginalValue;

@end

@implementation B2WCustomProductCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    EDStarRating *starRating = self.ratingView;
    starRating.starImage = [UIImage imageNamed:@"icn-star.png"];
    starRating.starHighlightedImage = [UIImage imageNamed:@"icn-star-highlighted.png"];
    starRating.backgroundColor = [UIColor whiteColor];
    starRating.maxRating = 5.0;
    starRating.horizontalMargin = 0;
    starRating.editable = NO;
    starRating.displayMode = EDStarRatingDisplayAccurate;
    
    self.labelPriceConstraintOriginalValue       = self.labelPriceConstraint.constant;
    self.labelInstallmentConstraintOriginalValue = self.labelInstallmentConstraint.constant;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.labelInstallments.text.length == 0)
    {
        CGFloat labelInstallmentConstraintValue = self.labelInstallmentConstraint.constant;
        self.labelInstallmentConstraint.constant = 0;
        self.labelPriceConstraint.constant = self.labelPriceConstraint.constant + labelInstallmentConstraintValue;
    }
    else
    {
        self.labelPriceConstraint.constant       = self.labelPriceConstraintOriginalValue;
        self.labelInstallmentConstraint.constant = self.labelInstallmentConstraintOriginalValue;
    }
}

- (void)setProduct:(B2WProduct *)product
{
    [super setProduct:product];
    
    EDStarRating *starRating = self.ratingView;
    starRating.rating= product.reviewsRatingAverage;
    
    self.labelName.text			= product.name;
    self.ratingView.hidden = (self.product.reviewsRatingAverage == 0);
    
    NSDictionary* attributes = @{ NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle] };
    
    if (self.productMarketplacePartner == nil)
    {
		self.labelPrice.text = product.price;
		
        if (product.priceFrom || product.price)
        {
            NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:( product.priceFrom ? product.priceFrom : product.price ) attributes:attributes];
            self.labelOriginalPrice.attributedText = attrText;
        }
        else
        {
            self.labelOriginalPrice.hidden = YES;
        }
        
        NSString *installmentString = [product.installment stringByReplacingOccurrencesOfString:@"sem juros" withString:@""];
        installmentString = [installmentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.labelInstallments.text = installmentString;
    }
    else
    {
        self.labelPrice.text = self.productMarketplacePartner.price;
        if (self.productMarketplacePartner.price)
        {
            NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:self.productMarketplacePartner.price attributes:attributes];
            self.labelOriginalPrice.attributedText = attrText;
        }
        else
        {
            self.labelOriginalPrice.hidden = YES;
        }
        
        NSString *installmentString = [self.productMarketplacePartner.installments.firstObject stringByReplacingOccurrencesOfString:@"sem juros" withString:@""];
        installmentString = [installmentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.labelInstallments.text = installmentString;
    }
	
    self.labelStock.hidden = product.isInStock;
    self.labelPrice.hidden = self.labelOriginalPrice.hidden = self.labelInstallments.hidden = ! self.labelStock.hidden;
    
	[self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:product.thumbnailImageURL]
						  placeholderImage:[B2WPlaceholderImage image]
								   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
									   self.imageView.image = image;
								   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
									   //
								   }];
}

- (void)addSelectionMarker
{
    self.selectionMarkerImageView.hidden = NO;
}

- (void)removeSelectionMarker
{
    self.selectionMarkerImageView.hidden = YES;
}

@end
