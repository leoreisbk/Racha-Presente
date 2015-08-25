//
//  B2WProductListingViewController.m
//
//
//  Created by Thiago Peres on 22/11/13.
//
//

#define kHeaderViewTag    199999
#define kNoResultsViewTag 299999

#import "B2WProductListingViewController.h"

// Views
#import "B2WSegmentedControl.h"

// Models
#import "B2WSearchResults.h"
#import "B2WProduct.h"

// Cells
#import "B2WProductCell.h"

// Controllers
#import <SVPullToRefresh/SVPullToRefresh.h>

// Networking
#import <AFNetworking.h>

NSString *const kHeaderViewReuseIdentifier = @"Header";

@implementation NSString (productListingUtils)

- (BOOL)isAscending
{
    return [self characterAtIndex:0] == [@"▲" characterAtIndex:0];
}

- (NSString*)stringBySwappingArrows
{
    if ([self characterAtIndex:0] == [@"▲" characterAtIndex:0])
    {
        return [self stringByReplacingOccurrencesOfString:@"▲" withString:@"▼"];
    }
    return [self stringByReplacingOccurrencesOfString:@"▼" withString:@"▲"];
}

@end

#pragma mark - Product Listing Header View

@interface B2WProductListingHeaderView : UICollectionReusableView

@property (nonatomic, weak) UISegmentedControl *segmentedControl;

@end

@implementation B2WProductListingHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

- (void)setSegmentedControl:(UISegmentedControl *)segmentedControl
{
    if (![self viewWithTag:kHeaderViewTag])
    {
        segmentedControl.tag = kHeaderViewTag;
        [self addSubview:segmentedControl];
        
        segmentedControl.center = self.center;
    }
    _segmentedControl = segmentedControl;
}

@end

#pragma mark - Product Listing View Controller

static UIColor *_selectedProductBorderColor;
static CGFloat _selectedProductBorderWidth;
@interface B2WProductListingViewController () <UIScrollViewDelegate>

@property (nonatomic, strong  ) NSMutableArray             *internalProducts;
@property (nonatomic, strong  ) NSString                   *reuseIdentifier;
@property (nonatomic, readonly) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, weak) B2WProduct *previousSelectedProduct;
@property (nonatomic, weak) B2WProductCell *previousSelectedProductCell;

@end

@implementation B2WProductListingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.internalProducts = [NSMutableArray array];
    
    if (self.productCellNib)
    {
        [self.collectionView registerNib:self.productCellNib forCellWithReuseIdentifier:self.reuseIdentifier];
    }
    
    [self.pagingController requestFirstPage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __weak __block B2WProductListingViewController *weakSelf = self;
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        if ([weakSelf.pagingController hasMoreResults])
        {
            [weakSelf.pagingController requestNextPage];
        }
        else
        {
            [weakSelf.collectionView setShowsInfiniteScrolling:NO];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self isBeingDismissed] || [self isMovingFromParentViewController])
    {
        if ([self.pagingController currentRequestOperation]) {
            [[self.pagingController currentRequestOperation] cancel];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // [self removeProductSelectionBorder];
}

#pragma mark - Public Methods

- (NSArray *)products
{
    return self.internalProducts;
}

- (void)setPagingController:(id<B2WPagingProtocol>)pagingController
{
    _pagingController = pagingController;
    [_pagingController setDelegate:self];
}

- (void)loadView
{
    [super loadView];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame
                                             collectionViewLayout:[B2WProductListingViewController _defaultFlowLayout]];
    
    if (!self.shouldHideHeader)
    {
        self.sortingSegmentedControl = [[B2WSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 300, 33)];
        
        [self.collectionView registerClass:[B2WProductListingHeaderView class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                       withReuseIdentifier:kHeaderViewReuseIdentifier];
    }
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.collectionView];
}

- (void)setProductCellNib:(UINib *)productCellNib
{
    _productCellNib = productCellNib;
    
    self.reuseIdentifier = [B2WProductListingViewController reuseIdentifierForProductCellNib:productCellNib];
    
    if (self.reuseIdentifier == nil || self.reuseIdentifier.length <= 0)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Product cell nib must pass a valid non nil, non-empty reuse identifier."];
    }
    
    [self.collectionView registerNib:productCellNib
          forCellWithReuseIdentifier:self.reuseIdentifier];
}

- (void)removeProductSelectionBorder
{
    // [self.previousSelectedProductCell removeSelectionBorder];
    
    self.previousSelectedProductCell = nil;
    self.previousSelectedProduct     = nil;
}

#pragma mark - Class Methods

+ (NSString*)reuseIdentifierForProductCellNib:(UINib*)nib
{
    UICollectionViewCell *cell = [[nib instantiateWithOwner:self options:nil] firstObject];
    
    if (![cell isKindOfClass:[UICollectionViewCell class]])
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"The provided nib does not contain an object of the  UICollectionViewCell class kind, %@ class instead.", NSStringFromClass(cell.class)];
    }
    
    return cell.reuseIdentifier;
}

+ (void)setSelectedProductBorderColor:(UIColor *)color
{
    _selectedProductBorderColor = color;
}

+ (void)setSelectedProductBorderWidth:(CGFloat)width
{
    _selectedProductBorderWidth = width;
}

#pragma mark - B2WPagingResults Delegate

- (void)didLoadResults:(id)results error:(NSError *)error page:(NSUInteger)page
{
    [self.collectionView.infiniteScrollingView stopAnimating];
    
    if (page == 0)
    {
        [self.internalProducts removeAllObjects];
        [self.collectionView setShowsInfiniteScrolling:YES];
    }
    
    NSArray *products;
    if ([results isKindOfClass:[B2WSearchResults class]])
    {
        products = [(B2WSearchResults*)results products];
    }
    else
    {
        products = results;
    }
    
    //
    // Adds 'No Results' view when
    // the controller returns no results
    if (page == 0 &&
        products.count == 0 &&
        self.delegate &&
        [self.delegate respondsToSelector:@selector(viewForNoResults)])
    {
        UIView *view = [self.view viewWithTag:kNoResultsViewTag];
        
        if (view == nil)
        {
            UIView *noResultsView = [self.delegate viewForNoResults];
            noResultsView.center = self.view.center;
            noResultsView.tag = kNoResultsViewTag;
            
            [self.view addSubview:noResultsView];
        }
    }
    //
    // Removes it when new results get loaded
    //
    else if (page == 0 && products.count > 0)
    {
        UIView *view = [self.view viewWithTag:kNoResultsViewTag];
        
        if (view)
        {
            [view removeFromSuperview];
        }
    }
    
    [self.internalProducts addObjectsFromArray:products];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.internalProducts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    B2WProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier
                                                                     forIndexPath:indexPath];
    
    cell.product = self.internalProducts[indexPath.row];
    
    if ([cell.product.identifier isEqualToString:self.previousSelectedProduct.identifier])
    {
        self.previousSelectedProductCell = cell;
        // [cell addSelectionBorder];
    }
    else
    {
        // [cell removeSelectionBorder];
    }
    
    return (UICollectionViewCell*)cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    B2WProductListingHeaderView *header;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && (indexPath.section == 0))
    {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:kHeaderViewReuseIdentifier
                                                           forIndexPath:indexPath];
        
        if (self.shouldHideHeader) {
            header.frame = CGRectZero;
        }
        else {
            [header setSegmentedControl:self.sortingSegmentedControl];
        }
    }
    
    return header;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    B2WProductCell *cell = (B2WProductCell *)[collectionView cellForItemAtIndexPath:indexPath];
    // [self _addSelectionBorderToView:cell];
    
    if (self.delegate)
    {
        [self.delegate didSelectProduct:cell.product sender:cell];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return self.shouldHideHeader ? CGSizeMake(0, 0) : CGSizeMake(0, 44.0f);
}

#pragma mark - Private Methods

+ (UICollectionViewFlowLayout*)_defaultFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(158, 190)];
    [layout setMinimumInteritemSpacing:4];
    [layout setMinimumLineSpacing:4];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    return layout;
}

- (void)_addSelectionBorderToView:(B2WProductCell *)view
{
    // [self.previousSelectedProductCell removeSelectionBorder];
    
    self.previousSelectedProduct = view.product;
    self.previousSelectedProductCell = view;
    // [self.previousSelectedProductCell addSelectionBorder];
}

@end