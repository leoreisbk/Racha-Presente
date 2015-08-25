//
//  B2WMarketplacePartnerTableViewController.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#define kACTIVITY_VIEW_TAG 789
#define kPRODUCT_SEGUE_IDENTIFIER @"Product"

#import "B2WMarketplacePartnerTableViewController.h"

#import "B2WAPICatalog.h"
#import "B2WPlaceholderImage.h"
// Cells
#import "B2WMarketplacePartnerTableViewCell.h"
#import "B2WSwipeViewCell_iPhone.h"

// View Controllers
#import "B2WMarketplaceProductListingViewController.h"

// Categories
#import <UIViewController+States.h>
#import <UIImageView+AFNetworking.h>

// Protocols
#import "B2WProductSelectorProtocol.h"

@interface B2WMarketplacePartnerTableViewController () <B2WProductSelectorProtocol>

@property (nonatomic, strong) B2WMarketplacePartner *partner;
@property (nonatomic, strong) B2WSwipeViewCell_iPhone *swipeViewCell;

@property (nonatomic, strong) NSMutableArray *partnerInfoArray;
@property (nonatomic, strong) NSArray *productsArray;

@property (nonatomic, strong) AFHTTPRequestOperation *marketplacePartnerRequestOperation;
@property (nonatomic, strong) AFHTTPRequestOperation *partnerProductsRequestOperation;

@end

@implementation B2WMarketplacePartnerTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.];
    
    CGRect loadingViewFrame = self.loadingView.frame;
    self.loadingView.frame  = CGRectMake(loadingViewFrame.origin.x, -40, loadingViewFrame.size.width, loadingViewFrame.size.height);
    
    if (self.marketplacePartnerName)
    {
        [self _requestMarketplacePartner];
        [self _requestProducts];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	
    if ([self isBeingDismissed] || [self isMovingFromParentViewController])
    {
        [self.marketplacePartnerRequestOperation cancel];
        [self.partnerProductsRequestOperation cancel];
    }
}

- (void)setMarketplacePartnerName:(NSString *)marketplacePartnerName
{
    _marketplacePartnerName = marketplacePartnerName;
    
    if (self.isViewLoaded)
    {
        [self _requestMarketplacePartner];
        [self _requestProducts];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ProductListing"])
    {
        B2WMarketplaceProductListingViewController *destination = segue.destinationViewController;
        destination.partner = self.partner;
    }
}

#pragma mark - Product Selector

- (void)didSelectProduct:(B2WProduct *)product sender:(id)sender
{
    [self performSegueWithIdentifier:kPRODUCT_SEGUE_IDENTIFIER sender:product];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.partnerInfoArray.count;
    }
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        B2WMarketplacePartnerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.titleLabel.text = self.partnerInfoArray[indexPath.row][@"title"];
        cell.textView.text = self.partnerInfoArray[indexPath.row][@"content"];
        
        return cell;
    }
    
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"header" forIndexPath:indexPath];
            cell.backgroundColor = tableView.backgroundColor;
            
            break;
        case 1:
            if (self.swipeViewCell == nil)
            {
                self.swipeViewCell = [tableView dequeueReusableCellWithIdentifier:@"SwipeViewCell"];
                self.swipeViewCell.marketplacePartnerName = self.marketplacePartnerName;
                self.swipeViewCell.products = self.productsArray;
                self.swipeViewCell.delegate = self;
                
                [self.swipeViewCell.swipeView reloadData];
                
                CGFloat halfSizeOfActivityView = self.activityView.frame.size.width / 2;
                self.activityView.frame = CGRectMake((self.view.frame.size.width / 2) - halfSizeOfActivityView, (self.swipeViewCell.contentView.frame.size.height / 2) - halfSizeOfActivityView, self.activityView.frame.size.width, self.activityView.frame.size.height);
                [self.swipeViewCell addSubview:self.activityView];
            }
            
            return self.swipeViewCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
		CGFloat width = self.view.frame.size.width - 20;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && ![[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
        {
            width = ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) ? 680. : 730.;
        }
        UITextView *dummyTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
		dummyTextView.font = [UIFont systemFontOfSize:14.0];
        dummyTextView.text = self.partnerInfoArray[indexPath.row][@"content"];
        
        CGSize size = [dummyTextView sizeThatFits:dummyTextView.frame.size];
        return size.height + 21;
    }
    
    if (indexPath.section == 1 && indexPath.row == 1)
    {
        return 214.f;
    }
    
    return 44.f;
}

#pragma mark - Private Methods

- (void)_requestProducts
{
	self.partnerProductsRequestOperation = [B2WAPICatalog requestProductsFromMarketplacePartnerWithName:self.marketplacePartnerName order:B2WAPICatalogOrderAscending sort:B2WAPICatalogSortBestSellers page:0 resultsPerPage:10 block:^(id object, NSError *error) {
		if (error)
		{
			DLog(@"%@", error);
			
			if (error.code != NSURLErrorCancelled)
			{
				NSString *title = kDefaultErrorTitle;
				NSString *message = kDefaultErrorMessage;
				
				if (error.code != kCFURLErrorNotConnectedToInternet)
				{
					if (error.code == kCFURLErrorTimedOut || error.code == kCFURLErrorUnsupportedURL || error.code == kCFURLErrorCannotFindHost)
					{
						title = kLoadProductErrorTitle;
						message = kLoadProductErrorMessage;
					}
				}
				else
				{
					title = kDefaultConnectionErrorTitle;
					message = kDefaultConnectionErrorMessage;
				}
			}
		}
		else
		{
			self.productsArray = object;
			
			if (self.swipeViewCell)
			{
				self.swipeViewCell.products = object;
				[self.activityView removeFromSuperview];
				[self.swipeViewCell.swipeView reloadData];
			}
		}
	}];
}

- (void)_setupMarketplacePartner
{
    __weak __block UIImageView *weakLogoImageView = self.logo;
    __weak __block B2WMarketplacePartnerTableViewController *weakSelf = self;
    [self.logo setImageWithURLRequest:[NSURLRequest requestWithURL:self.partner.logoURL]
                     placeholderImage:[B2WPlaceholderImage image]
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  if (image)
                                  {
                                      weakLogoImageView.image = image;
                                      [weakSelf showHeaderViewImage];
                                      [weakSelf.tableView reloadData];
                                  }
                                  else
                                  {
                                      [weakSelf hideHeaderView];
                                  }
                              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  [weakSelf hideHeaderView];
                              }];
	
    self.partnerInfoArray = [NSMutableArray new];
    if (self.partner.aboutStore != nil && self.partner.aboutStore.length > 0)
    {
        [self.partnerInfoArray addObject:@{@"title": @"Sobre a Loja", @"content": self.partner.aboutStore}];
    }
	
    if (self.partner.deliveryPolicy != nil && self.partner.deliveryPolicy.length > 0)
    {
        [self.partnerInfoArray addObject:@{@"title": @"Entrega", @"content": self.partner.deliveryPolicy}];
    }
	
    if (self.partner.returnPolicy != nil && self.partner.returnPolicy.length > 0)
    {
        [self.partnerInfoArray addObject:@{@"title": @"Devolução", @"content": self.partner.returnPolicy}];
    }
	
    if (self.partner.CNPJ != nil && self.partner.CNPJ.length > 0)
    {
        [self.partnerInfoArray addObject:@{@"title": @"CNPJ", @"content": self.partner.CNPJ}];
    }
	
    if (self.partner.address != nil && self.partner.address.length > 0)
    {
        [self.partnerInfoArray addObject:@{@"title": @"Endereço", @"content": self.partner.address}];
    }
	
    [self.tableView reloadData];
}

- (void)showHeaderViewImage
{
    self.logo.alpha = 0.f;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.logo.alpha = 1.f;
    } completion:nil];
}

- (void)hideHeaderView
{
    self.logo.hidden = YES;
    CGRect newRect = CGRectMake(0, 0, self.view.frame.size.width, 20);
    UIView *newHeaderView = self.tableView.tableHeaderView;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        newHeaderView.frame = newRect;
        self.tableView.tableHeaderView = newHeaderView;
    }];
}

- (void)_requestMarketplacePartner
{
    self.title = self.marketplacePartnerName;
	
    [self.loadingView show];
    self.tableView.userInteractionEnabled = NO;
    self.marketplacePartnerRequestOperation = [B2WAPICatalog requestMarketplacePartnerByName:self.marketplacePartnerName block:^(id object, NSError *error) {
        [self.loadingView dismiss];
        self.tableView.userInteractionEnabled = YES;
		
        if (error)
        {
            DLog(@"%@", error);
			
            if (error.code != NSURLErrorCancelled)
            {
                NSString *title = kDefaultErrorTitle;
                NSString *message = kDefaultErrorMessage;
                
                if (error.code != kCFURLErrorNotConnectedToInternet)
                {
                    if (error.code == kCFURLErrorTimedOut || error.code == kCFURLErrorUnsupportedURL || error.code == kCFURLErrorCannotFindHost)
                    {
                        title = kLoadProductErrorTitle;
                        message = kLoadProductErrorMessage;
                    }
                }
                else
                {
                    title = kDefaultConnectionErrorTitle;
                    message = kDefaultConnectionErrorMessage;
                }
                
                [self.contentUnavailableView showWithTitle:title message:message buttonTitle:@"Tentar novamente" reloadButtonPressedBlock:^()
                 {
                     [self.contentUnavailableView dismiss];
                     [self _requestMarketplacePartner];
                 }];
            }
        }
        else
        {
            self.partner = object;
            [self _setupMarketplacePartner];
        }
    }];
}

+ (B2WProductMarketplacePartner *)productMarketplacePartnerWithName:(NSString *)name inPartners:(NSArray *)partners
{
    for (B2WProductMarketplacePartner *productPartner in partners)
    {
        if( [productPartner.name caseInsensitiveCompare:name] == NSOrderedSame )
        {
            return productPartner;
        }
    }
    return nil;
}

@end