//
//  B2WMarketplaceProductPartnerCell.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "B2WProductMarketplacePartner.h"
#import <IDMAlertViewManager/IDMAlertViewManager.h>

@protocol B2WMarketplacePartnerCellProtocol <NSObject>

- (void)buyButtonPressedFoPartner:(B2WProductMarketplacePartner *)partner;
- (void)titleButtonPressedFoPartner:(B2WProductMarketplacePartner *)partner;

@end

@interface B2WMarketplaceProductPartnerCell : UITableViewCell

@property (nonatomic, assign) BOOL isFreightResultPartial;

@property (nonatomic, weak) IBOutlet UILabel *partnerName;
@property (nonatomic, weak) IBOutlet UILabel *productPrice;
@property (nonatomic, weak) IBOutlet UILabel *productInstallment;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loading;
@property (nonatomic, weak) IBOutlet UILabel *freightMessage;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;
@property (nonatomic, weak) IBOutlet UIImageView *infoImage;
@property (nonatomic, weak) IBOutlet UIButton *buyButton;
@property (nonatomic, weak) IBOutlet UIButton *freightMessageInfoButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonNameConstraint;
@property (readwrite, nonatomic) NSUInteger buttonNameConstraintOriginalValue;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelPriceConstraint;
@property (readwrite, nonatomic) CGFloat labelPriceConstraintOriginalValue;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelInstallmentConstraint;
@property (readwrite, nonatomic) NSUInteger labelInstallmentConstraintOriginalValue;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *freightMessageHeight;

@property (nonatomic, strong) NSString *freightResultErrorTitle;
@property (nonatomic, strong) NSString *freightResultErrorMessage;

@property (nonatomic, strong) B2WProductMarketplacePartner *partner;

@property (nonatomic, weak) id <B2WMarketplacePartnerCellProtocol> delegate;

+ (CGFloat)heigthForFreightMessageWithText:(NSString *)text forBrand:(NSString *)brand;

- (IBAction)buyButtonPressed;

- (IBAction)freightMessageInfoButtonPressed;

- (void)setPartner:(B2WProductMarketplacePartner *)partner forBrand:(NSString *)brand;

@end
