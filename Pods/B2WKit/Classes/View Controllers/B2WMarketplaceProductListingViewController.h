//
//  B2WMarketplaceProductListingViewController.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WProductListingViewController.h"
#import "B2WMarketplacePartner.h"

@interface B2WMarketplaceProductListingViewController : B2WProductListingViewController

@property (nonatomic, strong) B2WMarketplacePartner *partner;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *searchBarWidthConstraint;

@end
