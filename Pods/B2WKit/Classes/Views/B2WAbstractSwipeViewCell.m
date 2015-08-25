//
//  B2WAbstractSwipeViewCell.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WAbstractSwipeViewCell.h"
#import <B2WMarketplaceInformation.h>
#import <B2WMarketplacePartnerTableViewController.h>

// Cells
#import "B2WCustomProductCell.h"

// Views
#import <EDStarRating/EDStarRating.h>

@interface B2WAbstractSwipeViewCell ()

@end

@implementation B2WAbstractSwipeViewCell

- (void)awakeFromNib
{
    [self.swipeView setDataSource:self];
    [self.swipeView setDelegate:self];
    
    self.swipeView.clipsToBounds = NO;
    
	self.swipeView.alignment         = SwipeViewAlignmentEdge;
	self.swipeView.pagingEnabled     = [self isPagingEnabled];
	self.swipeView.bounces           = YES;
	self.swipeView.wrapEnabled       = NO;
	self.swipeView.itemsPerPage      = 1;
	self.swipeView.truncateFinalPage = YES;
}

- (void)setProducts:(NSArray *)products
{
    _products = products;
	
    [self.swipeView reloadData];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    B2WProduct *product = self.products[index];
    B2WCustomProductCell *productView = (B2WCustomProductCell *)view;
    
    if (productView == nil)
    {
        productView = [[self.swipeViewNib instantiateWithOwner:self options:nil] firstObject];
    }
    
    if (self.marketplacePartnerName)
    {
        productView.productMarketplacePartner = [B2WMarketplacePartnerTableViewController productMarketplacePartnerWithName:self.marketplacePartnerName inPartners:[product allProductMarketplacePartners]];
    }
    
    [productView setProduct:product];
    
    EDStarRating *starRating        = productView.ratingView;
    starRating.starImage            = [self defaultImageForRatingStar];
    starRating.starHighlightedImage = [self highlitedImageForRatingStar];
    
    return productView;
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.products.count;
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectProduct:sender:)])
    {
        [self.delegate didSelectProduct:self.products[index] sender:[self swipeView:swipeView viewForItemAtIndex:index reusingView:nil]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:NO];
}

- (BOOL)isPagingEnabled
{
    return NO;
}

#pragma mark - Abstract Methods
- (UIImage *)highlitedImageForRatingStar kABSTRACT_METHOD
- (UIImage*)defaultImageForRatingStar kABSTRACT_METHOD
@end
