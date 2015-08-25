//
//  B2WAbstractSwipeViewCell.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SwipeView/SwipeView.h>
#import "B2WMarketplacePartner.h"
#import "B2WProductSelectorProtocol.h"

@interface B2WAbstractSwipeViewCell : UITableViewCell <SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, weak) IBOutlet SwipeView *swipeView;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSString *marketplacePartnerName;
@property (nonatomic, weak) id <B2WProductSelectorProtocol> delegate;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) UINib *swipeViewNib;

- (BOOL)isPagingEnabled;

- (UIImage *)highlitedImageForRatingStar;
- (UIImage *)defaultImageForRatingStar;

@end