//
//  B2WProductListingViewController.h
//
//  Created by Thiago Peres on 22/11/13.
//
//

#import <UIKit/UIKit.h>

#import "B2WPagingProtocol.h"

@class B2WSegmentedControl;


@interface NSString (productListingUtils)

- (BOOL)isAscending;
- (NSString*)stringBySwappingArrows;

@end

@class B2WProduct;

@protocol B2WProductListingDelegate <NSObject>
@optional

/**
 *  Tells the delegate that the specified product is now selected.
 *
 *  @param product The selected product object.
 *  @param sender  The object that originated the event.
 */
- (void)didSelectProduct:(B2WProduct*)product sender:(id)sender;

/**
 *  Asks the delegate to provide a view when there are no results
 *  to show.
 *
 *  @return A configured no results view object.
 */
- (UIView*)viewForNoResults;

@end


@interface B2WProductListingViewController : UIViewController <B2WPagingResultsDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

/**
 *  The product listing's paging controller object. This controller is
 *  responsible for loading products from a data source and must conform
 *  to the B2WPagingProtocol. Therefore, you should always provide a
 *  paging controller.
 */
@property (nonatomic, strong) id <B2WPagingProtocol> pagingController;

/**
 *  The product listing's delegate.
 */
@property (nonatomic, weak) id <B2WProductListingDelegate> delegate;

/**
 *  Returns an array containing the products currently being shown.
 *  Cell object must conform to the B2WProductCellProtocol.
 */
@property (nonatomic, readonly) NSArray *products;

/**
 *  Registers a nib object containing a product cell.
 */
@property (nonatomic, strong) UINib *productCellNib;

/**
 *  The collection view managed by the controller object.
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 *  The segmented control managed by the controller object.
 */
@property (nonatomic, strong) B2WSegmentedControl *sortingSegmentedControl;

/**
 *  Flag to show or hide header.
 */
@property (nonatomic, assign) BOOL shouldHideHeader;

/**
 *  Removes the border from the selected product.
 */
- (void)removeProductSelectionBorder;

@end