//
//  B2WCustomerManager.h
//  B2WKit
//
//  Created by Eduardo Callado on 1/27/14.
//  Copyright (c) 2014 Eduardo Callado. All rights reserved.
//

#import "B2WObject.h"

#import "B2WKit.h"
#import "B2WAPIAccount.h"
#import "B2WIndividualCustomer.h"
#import "B2WBusinessCustomer.h"

#import <MZFormSheetController/MZFormSheetController.h>

typedef NS_ENUM(NSInteger, CustomerType) {
    CustomerTypeIndividual,
    CustomerTypeBusiness
};

@protocol B2WAccountCreationDelegate <NSObject>

- (void)addressSelected;

@end

@interface B2WAccountManager : B2WObject

+ (B2WAccountManager *)sharedManager;

// Main App Information
@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) UIColor *appPrimaryColor;
@property (nonatomic, strong) UIColor *appSecondaryColor;
@property (nonatomic, strong) UIColor *appThirdColor;
@property (nonatomic, strong) UIColor *appLoadingColor;
@property (nonatomic, strong) UIColor *appTextColor;
@property (nonatomic, strong) NSString *oneClickBrandName;
@property (nonatomic, strong) UIImage *oneClickBackgroundImage;
@property (nonatomic, strong) NSString *oneClickTitle;

// Sign Up
@property (nonatomic, assign) BOOL isCreatingNewAccount;
@property (nonatomic, assign) BOOL shouldPresentOneClickActivationPopUpAfterSignUp;
@property (nonatomic, weak) id<B2WAccountCreationDelegate> accountCreationDelegate;

// Customer
@property (nonatomic) CustomerType customerType;
@property (nonatomic, strong) B2WIndividualCustomer *individualCustomer;
@property (nonatomic, strong) B2WBusinessCustomer *businessCustomer;
@property (nonatomic, strong) B2WAddress *address;
@property (nonatomic, strong) B2WCreditCard *creditCard;
@property (nonatomic, strong) B2WOneClickRelationship *oneClick;

// Controllers
@property (nonatomic, strong) MZFormSheetController *currentFormSheetController;

// Sign Up
+ (void)loginUserWithEmail:(NSString *)email password:(NSString *)password;
- (void)showAccountAlertView;
- (void)showSignUpForm;

// Sign Up Helpers
- (void)setupCurrentCustomerInformation:(B2WCustomer *)customer;
- (void)setupCustomerWithEmptyValues;
- (void)setupAddressWithEmptyValues;

// Customer
+ (B2WCustomer *)currentCustomer;
+ (NSString *)currentCustomerCPF;
+ (NSString *)currentCustomerName;
+ (void)requestCustomerInformation;
+ (void)requestCustomerInformationWithCompletion:(void (^)(void))completion;
+ (void)requestCustomerInformationWithCompletion:(void (^)(void))completion failed:(void (^)(void))failed;
+ (void)resetAccountSavedData;

// Presentations
- (void)presentLoginViewController;
- (void)presentLoginViewControllerWithUserSignedInHandler:(void (^)(void))userSignedInHandler
											failedHandler:(void (^)(void))userSignInFailedHandler
										  canceledHandler:(void (^)(void))userSignInCanceledHandler;
- (void)presentSignUpForm;
- (void)presentSignUpCompletedViewController;
- (void)presentEditCustomerViewController;
- (void)presentAddressListViewController:(UINavigationController *)navigationController;
- (void)presentCreditCardListViewController:(UINavigationController *)navigationController;
- (void)presentOneClickViewController:(UINavigationController *)navigationController;

// Images
+ (UIImage *)alertImage;
+ (UIImage *)cardImageName:(NSString *)name;
+ (UIImage *)cardImageForBrand:(NSString *)brand;

// Token
+ (AFHTTPRequestOperation *)refreshToken:(B2WAPICompletionBlock)block;
+ (AFHTTPRequestOperation *)refreshTokenAndUpdateCartCustomer:(B2WAPICompletionBlock)block;

@end
