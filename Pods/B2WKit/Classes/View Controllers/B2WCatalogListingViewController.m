//
//  B2WCatalogListingViewController.m
//  B2WKit
//
//  Created by Thiago Peres on 23/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WCatalogListingViewController.h"

// Controllers
#import "B2WCatalogController.h"
#import "B2WSegmentedControl.h"

@interface B2WCatalogListingViewController ()

@property (strong, nonatomic) NSNumber* previousSelectedSegmentedIndex;

@end


@implementation B2WCatalogListingViewController

- (void)viewDidLoad
{
    if (self.department)
    {
        self.pagingController = [[B2WCatalogController alloc] initWithDepartment:self.department
                                                                           order:B2WAPICatalogOrderAscending
                                                                            sort:B2WAPICatalogSortBestSellers
                                                                  resultsPerPage:kB2WDefaultNumberOfProductsPerPage];
    }
    else if (self.groups)
    {
        self.pagingController = [[B2WCatalogController alloc] initWithGroups:self.groups
                                                                       order:B2WAPICatalogOrderAscending
                                                                        sort:B2WAPICatalogSortBestSellers
                                                              resultsPerPage:kB2WDefaultNumberOfProductsPerPage];
        // TODO: remover quando estiver funcionando no catálogo
        self.shouldHideHeader = YES;
    }
    else if (self.tags)
    {
        self.pagingController = [[B2WCatalogController alloc] initWithTags:self.tags
                                                                     order:B2WAPICatalogOrderAscending
                                                                      sort:B2WAPICatalogSortBestSellers
                                                            resultsPerPage:kB2WDefaultNumberOfProductsPerPage];
        // TODO: remover quando estiver funcionando no catálogo
        self.shouldHideHeader = YES;
    }
    else if (self.productIdentifiers)
    {
        self.pagingController = [[B2WCatalogController alloc] initWithProductIdentifiers:self.productIdentifiers];
        self.shouldHideHeader = YES;
    }
    
    [super viewDidLoad];
    
    if (!self.shouldHideHeader)
    {
        B2WSegmentedControl *seg = self.sortingSegmentedControl;
        
        self.previousSelectedSegmentedIndex = [NSNumber numberWithInt:0];
        
        [seg removeAllSegments];
        [seg insertSegmentWithTitle:@"Mais Vendidos" atIndex:0 animated:NO];
        [seg insertSegmentWithTitle:@"▲ Nome" atIndex:1 animated:NO];
        [seg insertSegmentWithTitle:@"▲ Preço" atIndex:2 animated:NO];
        [seg setSelectedSegmentIndex:0];
        seg.center = seg.superview.center;
        [seg addTarget:self
                action:@selector(segmentedControlChanged:)
      forControlEvents:UIControlEventValueChanged];
    }
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
}

- (void)segmentedControlChanged:(UISegmentedControl*)seg
{
    NSString *title = [seg titleForSegmentAtIndex:seg.selectedSegmentIndex];
    B2WCatalogController *controller = (B2WCatalogController*)self.pagingController;
    
    if ([title isEqualToString:@"Mais Vendidos"])
    {
        [controller setSortType:B2WAPICatalogSortBestSellers];
        [controller setOrderType:B2WAPICatalogOrderAscending];
    }
    NSString *strippedTitle = [title stringByReplacingOccurrencesOfString:@"▲ " withString:@""];
    strippedTitle = [strippedTitle stringByReplacingOccurrencesOfString:@"▼ " withString:@""];
    
    if ([strippedTitle isEqualToString:@"Nome"])
    {
        if ([self.previousSelectedSegmentedIndex intValue] == seg.selectedSegmentIndex)
        {
            title = [title stringBySwappingArrows];
            
            [seg setTitle:title forSegmentAtIndex:seg.selectedSegmentIndex];
        }
        
        [controller setSortType:B2WAPICatalogSortName];
        [controller setOrderType:[title isAscending] ? B2WAPICatalogOrderAscending : B2WAPICatalogOrderDescending];
    }
    if ([strippedTitle isEqualToString:@"Preço"])
    {
        if ([self.previousSelectedSegmentedIndex intValue] == seg.selectedSegmentIndex)
        {
            title = [title stringBySwappingArrows];
            
            [seg setTitle:title forSegmentAtIndex:seg.selectedSegmentIndex];
        }
        
        [controller setSortType:B2WAPICatalogSortPrice];
        [controller setOrderType:[title isAscending] ? B2WAPICatalogOrderAscending : B2WAPICatalogOrderDescending];
    }
    
    [controller requestFirstPage];
    
    self.previousSelectedSegmentedIndex = @(seg.selectedSegmentIndex);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end