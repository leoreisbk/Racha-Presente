//
//  B2WSearchListingViewController.m
//  B2WKit
//
//  Created by Thiago Peres on 23/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WSearchListingViewController.h"
#import "B2WSearchController.h"
#import "B2WSegmentedControl.h"

@interface B2WSearchListingViewController ()

@property (strong, nonatomic) NSNumber* previousSelectedSegmentedIndex;

@end

@implementation B2WSearchListingViewController

- (void)viewDidLoad
{
    self.pagingController = [[B2WSearchController alloc] initWithQuery:self.searchQuery
                                                        resultsPerPage:kB2WDefaultNumberOfProductsPerPage
                                                              sortType:B2WAPISearchSortRelevance];
    
    [super viewDidLoad];
    
    B2WSegmentedControl *seg = self.sortingSegmentedControl;
    self.previousSelectedSegmentedIndex = [NSNumber numberWithInt:0];
    //
    //▲ ▼ special arrow characters
    //
    [seg removeAllSegments];
    [seg setApportionsSegmentWidthsByContent:YES];
    [seg insertSegmentWithTitle:@"Relevância" atIndex:0 animated:NO];
    [seg insertSegmentWithTitle:@"+ Vendidos" atIndex:1 animated:NO];
    [seg insertSegmentWithTitle:@"+ Avaliados" atIndex:2 animated:NO];
    [seg insertSegmentWithTitle:@"▲ Preço" atIndex:3 animated:NO];
    [seg setSelectedSegmentIndex:0];
    seg.center = seg.superview.center;
    [seg addTarget:self
            action:@selector(segmentedControlChanged:)
  forControlEvents:UIControlEventValueChanged];
}

- (void)segmentedControlChanged:(UISegmentedControl*)seg
{
    NSString *title = [seg titleForSegmentAtIndex:seg.selectedSegmentIndex];
    B2WSearchController *controller = (B2WSearchController*)self.pagingController;
    
    if ([title isEqualToString:@"Relevância"])
    {
        [controller setSortType:B2WAPISearchSortRelevance];
    }
    if ([title isEqualToString:@"+ Vendidos"])
    {
        [controller setSortType:B2WAPISearchSortBestSellers];
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
        [controller setSortType:[title isAscending] ? B2WAPISearchSortNameAscending : B2WAPISearchSortNameDescending];
    }
    if ([strippedTitle isEqualToString:@"Preço"])
    {
        if ([self.previousSelectedSegmentedIndex intValue] == seg.selectedSegmentIndex)
        {
            title = [title stringBySwappingArrows];
            
            [seg setTitle:title forSegmentAtIndex:seg.selectedSegmentIndex];
        }
        [controller setSortType:[title isAscending] ? B2WAPISearchSortPriceAscending : B2WAPISearchSortPriceDescending];
    }
    if ([strippedTitle isEqualToString:@"+ Avaliados"])
    {
        [controller setSortType:B2WAPISearchSortBestRated];
    }
    
    self.previousSelectedSegmentedIndex = @(seg.selectedSegmentIndex);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
