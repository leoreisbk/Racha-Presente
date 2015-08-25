//
//  B2WMarketplacePartnerListViewController.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WMarketplacePartnerListViewController.h"
#import "B2WMarketplaceInformation.h"
#import "B2WProductFreightCalculatorCell.h"
#import "B2WMarketplaceProductPartnerCell.h"
#import "B2WProductFreightCalculatorCell.h"
#import "B2WMarketplaceController.h"
#import "B2WMarketplacePartnerTableViewController.h"
#import "B2WProductFreightCalculatorViewController.h"

#import "B2WAPIClient.h"


@interface B2WMarketplacePartnerListViewController () <B2WMarketplacePartnerCellProtocol>

@property (nonatomic, strong) B2WMarketplaceController *controller;

@property (nonatomic, strong) B2WProductFreightCalculatorCell *freightCalculatorCell;

@end

@implementation B2WMarketplacePartnerListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Todas opções de compra";
    
    self.controller = [[B2WMarketplaceController alloc] initWithProduct:self.product brand:self.brand];
    [self.controller setCanShowFullFreightResult:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController])
    {
        if (self.freightCalculatorCell)
        {
            [self.freightCalculatorCell.calculateFreightRequestOperation cancel];
            [self.freightCalculatorCell cancelFreightRequestOperation];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MarketplacePartner"])
    {
        UIButton *button = sender;
        B2WMarketplacePartnerTableViewController *destination = segue.destinationViewController;
        B2WProductMarketplacePartner *partner = self.controller.fullPartnersArray[button.tag];
        destination.marketplacePartnerName = partner.name;
        
        if (kIsIpad)
        {
            [self titleButtonPressedFoPartner:partner];
        }
    }
    else if ([segue.identifier isEqualToString:@"Freight"])
    {
        UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
        B2WProductFreightCalculatorViewController *destination = popoverSegue.destinationViewController;
        destination.popoverSegue = popoverSegue;
        destination.marketplaceController = self.controller;
        destination.productTableView = self.tableView;
        [destination setProductSKU:self.selectedSku.SKUIdentifier];
        [destination setProductPrice:self.product.price];
        
        [popoverSegue.popoverController setPopoverContentSize:destination.lastPopoverSize];
    }
}

#pragma mark - UI Actions

- (IBAction)didPressCloseButton:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? 1 : self.controller.fullPartnersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (self.freightCalculatorCell == nil)
        {
            self.freightCalculatorCell = [self.tableView dequeueReusableCellWithIdentifier:@"FreightCell"];
        }
        self.freightCalculatorCell.delegate = self;
        self.freightCalculatorCell.isMarketplace = YES;
        self.freightCalculatorCell.productSKU = self.selectedSku.SKUIdentifier;
        self.freightCalculatorCell.productPrice = self.product.price;
        self.freightCalculatorCell.sellerIdentifiers = self.controller.fullSellerIdsArray;
        
        return self.freightCalculatorCell;
    }
    else
    {
        return [self.controller cellForRowAtIndexPath:indexPath inTableView:self.tableView withDelegate:self];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.controller heightForRowAtIndexPath:indexPath isFormsheet:YES];
}

- (void)beginCalculateFreight
{
    [self.controller beginCalculateFreight];
    if (self.freightCalculatorCell)
    {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        [self.tableView reloadData];
    }
}

- (void)didLoadEstimateWithFreightResultDictionary:(NSDictionary *)freightResultDictionary
{
    [self.controller didLoadEstimateWithFreightResultDictionary:freightResultDictionary];
    
    B2WFreightCalculationProduct *freightCalculationResult = [freightResultDictionary objectForKey:self.controller.fullSellerIdsArray.firstObject];
    
    NSError *error = (NSError *)freightCalculationResult;
    if (freightCalculationResult && [error isKindOfClass:[B2WFreightCalculationProduct class]])
    {
        if (freightCalculationResult.resultType == B2WAPIFreightCalculationResultInexistingPostalCode)
        {
            [self.freightCalculatorCell showInexistingPostalCodeAlertForFreightCalculationResult:freightCalculationResult];
            if (self.freightCalculatorCell)
            {
                self.freightCalculatorCell.productFreightCalculatorRecalculateButton.hidden = YES;
            }
        }
        else if (self.freightCalculatorCell)
        {
            self.freightCalculatorCell.productFreightCalculatorRecalculateButton.hidden = NO;
        }
    }
    
    [self.tableView reloadData];
}

- (void)buyButtonPressedFoPartner:(B2WProductMarketplacePartner *)partner
{
    [self.navigationController popViewControllerAnimated:NO];
    if (self.delegate)
    {
        [self.delegate buyButtonPressedFoPartner:partner];
    }
}

- (void)titleButtonPressedFoPartner:(B2WProductMarketplacePartner *)partner
{
    if (![[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (self.delegate)
            {
                [self.delegate titleButtonPressedFoPartner:partner];
            }
        }];
    }
}

@end