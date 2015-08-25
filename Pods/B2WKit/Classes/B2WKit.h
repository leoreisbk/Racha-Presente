//
//  B2WKit.h
//  B2WKit
//
//  Created by Thiago Peres on 17/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#ifndef B2WKit_B2WKit_h
#define B2WKit_B2WKit_h

#import "B2WKitErrors.h"
#import "B2WKit-Constants.h"

// Networking
#import "B2WAPIClient.h"
#import "B2WAPICatalog.h"
#import "B2WAPICustomer.h"
#import "B2WAPIFreight.h"
#import "B2WAPIRecommendation.h"
#import "B2WAPIAccount.h"
#import "B2WAPIPush.h"
#import "B2WAPISearch.h"
#import "B2WAPIReviews.h"
#import "B2WAPIPostalCode.h"
#import "B2WAPIOffers.h"
#import "B2WAPICart.h"
#import "B2WAPICheckout.h"
#import "B2WAPIPayment.h"
#import "B2WAPIInstallment.h"
#import "B2WAPIPaymentInfo.h"
#import "B2WAPICart.h"
#import "B2WAPICheckout.h"

// Models
#import "B2WObject.h"
#import "B2WSearchResults.h"
#import "B2WDepartment.h"
#import "B2WDepartmentGroup.h"
#import "B2WFacet.h"
#import "B2WFacetItem.h"
#import "B2WImage.h"
#import "B2WProduct.h"
#import "B2WSKUInformation.h"
#import "B2WSpecification.h"
#import "B2WFreightCalculationResult.h"
#import "B2WFreightCalculationProduct.h"
#import "B2WReview.h"
#import "B2WReviewComment.h"
#import "B2WReviewResults.h"
#import "B2WCrossSellItem.h"
#import "B2WWishList.h"
#import "B2WWishListItem.h"
#import "B2WPlaceholderImage.h"
#import "B2WProductList.h"
#import "IDMTableViewContent.h"
#import "B2WAccountManager.h"
#import "B2WCustomer.h"
#import "B2WAddress.h"
#import "B2WCreditCard.h"
#import "B2WOneClickRelationship.h"
#import "B2WMarketplacePartner.h"
#import "B2WOffer.h"
#import "B2WDailyOffer.h"
#import "B2WProductOffer.h"
#import "B2WListingAttributes.h"
#import "B2WImageOffer.h"
#import "B2WProductOffer.h"
#import "B2WBreadcrumb.h"
#import "B2WDeeplink.h"
#import "B2WCartProduct.h"
#import "B2WCardValidator.h"
#import "B2WAddressValidator.h"
#import "B2WInstallment.h"
#import "B2WInstallmentProduct.h"
#import "B2WFreightProduct.h"
#import "B2WVoucher.h"

// Controllers
#import "B2WWishlistManager.h"
#import "B2WProductHistoryManager.h"
#import "B2WSearchHistoryManager.h"
#import "B2WCatalogController.h"
#import "B2WSearchController.h"
#import "B2WSearchDisplayController.h"
#import "B2WReviewsController.h"
#import "B2WCatalogParser.h"
#import "B2WCartURLProtocol.h"
#import "B2WCartAuthURLProtocol.h"
#import "B2WKitUtils.h"
#import "B2WValidatorConstants.h"
#import "B2WListingController.h"
#import "B2WCheckoutManager.h"

// Views
#import "B2WSegmentedControl.h"
#import "B2WProductCell.h"
#import "B2WNotificationSettingsTableViewCell.h"
#import "B2WCustomProductCell.h"

// View Controllers
#import "B2WProductListingViewController.h"
#import "B2WCatalogListingViewController.h"
#import "B2WSearchListingViewController.h"
#import "B2WOrdersViewController.h"
#import "B2WNotificationSettingsViewController.h"
#import "B2WProductDetailsViewController.h"
#import "B2WOfferWebBrowserViewController.h"
#import "B2WWebBrowserViewController.h"
#import "B2WCheckoutViewController.h"
#import "B2WSignUpCompletedViewController.h"
#import "B2WDebugSettingsTableViewController.h"
#import "B2WMarketplacePartnerTableViewController.h"
#import "B2WMarketplaceProductListingViewController.h"

// Protocols
#import "B2WPagingProtocol.h"

// Utils
#import "IDMUtils.h"

// Categories
#import "NSString+B2WKit.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"

static BOOL B2WUtilsIsDevelopmentBuild(void) {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    static BOOL isDevelopment = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // There is no provisioning profile in AppStore Apps.
        NSData *data = [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"embedded" ofType:@"mobileprovision"]];
        if (data) {
            const char *bytes = [data bytes];
            NSMutableString *profile = [[NSMutableString alloc] initWithCapacity:data.length];
            for (NSUInteger i = 0; i < data.length; i++) {
                [profile appendFormat:@"%c", bytes[i]];
            }
            // Look for debug value, if detected we're a development build.
            NSString *cleared = [[profile componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] componentsJoinedByString:@""];
            isDevelopment = [cleared rangeOfString:@"<key>get-task-allow</key><true/>"].length > 0;
        }
    });
    return isDevelopment;
#endif 
}

#endif

#pragma clang diagnostic pop
