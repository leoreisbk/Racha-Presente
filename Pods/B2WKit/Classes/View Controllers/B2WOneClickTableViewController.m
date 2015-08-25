//
//  B2WOneClickTableViewController.m
//  B2WKit
//
//  Created by Caio Mello on 29/10/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WOneClickTableViewController.h"

#import "UIViewController+States.h"

#import "B2WAccountManager.h"
#import "B2WAddress.h"
#import "B2WCreditCard.h"
#import "B2WAddressValidator.h"
#import "B2WCardValidator.h"

@interface B2WOneClickTableViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *OneClickLabel;

@property (nonatomic, strong) IBOutlet UISwitch *activationSwitch;

@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UILabel *cityStateLabel;
@property (nonatomic, strong) IBOutlet UILabel *postalCodeLabel;

@property (nonatomic, strong) IBOutlet UIImageView *cardFlagImageView;
@property (nonatomic, strong) IBOutlet UILabel *cardNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *cardNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *cardExpirationLabel;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) B2WAddress *address;
@property (nonatomic, strong) B2WCreditCard *creditCard;

@end

@implementation B2WOneClickTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[self.activityIndicator setColor:[B2WAccountManager sharedManager].appLoadingColor];
	
	UIBarButtonItem *loadingBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
	[self.navigationItem setRightBarButtonItem:loadingBarItem];
	
	self.title = [B2WAccountManager sharedManager].oneClickBrandName;

	self.OneClickLabel.text = [B2WAccountManager sharedManager].oneClickBrandName;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ([B2WAccountManager currentCustomer].oneClickEnabled)
	{
		[self.activationSwitch setOn:YES];
		
		[self requestOneClick];
	}
	else
	{
		[self.activationSwitch setOn:NO];
	}
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (self.address && self.creditCard)
	{
		return 3;
	}
	else if (self.address || self.creditCard)
	{
		return 2;
	}
	
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section == 0 && ![B2WAccountManager currentCustomer].oneClickEnabled)
	{
		return [NSString stringWithFormat:@"Selecione um endereço de entrega e cadastre o seu cartão de crédito para ativar %@.", [B2WAccountManager sharedManager].oneClickBrandName];
	}
	
	return nil;
}

#pragma mark - Networking

- (void)requestOneClick
{
	[self.activityIndicator startAnimating];
	
	[[B2WAccountManager currentCustomer] requestOneClickRelationshipsWithBlock:^(id object, NSError *error) {
		if (error)
		{
			[self.activityIndicator stopAnimating];
			
			NSString *title   = kDefaultConnectionErrorTitle;
			NSString *message = kDefaultConnectionErrorMessage;
			
			[self.contentUnavailableView showWithTitle:title message:message buttonTitle:@"Tentar novamente" reloadButtonPressedBlock:^() {
				[self.contentUnavailableView dismiss];
				//[self.loadingView show];
				[self requestOneClick];
			}];
		}
		else
		{
			if ([object count])
			{
				B2WOneClickRelationship *oneClick = [object firstObject];
				[B2WAccountManager sharedManager].oneClick = oneClick;
				
				[self.activationSwitch setOn:YES];
				
				[[self.tableView footerViewForSection:0].textLabel setText:nil];
				[self.tableView beginUpdates];
				[self.tableView endUpdates];
				
				[self requestAddress:oneClick.addressIdentifier];
				[self requestCredtCard:oneClick.creditCardIdentifier];
			}
			else
			{
				[self.activationSwitch setOn:NO];
				[self.activityIndicator stopAnimating];
			}
		}
	}];
}

- (void)requestAddress:(NSString *)identifier
{
	[self.activityIndicator startAnimating];
	
	[B2WAPICustomer requestWithMethod:@"GET" resource:B2WAPICustomerResourceAddress resourceIdentifier:identifier parameters:nil block:^(id object, NSError *error) {
		if (error)
		{
			[self.activityIndicator stopAnimating];

			NSString *title   = kDefaultConnectionErrorTitle;
			NSString *message = kDefaultConnectionErrorMessage;
			
			[self.contentUnavailableView showWithTitle:title message:message buttonTitle:@"Tentar novamente" reloadButtonPressedBlock:^() {
				[self.contentUnavailableView dismiss];
				//[self.loadingView show];
				[self requestOneClick];
			}];
		}
		else
		{
			self.address = [object firstObject];
			
			self.addressLabel.text = self.address.address;
			self.cityStateLabel.text = self.address.city;
			self.postalCodeLabel.text = [NSString stringWithFormat:@"CEP %@", self.address.postalCode.maskedPostalCodeString];
			
			if (self.address && self.creditCard)
			{
                if (kIsIpad || [self.tableView numberOfSections] != 3)
                {
                    [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
                }
				[self.activityIndicator stopAnimating];
			}
		}
	}];
}

- (void)requestCredtCard:(NSString *)identifier
{
	[self.activityIndicator startAnimating];
	
	[B2WAPICustomer requestWithMethod:@"GET" resource:B2WAPICustomerResourceCreditCard resourceIdentifier:identifier parameters:nil block:^(id object, NSError *error) {
		if (error)
		{
			[self.activityIndicator stopAnimating];
			
			NSString *title   = kDefaultConnectionErrorTitle;
			NSString *message = kDefaultConnectionErrorMessage;
			
			[self.contentUnavailableView showWithTitle:title message:message buttonTitle:@"Tentar novamente" reloadButtonPressedBlock:^() {
				[self.contentUnavailableView dismiss];
				//[self.loadingView show];
				[self requestOneClick];
			}];
		}
		else
		{
			self.creditCard = [object firstObject];
			
			CreditCardBrand brand = [B2WValidatorCard cardBrandWithNumber:[self.creditCard.number substringToIndex:6]];
			NSString *brandString = [B2WValidatorCard convertToString:brand];
			
			self.cardFlagImageView.image = [B2WAccountManager cardImageForBrand:brandString];
			self.cardNumberLabel.text = [self.creditCard.number substringFromIndex:self.creditCard.number.length - 4];
			self.cardNameLabel.text = self.creditCard.holderName;
			self.cardExpirationLabel.text = [NSString stringWithFormat:@"%02lu/%lu", (unsigned long)self.creditCard.expirationMonth, (unsigned long)self.creditCard.expirationYear];
			
			if (self.address && self.creditCard)
			{
                if (kIsIpad || [self.tableView numberOfSections] != 3)
                {
                    [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
                }
				[self.activityIndicator stopAnimating];
			}
		}
	}];
}

/*- (void)deleteCredtCard:(NSString *)identifier
{
	[[B2WAccountManager currentCustomer] deleteCreditCard:identifier block:^(id object, NSError *error) {
		if (error)
		{
			//
			// error
			//
		}
		else
		{
			//
			// credit card deleted
			//
		}
	}];
}*/

- (void)deleteOneClickCreditCard
{
	[self.activityIndicator startAnimating];
	
	B2WOneClickRelationship *oneClick = [B2WAccountManager sharedManager].oneClick;
	
	[[B2WAccountManager currentCustomer] deleteCreditCard:oneClick.creditCardIdentifier block:^(id object, NSError *error) {
		if (error)
		{
			[self.activationSwitch setOn:YES animated:YES];
			
			if (error.code == -1009)
			{
				[UIAlertView showAlertViewWithTitle:@"A conexão parece estar offline. Tente novamente."];
			}
			else
			{
				NSDictionary *localizedDescription = (NSDictionary *)error.localizedDescription;
				
				if ([localizedDescription isKindOfClass:[NSDictionary class]])
				{
					[UIAlertView showAlertViewWithTitle:localizedDescription[@"message"]];
				}
				else
				{
					[UIAlertView showAlertViewWithTitle:error.localizedDescription];
				}
			}
		}
		else // 1-click deactivated
		{
			[B2WAccountManager currentCustomer].oneClickEnabled = NO;
			
			self.address = nil;
			self.creditCard = nil;
			
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
			
			NSString *text = [NSString stringWithFormat:@"Selecione um endereço de entrega e cadastre o seu cartão de crédito para ativar %@.", [B2WAccountManager sharedManager].oneClickBrandName];
			[[self.tableView footerViewForSection:0].textLabel setText:text];
			[self.tableView beginUpdates];
			[self.tableView endUpdates];
			
			[self.activityIndicator stopAnimating];
		}
	}];
}

#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex)
	{
		[self deleteOneClickCreditCard];
	}
	else
	{
		[self.activationSwitch setOn:YES animated:YES];
	}
}

#pragma mark - Actions

- (IBAction)closeBarButtonAction:(UIBarButtonItem *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)activationSwitchAction:(UISwitch *)sender
{
	if (sender.isOn)
	{
		[self performSegueWithIdentifier:@"AddressesSegue" sender:nil];
	}
	else
	{
		[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Tem certeza que deseja desativar %@?", [B2WAccountManager sharedManager].oneClickBrandName]
									message:@"Você poderá reativar esse serviço sempre que desejar." delegate:self
						  cancelButtonTitle:@"Cancelar"
						  otherButtonTitles:@"Desativar", nil] show];
	}
}

@end
