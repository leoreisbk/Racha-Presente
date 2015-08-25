//
//  B2WProductCell.h
//  B2WKit
//
//  Created by Flávio Caetano on 3/28/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class B2WProduct;

@interface B2WProductCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *promoBadgeImageView;

/**
 The product object associated with the cell.
 */
@property (nonatomic, strong) B2WProduct *product;

/**
 The info button in the product cell.
 */
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

#pragma mark - Appearance Properties

/**
 *  The color of the border for the selected product.
 */
@property (nonatomic, strong) UIColor *selectedProductBorderColor UI_APPEARANCE_SELECTOR;

/**
 *  The width for the selected product border.
 */
@property (nonatomic, strong) NSNumber *selectedProductBorderWidth UI_APPEARANCE_SELECTOR;

/**
 *  Adds the selection border.
 */
- (void)addSelectionBorder;

/**
 *  Removes the selection border.
 */
- (void)removeSelectionBorder;

@end
