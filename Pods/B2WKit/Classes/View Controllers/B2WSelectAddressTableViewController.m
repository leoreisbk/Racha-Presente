//
//  B2WSelectAddressTableViewController.m
//  B2WKit
//
//  Created by Caio Mello on 22/10/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WSelectAddressTableViewController.h"

#import "B2WAddressTableViewCell.h"

#import "B2WAddressValidator.h"

#import "UIViewController+States.h"

#import "B2WAccountManager.h"

#import "B2WOneClickTableViewController.h"
#import "B2WCreditCardFormViewController.h"
#import "SVProgressHUD.h"

@interface B2WSelectAddressTableViewController ()

@property (nonatomic, strong) NSArray *addresses;

@end

@implementation B2WSelectAddressTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self requestAddresses];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Networking

- (void)requestAddresses
{
	[self.loadingView show];
	
	[[B2WAccountManager currentCustomer] requestAddressesWithBlock:^(id object, NSError *error) {
		
		[self.loadingView dismiss];
		
		if (error)
		{
			NSString *title   = kDefaultConnectionErrorTitle;
			NSString *message = kDefaultConnectionErrorMessage;
			
			[self.contentUnavailableView showWithTitle:title message:message buttonTitle:@"Tentar novamente" reloadButtonPressedBlock:^() {
				 [self.contentUnavailableView dismiss];
				 [self.loadingView show];
				 [self requestAddresses];
			 }];
		}
		else
		{
			NSMutableArray *addresses = [NSMutableArray new];
			
			for (B2WAddress *address in object)
			{
				[addresses addObject:address];
			}
			
			self.addresses = addresses;
			
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		}
	}];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return self.addresses ? 1 : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return @"Selecione o endereço de entrega";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.addresses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	B2WAddress *address = self.addresses[indexPath.row];
	
	B2WAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	/*NSString *addressPrefix = [address.address componentsSeparatedByString:@" "][0];
	NSString *addressString = [address.address stringByReplacingCharactersInRange:NSMakeRange(0, addressPrefix.length)
																	   withString:[[address.address substringToIndex:addressPrefix.length] capitalizedString]];*/
	
	[cell.addressLabel setText:[address.address.capitalizedString stringByAppendingString:[NSString stringWithFormat:@", %@", address.number]]];
	[cell.cityStateLabel setText:[NSString stringWithFormat:@"%@ - %@", address.city, address.state]];
	[cell.postalCodeLabel setText:[NSString stringWithFormat:@"CEP %@", [address.postalCode maskedPostalCodeString]]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	B2WAddress *address = self.addresses[indexPath.row];
    
    [SVProgressHUD showWithStatus:@"Atualizando endereço..."];
    [address setAsMainWithBlock:^(id object, NSError *error) {
        [SVProgressHUD dismiss];
        if (error == nil) {
            [B2WAccountManager sharedManager].address = address;
            [self performSegueWithIdentifier:@"CreditCardSegue" sender:nil];
        } else {
            [B2WKitUtils presentError:error];
        }
    }];
}

#pragma mark - Actions

- (IBAction)cancelButtonAction:(id)sender
{
	if (kIsIpad)
	{
		[self.presentingViewController viewWillAppear:YES];
	}
	
    [self dismissViewControllerAnimated: YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OneClickActivationCancelled" object:nil];
    }];
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CreditCardSegue"])
    {
        B2WCreditCardFormViewController *creditCardFormViewController = (B2WCreditCardFormViewController *)segue.destinationViewController;
        creditCardFormViewController.isOneClickActivation = YES;
    }
}

@end
