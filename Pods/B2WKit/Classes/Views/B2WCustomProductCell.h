//
//  B2WCustomProductCell.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "B2WProduct.h"
#import "B2WProductCell.h"
#import "B2WPlaceholderImage.h"
#import <B2WProductMarketplacePartner.h>

@class EDStarRating;

@interface B2WCustomProductCell : B2WProductCell

@property (nonatomic, strong) B2WProduct *product;
@property (nonatomic, strong) B2WProductMarketplacePartner *productMarketplacePartner;

@property (nonatomic, weak) IBOutlet EDStarRating *ratingView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *labelInstallments;
@property (weak, nonatomic) IBOutlet UIImageView *selectionMarkerImageView;

- (void)addSelectionMarker;
- (void)removeSelectionMarker;

@end
