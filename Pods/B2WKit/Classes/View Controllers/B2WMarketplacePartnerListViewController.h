//
//  B2WMarketplacePartnerListViewController.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "B2WProduct.h"
#import "B2WProductFreightCalculatorProtocol.h"
#import "B2WSKUSelectionProtocol.h"
#import "B2WMarketplaceProductPartnerCell.h"

@interface B2WMarketplacePartnerListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, B2WProductFreightCalculatorProtocol, B2WSKUSelectionProtocol>

@property (nonatomic, strong) B2WProduct *product;
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) B2WSKUInformation *selectedSku;

@property (strong, nonatomic) id <B2WMarketplacePartnerCellProtocol> delegate;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
