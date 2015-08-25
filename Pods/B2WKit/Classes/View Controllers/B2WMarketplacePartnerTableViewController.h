//
//  B2WMarketplacePartnerTableViewController.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "B2WProductMarketplacePartner.h"

@interface B2WMarketplacePartnerTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (nonatomic, strong) NSString *marketplacePartnerName;

+ (B2WProductMarketplacePartner *)productMarketplacePartnerWithName:(NSString *)name inPartners:(NSArray *)partners;

@end
