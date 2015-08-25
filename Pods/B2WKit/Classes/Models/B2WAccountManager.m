//
//  B2WCustomerManager.m
//  B2WKit
//
//  Created by Eduardo Callado on 1/27/14.
//  Copyright (c) 2014 Eduardo Callado. All rights reserved.
//

#import "B2WAccountManager.h"

#import "B2WLoginMenuTableViewController.h"
#import "B2WSignUpCompletedViewController.h"
#import "B2WCustomerFormViewController.h"
#import "B2WAPIRecommendation.h"
#import "B2WKitUtils.h"
#import "IDMUtils.h"

#import <UICKeyChainStore/UICKeyChainStore.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface B2WAccountManager () <SignUpCompletedViewControllerDelegate>

@end

@implementation B2WAccountManager

#pragma mark - Shared Manager

+ (B2WAccountManager *)sharedManager
{
    static dispatch_once_t predManager;
    
    static B2WAccountManager *sharedManager = nil;
    
    dispatch_once(&predManager, ^{
        sharedManager = [B2WAccountManager new];
        
        sharedManager.brandName = @"B2W";
		sharedManager.oneClickBrandName = @"One Click";
		sharedManager.oneClickTitle = @"Bem-vindo ao B2WKit";
		
		sharedManager.isCreatingNewAccount = NO;
        sharedManager.shouldPresentOneClickActivationPopUpAfterSignUp = YES;
		
        sharedManager.individualCustomer = [B2WIndividualCustomer new];
        sharedManager.businessCustomer = [B2WBusinessCustomer new];
        sharedManager.address = [B2WAddress new];
        sharedManager.creditCard = [B2WCreditCard new];
        sharedManager.oneClick = [B2WOneClickRelationship new];
    });
    
    return sharedManager;
}

#pragma mark - Presentation

- (void)presentLoginViewController
{
    [self presentLoginViewControllerWithUserSignedInHandler:nil failedHandler:nil canceledHandler:nil];
}

- (void)presentLoginViewControllerWithUserSignedInHandler:(void (^)(void))userSignedInHandler failedHandler:(void (^)(void))userSignInFailedHandler canceledHandler:(void (^)(void))userSignInCanceledHandler
{
	if (kIsIpad)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DismissPopover" object:nil];
	}
	
	// self.presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kIsIphone ? @"B2WAccount_iPhone" : @"B2WAccount_iPad" bundle:[NSBundle B2WKitBundle]];
    B2WLoginMenuTableViewController *loginMenuController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    loginMenuController.userSignedInHandler = userSignedInHandler;
    loginMenuController.userSignInFailedHandler = userSignInFailedHandler;
    loginMenuController.userSignInCanceledHandler = userSignInCanceledHandler;
	[loginMenuController.view setBackgroundColor:[UIColor clearColor]];
	[[MZFormSheetController sharedBackgroundWindow] setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.5]];
	
	self.currentFormSheetController = [[MZFormSheetController alloc] initWithSize:CGSizeMake(320, 600) viewController:loginMenuController];
	[self.currentFormSheetController setTransitionStyle:MZFormSheetTransitionStyleSlideFromTop];
	[self.currentFormSheetController setPortraitTopInset:0];
	[self.currentFormSheetController presentAnimated:YES completionHandler:nil];
}

- (void)presentSignUpForm
{
	if (kIsIpad)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DismissPopover" object:nil];
	}
	
	void (^present)() = ^() {
        if (kIsIpad)
        {
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showSignUpForm) userInfo:nil repeats:NO];
        }
        else
        {
            [self showSignUpForm];
        }
	};
	
	// Tweak to make Login work while running on B2WKit
	if ([[B2WKitUtils mainAppDisplayName] isEqualToString:@"B2WKit"]) { present(); return; }
	
	if (self.currentFormSheetController)
	{
		[self.currentFormSheetController dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
			present();
		}];
	}
	else
	{
		present();
	}
}

- (void)showSignUpForm
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kIsIphone ? @"B2WAccount_iPhone" : @"B2WAccount_iPad"
                                                         bundle:[NSBundle B2WKitBundle]];
    
    UIViewController *topViewController = [B2WKitUtils topViewController];
    
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"CustomerViewController"];
    
    B2WCustomerFormViewController *customerFormViewController = (B2WCustomerFormViewController *) navigationController.viewControllers.firstObject;
    customerFormViewController.accountCreationDelegate = self.accountCreationDelegate;
    
    [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    [topViewController presentViewController:navigationController animated:YES completion:nil];
    
    [B2WAccountManager resetAccountSavedData];
    [[B2WAccountManager sharedManager] setIsCreatingNewAccount:YES];
}

- (void)presentSignUpCompletedViewController
{
	if (kIsIpad)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DismissPopover" object:nil];
	}
	
	void (^presentation)() = ^(){
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kIsIphone ? @"B2WAccount_iPhone" : @"B2WAccount_iPad" bundle:[NSBundle B2WKitBundle]];
		
		B2WSignUpCompletedViewController *OneClickController = [storyboard instantiateViewControllerWithIdentifier:@"SignUpCompletedViewController"];
		[OneClickController setDelegate:[B2WAccountManager sharedManager]];
		[OneClickController.view setBackgroundColor:[UIColor clearColor]];
		
		[[MZFormSheetController sharedBackgroundWindow] setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.5]];
		
		self.currentFormSheetController = [[MZFormSheetController alloc] initWithSize:CGSizeMake(320, kIsIpad ? 600 : 400)
																	   viewController:OneClickController];
		[self.currentFormSheetController setTransitionStyle:MZFormSheetTransitionStyleBounce];
		[self.currentFormSheetController presentAnimated:YES completionHandler:nil];
	};
	
	[[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
		presentation();
	}];
}

- (void)presentEditCustomerViewController
{
	if (kIsIpad)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DismissPopover" object:nil];
	}
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kIsIphone ? @"B2WAccount_iPhone" : @"B2WAccount_iPad"
														 bundle:[NSBundle B2WKitBundle]];
	
	UIViewController *presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
	
	UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"EditCustomerViewController"];
	[navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
	[presentingViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)presentAddressListViewController:(UINavigationController *)navigationController
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kIsIphone ? @"B2WAccount_iPhone" : @"B2WAccount_iPad"
														 bundle:[NSBundle B2WKitBundle]];
	UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AddressListViewController"];
	
	if (kIsIpad)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DismissPopover" object:nil];
		
		UIViewController *presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
		
		[viewController setModalPresentationStyle:UIModalPresentationFormSheet];
		[presentingViewController presentViewController:viewController animated:YES completion:nil];
	}
	else
	{
		[navigationController pushViewController:viewController animated:YES];
	}
}

- (void)presentCreditCardListViewController:(UINavigationController *)navigationController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kIsIphone ? @"B2WAccount_iPhone" : @"B2WAccount_iPad"
                                                         bundle:[NSBundle B2WKitBundle]];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"CreditCardListViewController"];
    
    if (kIsIpad)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissPopover" object:nil];
        
        UIViewController *presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        [viewController setModalPresentationStyle:UIModalPresentationFormSheet];
        [presentingViewController presentViewController:viewController animated:YES completion:nil];
    }
    else
    {
        [navigationController pushViewController:viewController animated:YES];
    }
}

- (void)presentOneClickViewController:(UINavigationController *)navigationController
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kIsIphone ? @"B2WAccount_iPhone" : @"B2WAccount_iPad"
														 bundle:[NSBundle B2WKitBundle]];
	UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"OneClickViewController"];
	
	if (kIsIpad)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DismissPopover" object:nil];
		
		UIViewController *presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
		
		[viewController setModalPresentationStyle:UIModalPresentationFormSheet];
		[presentingViewController presentViewController:viewController animated:YES completion:nil];
	}
	else
	{
		[navigationController pushViewController:viewController animated:YES];
	}
}

#pragma mark - SignUpCompletedViewController

- (void)SignUpCompletedViewControllerDidCancel:(B2WSignUpCompletedViewController *)controller
{
	[self.currentFormSheetController dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) { }];
}

- (void)SignUpCompletedViewControllerDidConfirm:(B2WSignUpCompletedViewController *)controller
{
	[self.currentFormSheetController dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kIsIphone ? @"B2WAccount_iPhone" : @"B2WAccount_iPad"
															 bundle:[NSBundle B2WKitBundle]];
		
		UIViewController *presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
		
		UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"CreditCardViewController"];
		[navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
		[presentingViewController presentViewController:navigationController animated:YES completion:nil];
	}];
}

#pragma mark - Login

+ (void)loginUserWithEmail:(NSString *)email password:(NSString *)password
{
	[B2WAPIAccount _loginWithUsername:email password:password block:^(id object, NSError *error) {
		if (error)
		{
			NSString *message;
			
			if ([error.localizedDescription isKindOfClass:[NSString class]])
			{
				message = error.localizedDescription;
			}
			else
			{
				NSDictionary *localizedDescription = (NSDictionary *)error.localizedDescription;
				
				NSMutableArray *validationErrors = [[NSMutableArray alloc] initWithArray:localizedDescription[@"validationErrors"]];
				
				if (validationErrors.count == 0)
				{
					if ([localizedDescription[@"errorCode"] isEqualToString:@"403"])
					{
						message = @"Email e senha não conferem.";
					}
					else
					{
						message = localizedDescription[@"message"];
					}
				}
				else
				{
					message = validationErrors[0][@"message"];
				}
			}
			
			if (error.code == -1011)
			{
				[UIAlertView showAlertViewWithTitle:@"Falha No Login" message:@"Por favor, tente novamente."];
			}
			else
			{
				[UIAlertView showAlertViewWithTitle:@"Falha No Login" message:message];
			}
			
			NSLog(@"error = %@", error.localizedDescription);
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"UserSignInFailed" object:nil];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"UserSignedIn" object:nil];
            
            [B2WAPIAccount updateB2WUID];
			
			[B2WAccountManager requestCustomerInformation];
            
//            [B2WAPISearch requestDesktopSearchHistoryWithBlock:^(id object, NSError *error) {
//                if (object) {
//                    NSArray *searchTermArray = (NSArray *) object;
//                    [B2WSearchHistoryManager addSearchTermArray:searchTermArray];
//                }
//            }];
		}
	}];
}

+ (AFHTTPRequestOperation *)refreshToken:(B2WAPICompletionBlock)block
{
	return [B2WAPIAccount _loginWithUsername:[B2WAPIAccount username] password:[B2WAPIAccount password] block:block];
}

+ (AFHTTPRequestOperation *)refreshTokenAndUpdateCartCustomer:(B2WAPICompletionBlock)block
{
	return [B2WAPIAccount _loginWithUsername:[B2WAPIAccount username] password:[B2WAPIAccount password] block:^(id object, NSError *error) {
		if (error)
		{
			if (block)
			{
				block(nil, error);
			}
		}
		[B2WCart updateCartWithCurrentLoggedInCustomerWithCompletion:^(id object, NSError *error) {
			if (block)
			{
				block(object, error);
			}
		}];
	}];
}

+ (void)requestCustomerInformation
{
	[B2WAccountManager requestCustomerInformationWithCompletion:nil failed:nil];
}

+ (void)requestCustomerInformationWithCompletion:(void (^)(void))completion
{
	[B2WAccountManager requestCustomerInformationWithCompletion:completion failed:nil];
}

+ (void)requestCustomerInformationWithCompletion:(void (^)(void))completion failed:(void (^)(void))failed
{
	[B2WAPICustomer requestWithMethod:@"GET" resource:B2WAPICustomerResourceNone resourceIdentifier:nil parameters:nil block:^(NSArray *object, NSError *error) {
		if (error)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"UserInfoFailed" object:nil];
			
			if (failed)
			{
				failed();
			}
		}
		else
		{
			B2WCustomer *customer = [object firstObject];
			[[B2WAccountManager sharedManager] setupCurrentCustomerInformation:customer];
			
			if (completion)
			{
				completion();
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"UserInfo" object:nil];
		}
	}];
}

- (void)showAccountAlertView
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Conta %@", [B2WAccountManager sharedManager].brandName]
														message:[B2WAPIAccount username]
													   delegate:self
											  cancelButtonTitle:@"Cancelar"
											  otherButtonTitles:@"Desconectar", nil];
	[alertView show];
}

#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[B2WAPIAccount logout];
		[B2WAccountManager resetAccountSavedData];
	}
}

#pragma mark - General

+ (B2WCustomer *)currentCustomer
{
	B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
    
    if (customerManager.customerType == CustomerTypeIndividual)
	{
		return customerManager.individualCustomer;
	}
	else
	{
		return customerManager.businessCustomer;
	}
}

+ (NSString *)currentCustomerCPF
{
	B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
	
	if (customerManager.customerType == CustomerTypeIndividual)
	{
		return customerManager.individualCustomer.cpf;
	}
	else
	{
		return nil;
	}
}

+ (NSString *)currentCustomerName
{
	B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
	
	if (customerManager.customerType == CustomerTypeIndividual)
	{
		return customerManager.individualCustomer.fullName;
	}
	else
	{
		return nil;
	}
}

+ (void)resetAccountSavedData
{
	B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
	customerManager.individualCustomer = [B2WIndividualCustomer new];
	customerManager.businessCustomer = [B2WBusinessCustomer new];
	customerManager.address = [B2WAddress new];
	customerManager.creditCard = [B2WCreditCard new];
	customerManager.oneClick = [B2WOneClickRelationship new];
	
	customerManager.customerType = CustomerTypeIndividual;
}

#pragma mark - Helpers

- (void)setupCurrentCustomerInformation:(B2WCustomer *)customer
{
    B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
    
    if ([customer isKindOfClass:[B2WIndividualCustomer class]])
    {
        customerManager.customerType = CustomerTypeIndividual;
		customerManager.individualCustomer = (B2WIndividualCustomer *)customer;
		
		customerManager.individualCustomer.password = [B2WAPIAccount password];
    }
    else
    {
        customerManager.customerType = CustomerTypeBusiness;
        customerManager.businessCustomer = (B2WBusinessCustomer *)customer;
		
		customerManager.businessCustomer.password = [B2WAPIAccount password];
    }
	
	// TODO: check if still need to set username here
	//[B2WAPIAccount setUsername:[B2WAccountManager currentCustomer].email];
}

- (void)setupCustomerWithEmptyValues
{
    B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
    
    if (customerManager.customerType == CustomerTypeIndividual)
    {
        customerManager.individualCustomer.email = @"";
        customerManager.individualCustomer.password = @"";
        customerManager.individualCustomer.fullName = @"";
        customerManager.individualCustomer.gender = B2WIndividualCustomerGenderMale;
        customerManager.individualCustomer.cpf = @"";
        customerManager.individualCustomer.mainPhone = @"";
        customerManager.individualCustomer.birthDate = @"";
        customerManager.individualCustomer.nickname = @"";
    }
    else
    {
        customerManager.businessCustomer.email = @"";
        customerManager.businessCustomer.corporateName = @"";
        customerManager.businessCustomer.responsibleName = @"";
        customerManager.businessCustomer.cnpj = @"";
        customerManager.businessCustomer.mainPhone = @"";
        customerManager.businessCustomer.password = @"";
        customerManager.businessCustomer.stateInscription = @"";
	}
}

- (void)setupAddressWithEmptyValues
{
	B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
	customerManager.address.name = @"";
	customerManager.address.address = @"";
	customerManager.address.number = @"";
	customerManager.address.recipientName = @"";
	customerManager.address.city = @"";
	customerManager.address.postalCode = @"";
	customerManager.address.additionalInfo = @"";
	customerManager.address.neighborhood = @"";
	customerManager.address.reference = @"";
}

+ (UIImage *)alertImage
{
	return [B2WKitUtils imageNamed:@"icn-alert"];
}

+ (UIImage *)cardImageName:(NSString *)name
{
	return [B2WKitUtils imageNamed:[NSString stringWithFormat:@"Cards/%@", name]];
}

+ (UIImage *)cardImageForBrand:(NSString *)brand
{
	if ([brand containsString:@"VISA"])
	{
		return [B2WKitUtils imageNamed:@"Cards/icn-card-visa@2x.png"];
	}
	else if ([brand containsString:@"MASTERCARD"])
	{
		return [B2WKitUtils imageNamed:@"Cards/icn-card-mastercard@2x.png"];
	}
	else if ([brand containsString:@"AMEX"])
	{
		return [B2WKitUtils imageNamed:@"Cards/icn-card-american@2x.png"];
	}
	else if ([brand containsString:@"DINERS"])
	{
		return [B2WKitUtils imageNamed:@"Cards/icn-card-diners@2x.png"];
	}
	else if ([brand containsString:@"AURA"])
	{
		return [B2WKitUtils imageNamed:@"Cards/icn-card-aura@2x.png"];
	}
	else if ([brand containsString:@"HIPERCARD"])
	{
		return [B2WKitUtils imageNamed:@"Cards/icn-card-hipercard@2x.png"];
	}
	
	return nil;
}

@end
