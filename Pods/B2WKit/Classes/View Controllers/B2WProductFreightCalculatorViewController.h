//
//  B2WProductFreightCalculatorViewController.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "B2WProductFreightCalculatorButtonsProtocol.h"
#import "B2WProductFreightCalculatorButtonsCell.h"
#import "B2WProductFreightCalculatorCell.h"
#import "B2WProductFreightCalculatorResultCell.h"
#import "B2WProductFreightCalculatorNumberPadCell.h"
#import "B2WMarketplaceController.h"

@interface B2WProductFreightCalculatorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, B2WProductFreightCalculatorProtocol, B2WProductFreightCalculatorButtonsProtocol>

@property (strong, nonatomic) UIStoryboardPopoverSegue *popoverSegue;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UITableView *productTableView;

@property (weak, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) NSMutableArray *tableContent;

@property (strong, nonatomic) NSNumber* numberOfSections;
@property (strong, nonatomic) NSNumber* numberOfCellsInButtonsSection;
@property (strong, nonatomic) NSNumber* numberOfCellsInFreightSection;
@property (strong, nonatomic) NSNumber* numberOfCellsInNumberPadSection;

@property (strong, nonatomic) NSString *productSKU;
@property (strong, nonatomic) NSString *productPrice;

@property (strong, nonatomic) B2WProductFreightCalculatorButtonsCell *productFreightCalculatorButtonsCell;
@property (strong, nonatomic) B2WProductFreightCalculatorCell *productFreightCalculatorCell;
@property (strong, nonatomic) B2WProductFreightCalculatorResultCell *productFreightCalculatorResultCell;
@property (strong, nonatomic) B2WProductFreightCalculatorNumberPadCell *productFreightCalculatorNumberPadCell;

// Marketplace
@property (nonatomic, strong) B2WMarketplaceController *marketplaceController;
@property (strong, nonatomic) id <B2WProductFreightCalculatorProtocol> delegate;

@property (nonatomic, assign) CGSize lastPopoverSize;

@end