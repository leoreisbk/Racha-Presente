//
//  B2WProductFreightCalculatorCell.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AFHTTPRequestOperation+B2WKit.h"
#import "B2WProductFreightCalculatorProtocol.h"
#import "B2WProductFreightCalculatorNumberPadProtocol.h"
#import "B2WSKUSelectionProtocol.h"
#import "B2WFreightCalculationProduct.h"

@interface B2WProductFreightCalculatorCell : UITableViewCell <UITextFieldDelegate, B2WProductFreightCalculatorNumberPadProtocol>

@property (assign, nonatomic) BOOL isMarketplace;
@property (assign, nonatomic) BOOL isBeingPresentedFromProductView;
@property (assign, nonatomic) BOOL shouldHideKeyboard;
@property (strong, nonatomic) NSString *productSKU;
@property (strong, nonatomic) NSString *productPrice;

@property (strong, nonatomic) UIBarButtonItem *cancelButton;
@property (strong, nonatomic) UIBarButtonItem *spaceButton;
@property (strong, nonatomic) UIBarButtonItem *doneButton;

// Outlets
@property (weak, nonatomic) IBOutlet UITextField *cepTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *freightLoadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel                 *productFreightCalculatorMessage;
@property (weak, nonatomic) IBOutlet UIButton                *productFreightCalculatorRecalculateButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint      *cepTextFieldTopConstraint;

@property (strong, nonatomic) id <B2WProductFreightCalculatorProtocol, B2WSKUSelectionProtocol> delegate;
@property (strong, nonatomic) AFHTTPRequestOperation               *calculateFreightRequestOperation;

@property (nonatomic, strong) NSArray *sellers;
@property (nonatomic, strong) NSMutableArray *sellerIdentifiers;
@property (nonatomic, strong) AFHTTPRequestOperation *productFreightRequestOperation;

- (void)cancelFreightRequestOperation;
- (IBAction)calculateButtonTouched:(id)sender;
- (IBAction)recalculateFreight:(id)sender;
- (void)resetCalculateFreight;
- (void)_closeKeyboard;

- (void)_showCalculateFreightResponseError:(NSError *)error;
- (void)showInexistingPostalCodeAlertForFreightCalculationResult:(B2WFreightCalculationProduct *)freightCalculationResult;

@end