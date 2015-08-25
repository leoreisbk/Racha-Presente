//
//  B2WMarketplaceController.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WMarketplaceProductPartnerCell.h"
#import "B2WProductFreightCalculatorCell.h"
#import "B2WMarketplacePartner.h"
#import "B2WMarketplaceInformation.h"
#import "B2WFreightCalculationProduct.h"
#import "B2WProduct.h"

@interface B2WProduct (Marketplace)

@property (nonatomic, readonly) BOOL shouldDisplayMarketplacePartners;

- (NSString *)defaultPartnerForBrand:(NSString *)brand;

@end

@interface B2WMarketplaceController : NSObject

@property (nonatomic, assign) BOOL canShowFreightResult;
@property (nonatomic, assign) BOOL canShowFreightLoading;
@property (nonatomic, assign) BOOL canShowFullFreightResult;

@property (nonatomic, strong) B2WProduct *product;
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSMutableArray *fullPartnersArray;
@property (nonatomic, strong) NSMutableArray *fullSellerIdsArray;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSDictionary *freightResultDictionary;

- (id)initWithProduct:(B2WProduct *)product brand:(NSString *)brand;

- (B2WMarketplaceProductPartnerCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView withDelegate:(id)delegate;

- (void)changeStateOfMarketplaceProductPartnerCell:(B2WMarketplaceProductPartnerCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath isFormsheet:(BOOL)isFormsheet;

- (void)resetCalculateFreight;

- (void)beginCalculateFreight;

- (void)didLoadEstimateWithFreightResultDictionary:(NSDictionary *)freightResultDictionary;

- (void)setupMarketplaceInFreightCalculatorCell:(B2WProductFreightCalculatorCell *)cell;

+ (NSMutableAttributedString *)messageForFreightCalculationResult:(B2WFreightCalculationProduct *)freightResult;

+ (B2WProductMarketplacePartner *)featuredProductPartner:(B2WProduct *)product brandName:(NSString *)brandName;

@end
