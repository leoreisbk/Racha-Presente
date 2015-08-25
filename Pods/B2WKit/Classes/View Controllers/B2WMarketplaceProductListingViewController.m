//
//  B2WMarketplaceProductListingViewController.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#define kPRODUCT_SEGUE_IDENTIFIER @"Product"

// View Controllers
#import "B2WMarketplaceProductListingViewController.h"

// Controllers
#import "B2WMarketplaceProductsPagingController.h"
#import "B2WCollectionViewFlowLayoutProvider.h"
#import <IDMAlertViewManager/IDMAlertViewManager.h>

// Categories
#import <UIViewController+States.h>

@interface B2WMarketplaceHeaderView : UICollectionReusableView @end
@implementation B2WMarketplaceHeaderView @end


@interface B2WMarketplaceProductListingViewController () <UISearchBarDelegate, B2WProductListingDelegate>

@property (assign, nonatomic) BOOL isSearchResult;

@end


@implementation B2WMarketplaceProductListingViewController

- (void)viewDidLoad
{
    [self setupViewForOrientation];
    
    self.pagingController = [[B2WMarketplaceProductsPagingController alloc] initWithPartnerName:self.partner.name
                                                                                          query:nil
                                                                                 resultsPerPage:kB2WDefaultNumberOfProductsPerPage
                                                                                       sortType:B2WAPICatalogSortBestSellers];
    
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.000];
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.collectionView registerClass:[B2WMarketplaceHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.placeholder = [NSString stringWithFormat:@"Busque dentro da loja %@", self.partner.name];
    
    [self.loadingView show];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupViewForOrientation];
}

- (void)setupViewForOrientation
{
    self.searchBarWidthConstraint.constant = [self searchBarWidth];
    [self.collectionView reloadData];
}

- (CGFloat )searchBarWidth
{
    CGFloat searchBarWidth = self.view.bounds.size.width;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
        {
            searchBarWidth = 345.;
        }
        else
        {
            searchBarWidth = 410.;
        }
    }
    return searchBarWidth;
}

- (void)didLoadResults:(id)results error:(NSError *)error page:(NSUInteger)page
{
    [super didLoadResults:results error:error page:page];
    
    if (error)
    {
        if (page == 0)
        {
            if (self.isSearchResult)
            {
                [IDMAlertViewManager showAlertWithTitle:@"Não Há Resultados"
                                                message:[NSString stringWithFormat:@"Sua busca por \"%@\" não retornou nenhum resultado.", self.searchBar.text]
                                               priority:IDMAlertPriorityMedium
                                                success:^(NSUInteger selectedIndex) {
                                                    
                                                    [self.searchBar becomeFirstResponder];
                                                    
                                                } failure:nil];
            }
            else
            {
                [self.contentUnavailableView showWithTitle:kDefaultConnectionErrorTitle
                                                   message:kDefaultConnectionErrorMessage
                                  reloadButtonPressedBlock:^{
                                      [self.contentUnavailableView dismiss];
                                      [self.loadingView show];
                                      
                                      [self.pagingController requestFirstPage];
                                  }];
            }
        }
        else
        {
            [IDMAlertViewManager showDefaultConnectionFailureAlert];
        }
    }
    
    
    if (page == 0)
    {
        [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
    
    [self.loadingView dismiss];
}

#pragma mark - UI Actions

- (IBAction)didChangeSegmentedControl:(UISegmentedControl *)sender
{
    self.isSearchResult = NO;
    
    B2WMarketplaceProductsPagingController *pagingController = (B2WMarketplaceProductsPagingController *)self.pagingController;
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            pagingController.sortType = B2WAPICatalogSortName;
            pagingController.orderType = B2WAPICatalogOrderAscending;
            
            break;
            
        case 1:
            pagingController.sortType = B2WAPICatalogSortBestSellers;
            pagingController.orderType = B2WAPICatalogOrderAscending;
            
            break;
            
        case 2:
            pagingController.sortType = B2WAPICatalogSortName;
            pagingController.orderType = B2WAPICatalogOrderDescending;
            
            break;
            
        default:
            break;
    }
    
    [self.loadingView show];
    [pagingController requestFirstPage];
}

#pragma mark - Product Listing

- (void)didSelectProduct:(B2WProduct *)product sender:(id)sender
{
    [self performSegueWithIdentifier:kPRODUCT_SEGUE_IDENTIFIER sender:product];
}

#pragma mark - Collection View

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    B2WMarketplaceHeaderView *headerView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Header" forIndexPath:indexPath];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            CGRect headerFrame = CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y, self.view.frame.size.width, self.headerView.frame.size.height);
            self.headerView.frame = headerFrame;
        }
        [headerView addSubview:self.headerView];
    }
    
    return headerView;
}

#pragma mark - Search Bar

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    B2WMarketplaceProductsPagingController *pagingController = (B2WMarketplaceProductsPagingController *)self.pagingController;
    pagingController.query = nil;
    searchBar.showsCancelButton = NO;
    
    [self.loadingView show];
    [pagingController requestFirstPage];
    
    searchBar.text = nil;
    
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.isSearchResult = YES;
    B2WMarketplaceProductsPagingController *pagingController = (B2WMarketplaceProductsPagingController *)self.pagingController;
    pagingController.query = searchBar.text;
    searchBar.showsCancelButton = YES;
    
    [self.loadingView show];
    [pagingController requestFirstPage];
    
    [searchBar resignFirstResponder];
}

@end