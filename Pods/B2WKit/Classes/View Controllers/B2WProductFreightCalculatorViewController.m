//
//  B2WProductFreightCalculatorViewController.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WProductFreightCalculatorViewController.h"
#import "IDMTableViewContent.h"

@interface B2WProductFreightCalculatorViewController ()

@end

@implementation B2WProductFreightCalculatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableContent = [[NSMutableArray alloc] init];
    self.numberOfSections = [NSNumber numberWithInt:3];
    self.lastPopoverSize = CGSizeMake(320, 265);
    
    [self _createButtonsCell];
    [self _createProductFreightCell];
    [self _createProductNumberPadCell];
    [self.productFreightCalculatorCell.cepTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.productFreightCalculatorCell && [self.productFreightCalculatorCell.calculateFreightRequestOperation isExecuting])
    {
        [self.productFreightCalculatorCell.calculateFreightRequestOperation cancel];
    }
}

- (void)createSeparatorLineInView:(UIView*)viewToAddLine andPosition:(CGFloat)position
{
    CGFloat y = position == 0.0f ? position : position - 0.5f;
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, y, viewToAddLine.frame.size.width, 0.5f)];
    line.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    line.tag = 1001;
    [viewToAddLine addSubview:line];
}

- (void)_createButtonsCell
{
    [self.tableContent addSection];
    self.numberOfCellsInButtonsSection = [NSNumber numberWithInt:0];
    
    self.productFreightCalculatorButtonsCell = (B2WProductFreightCalculatorButtonsCell*) [self.tableView dequeueReusableCellWithIdentifier:@"ButtonsCell"];
    self.productFreightCalculatorButtonsCell.delegate = self;
    
    [self createSeparatorLineInView:self.productFreightCalculatorButtonsCell andPosition:44.0f];
    
    [self.tableContent addCell:self.productFreightCalculatorButtonsCell withIdentifier:@"ButtonsCell"];
    
    self.numberOfCellsInButtonsSection = [NSNumber numberWithInt:[self.numberOfCellsInButtonsSection intValue]+1];
}

- (void)_createProductFreightCell
{
    [self.tableContent addSection];
    self.numberOfCellsInFreightSection = [NSNumber numberWithInt:0];
    
    self.productFreightCalculatorCell = (B2WProductFreightCalculatorCell *)[self.tableView dequeueReusableCellWithIdentifier:@"FreightCell"];
    self.productFreightCalculatorCell.productSKU = self.productSKU;
    self.productFreightCalculatorCell.productPrice = self.productPrice;
    self.productFreightCalculatorCell.delegate = (id)self;
    self.productFreightCalculatorCell.shouldHideKeyboard = YES;
    self.productFreightCalculatorCell.isBeingPresentedFromProductView = YES;
    self.productFreightCalculatorCell.isMarketplace = YES;
    self.productFreightCalculatorCell.sellers = self.marketplaceController.product.marketPlaceInformation.partners;
    self.productFreightCalculatorCell.sellerIdentifiers = self.marketplaceController.fullSellerIdsArray;
    [self.marketplaceController setCanShowFullFreightResult:YES];
    
    [self createSeparatorLineInView:self.productFreightCalculatorCell andPosition:0.0f];
    [self createSeparatorLineInView:self.productFreightCalculatorCell andPosition:50.0f];
    
    [self.tableContent addCell:self.productFreightCalculatorCell withIdentifier:@"FreightCell"];
    
    self.numberOfCellsInFreightSection = [NSNumber numberWithInt:[self.numberOfCellsInFreightSection intValue]+1];
}

- (void)_createProductNumberPadCell
{
    [self.tableContent addSection];
    self.numberOfCellsInNumberPadSection = [NSNumber numberWithInt:0];
    
    self.productFreightCalculatorNumberPadCell = (B2WProductFreightCalculatorNumberPadCell *)[self.tableView dequeueReusableCellWithIdentifier:@"NumberPadCell"];
    self.productFreightCalculatorNumberPadCell.delegate = self.productFreightCalculatorCell;
    
    [self createSeparatorLineInView:self.productFreightCalculatorNumberPadCell andPosition:0.0f];
    [self createSeparatorLineInView:self.productFreightCalculatorNumberPadCell andPosition:174.0f];
    
    [self.tableContent addCell:self.productFreightCalculatorNumberPadCell withIdentifier:@"NumberPadCell"];
    
    self.numberOfCellsInNumberPadSection = [NSNumber numberWithInt:[self.numberOfCellsInNumberPadSection intValue]+1];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableContent cellForIndexPath:indexPath];
    return cell.bounds.size.height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.numberOfSections intValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return self.numberOfCellsInButtonsSection.intValue;
    if (section == 1) return self.numberOfCellsInFreightSection.intValue;
    if (section == 2) return self.numberOfCellsInNumberPadSection.intValue;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.tableContent cellForIndexPath:indexPath];
}

#pragma mark - Freight Calculation Delegate

- (void)didLoadEstimateWithFreightResult:(B2WFreightCalculationProduct *)freightResult
{
    self.productFreightCalculatorResultCell = (B2WProductFreightCalculatorResultCell *)[self.tableView dequeueReusableCellWithIdentifier:@"FreightResultCell"];
    self.productFreightCalculatorResultCell.freightCalculationResult = freightResult;
    
    [self.tableContent addCell:self.productFreightCalculatorResultCell forSection:1 atIndex:1 withIdentifier:@"FreightResultCell"];
    self.numberOfCellsInFreightSection = [NSNumber numberWithInt:[self.numberOfCellsInFreightSection intValue]+1];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)removeResultView
{
    if (self.productFreightCalculatorResultCell)
    {
        [self.tableContent removeCellforSection:1 withIdentifier:@"FreightResultCell"];
        self.numberOfCellsInFreightSection = [NSNumber numberWithInt:[self.numberOfCellsInFreightSection intValue]-1];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        self.productFreightCalculatorResultCell = nil;
    }
}

- (void)removeNumberPad
{
    if (self.productFreightCalculatorNumberPadCell)
    {
        [self.tableContent removeSectionAtIndex:2];
        self.numberOfSections = [NSNumber numberWithInt:2];
        self.numberOfCellsInNumberPadSection = [NSNumber numberWithInt:0];
        
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        self.productFreightCalculatorNumberPadCell = nil;
    }
}

- (void)addNumberPad
{
    if (self.productFreightCalculatorNumberPadCell == nil)
    {
        [self.tableContent addSection];
        self.numberOfSections = [NSNumber numberWithInt:3];
        
        self.productFreightCalculatorNumberPadCell = (B2WProductFreightCalculatorNumberPadCell *)[self.tableView dequeueReusableCellWithIdentifier:@"NumberPadCell"];
        self.productFreightCalculatorNumberPadCell.delegate = self.productFreightCalculatorCell;
        
        [self createSeparatorLineInView:self.productFreightCalculatorNumberPadCell andPosition:0.0f];
        [self createSeparatorLineInView:self.productFreightCalculatorNumberPadCell andPosition:174.0f];
        
        [self.tableContent addCell:self.productFreightCalculatorNumberPadCell forSection:2 atIndex:0 withIdentifier:@"NumberPadCell"];
        self.numberOfCellsInNumberPadSection = [NSNumber numberWithInt:[self.numberOfCellsInNumberPadSection intValue]+1];
        
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)didPressFreightCalculatorCloseButton:(id)sender
{
    if (self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
    }
}

- (void)didPressFreightCalculatorCalculateButton:(id)sender
{
    if (self.productFreightCalculatorCell && self.productFreightCalculatorCell.cepTextField.text.length == kPRODUCT_MAX_SIZE_CEP)
    {
        [self removeNumberPad];
        if (self.popover)
        {
            self.lastPopoverSize = CGSizeMake(320, 150);
            [self.popover setPopoverContentSize:self.lastPopoverSize animated:YES];
        }
        [self.productFreightCalculatorButtonsCell.calculateButton setHidden:YES];
        [self.productFreightCalculatorCell calculateButtonTouched:sender];
    }
}

- (void)reloadFreight
{
    [self didPressFreightCalculatorRecalculateButton:nil];
}

- (void)endCalculateFreight
{
    if (self.productFreightCalculatorButtonsCell)
    {
        [self.productFreightCalculatorButtonsCell.recalculateButton setHidden:NO];
    }
}

- (void)didPressFreightCalculatorRecalculateButton:(id)sender
{
    if (self.productFreightCalculatorCell)
    {
        [self.productFreightCalculatorCell recalculateFreight:sender];
        [self addNumberPad];
        [self.productFreightCalculatorCell resetCalculateFreight];
        
        if (self.productFreightCalculatorButtonsCell)
        {
            [self.productFreightCalculatorButtonsCell.recalculateButton setHidden:YES];
            [self.productFreightCalculatorButtonsCell.calculateButton setHidden:NO];
            
            if (self.popover)
            {
                self.lastPopoverSize = CGSizeMake(320, 265);
                [self.popover setPopoverContentSize:self.lastPopoverSize animated:YES];
            }
        }
    }
}

- (void)resetMarketplaceFreightCalculation
{
    if (self.delegate)
    {
        [self.delegate resetMarketplaceFreightCalculation];
    }
}

- (void)beginCalculateFreight
{
    if (self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
    }
    else
    {
        self.popover = [(UIStoryboardPopoverSegue *)self.popoverSegue popoverController];
        [self.popover dismissPopoverAnimated:YES];
    }
    
    if (self.delegate)
    {
        [self.delegate beginCalculateFreight];
    }
    else
    {
        [self.marketplaceController beginCalculateFreight];
        if (self.productTableView)
        {
            [self.productTableView reloadData];
        }
    }
}

- (void)didLoadEstimateWithFreightResultDictionary:(NSDictionary *)freightResultDictionary
{
    if (self.delegate)
    {
        [self.delegate didLoadEstimateWithFreightResultDictionary:freightResultDictionary];
    }
    else
    {
        if (self.productTableView)
        {
            [self.marketplaceController didLoadEstimateWithFreightResultDictionary:freightResultDictionary];
            [self.productTableView reloadData];
        }
    }
}

- (void)resetMarketplaceFreightList
{
    [self.marketplaceController resetCalculateFreight];
    if (self.productTableView)
    {
        [self.productTableView reloadData];
    }
}

@end
