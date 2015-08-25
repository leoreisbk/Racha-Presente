//
//  B2WAddressListTableViewController.m
//  B2WKit
//
//  Created by Caio Mello on 22/10/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WAddressListTableViewController.h"

#import "B2WAddressTableViewCell.h"
#import "B2WAddressFormViewController.h"
#import "B2WAddressValidator.h"

#import "UIViewController+States.h"

@interface B2WAddressListTableViewController () <UIActionSheetDelegate, AddressFormViewControllerDelegate>

@property (nonatomic, strong) NSArray *addresses;

@end

@implementation B2WAddressListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.tableView.allowsSelectionDuringEditing = YES;
    
	[self requestAddresses];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.addresses.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return @"Endereço principal";
	}
	else
	{
		return @"Outros endereços";
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
	{
		return [self.addresses.firstObject count];
	}
	else
	{
		NSInteger count = [self.addresses.lastObject count];
		
		[self.navigationItem setRightBarButtonItem:(count == 0) ? nil : [self editBarItem] animated:YES];
		
		return count + 1;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1 && indexPath.row == [self.addresses.lastObject count])
	{
		return 44;
	}
	
	return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1 && indexPath.row == [self.addresses.lastObject count])
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell" forIndexPath:indexPath];
		cell.textLabel.textColor = [B2WAccountManager sharedManager].appPrimaryColor;
		return cell;
	}
	else
	{
		B2WAddress *address = self.addresses[indexPath.section][indexPath.row];
		
		B2WAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
		
		/*NSString *addressPrefix = [address.address componentsSeparatedByString:@" "][0];
		NSString *addressString = [address.address stringByReplacingCharactersInRange:NSMakeRange(0, addressPrefix.length)
																	withString:[[address.address substringToIndex:addressPrefix.length] capitalizedString]];*/
		
		[cell.addressLabel setText:[address.address.capitalizedString stringByAppendingString:[NSString stringWithFormat:@", %@", address.number]]];
		[cell.additionalInfoLabel setText:address.additionalInfo];
		[cell.cityStateLabel setText:[NSString stringWithFormat:@"%@ - %@", address.city, address.state]];
		[cell.postalCodeLabel setText:[NSString stringWithFormat:@"CEP %@", [address.postalCode maskedPostalCodeString]]];
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{ // selected main address
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:@"Editar", nil];
		[actionSheet showInView:self.view];
	}
	else if (indexPath.row == [self.addresses.lastObject count])
	{ // add new address
		[B2WAccountManager sharedManager].address = nil;
		[self performSegueWithIdentifier:@"AddressSegue" sender:nil];
	}
	else
	{ // selected regular address
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:@"Tornar Principal", @"Editar", nil];
		[actionSheet showInView:self.view];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!tableView.isEditing || ([self.addresses.firstObject count] + [self.addresses.lastObject count] == 1) || (indexPath.section == 1 && indexPath.row == [self.addresses.lastObject count]))
	{
		return NO;
	}
	
	return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return @"Remover";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		B2WAddress *address = self.addresses[indexPath.section][indexPath.row];
		
		if (indexPath.section == 0)
		{
			B2WAddress *newMainAddress = [self.addresses.lastObject firstObject];
			[newMainAddress setMain:YES];
			
			[self.addresses.firstObject removeObjectAtIndex:0];
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			
			[self.addresses.lastObject removeObjectAtIndex:0];
			[self.addresses.firstObject addObject:newMainAddress];
			[tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			
			[newMainAddress setAsMainWithBlock:nil];
		}
		else
		{
			[self.addresses.lastObject removeObjectAtIndex:indexPath.row];
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		}
		
		[self deleteAddress:address];
	}
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
			B2WAddress *mainAddress;
			NSMutableArray *addresses = [NSMutableArray new];
			
			for (B2WAddress *address in object)
			{
				if (address.main)
				{
					mainAddress = address;
				}
				else
				{
					[addresses addObject:address];
				}
			}
			
			if (mainAddress)
			{
				self.addresses = @[@[mainAddress].mutableCopy, addresses];
			}
			else
			{
				self.addresses = @[@[].mutableCopy, addresses];
			}
			
			[self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade];
		}
	}];
}

- (void)deleteAddress:(B2WAddress *)address
{
	//[self.loadingView show];
	
	[address removeWithBlock:^(id object, NSError *error) {
		
		//[self.loadingView dismiss];

		if (error)
		{
			/*if (error.code == -1009)
			{
				[UIAlertView showAlertViewWithTitle:@"A conexão parece estar offline. Tente novamente."];
			}
			else
			{
				NSDictionary *localizedDescription = (NSDictionary *)error.localizedDescription;
				
				if (localizedDescription && (! [localizedDescription.allKeys containsObject:@"validationErrors"]))
				{
					[UIAlertView showAlertViewWithTitle:localizedDescription[@"message"]];
				}
				else
				{
					[UIAlertView showAlertViewWithTitle:error.localizedDescription];
				}
			}*/
		}
		else
		{
			// [UIAlertView showAlertViewWithTitle:@"Endereço removido com sucesso!"];
		}
	}];
}

#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
		
		// Set as main address
		if (actionSheet.numberOfButtons == 3 && buttonIndex == 0)
		{
			B2WAddress *oldMainAddress = [self.addresses.firstObject firstObject];
			[oldMainAddress setMain:NO];
			
			B2WAddress *newMainAddress = [self.addresses.lastObject objectAtIndex:indexPath.row];
			[newMainAddress setMain:YES];
			
			[self.addresses.lastObject removeObject:newMainAddress];
			[self.addresses.firstObject insertObject:newMainAddress atIndex:0];
			[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:1] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			
			if (oldMainAddress) {
				[self.addresses.firstObject removeObjectAtIndex:1];
				[self.addresses.lastObject insertObject:oldMainAddress atIndex:indexPath.row];
				[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:1]];
			}
			
			[newMainAddress setAsMainWithBlock:nil];
		}
		// Edit address
		else if ((actionSheet.numberOfButtons == 3 && buttonIndex == 1) || (actionSheet.numberOfButtons == 2 && buttonIndex == 0))
		{
			B2WAddress *address = self.addresses[indexPath.section][indexPath.row];
			[B2WAccountManager sharedManager].address = address;
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[self performSegueWithIdentifier:@"AddressSegue" sender:[B2WAccountManager sharedManager].address];
			});
		}
	}
	
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark - AddressViewController

- (void)addressFormViewController:(B2WAddressFormViewController *)controller didCreateAddress:(B2WAddress *)address
{
	[self dismissViewControllerAnimated:YES completion:^{
		[self.addresses.lastObject insertObject:address atIndex:0];
		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
	}];
}

- (void)addressFormViewController:(B2WAddressFormViewController *)controller didEditAddress:(B2WAddress *)address
{
	[self.tableView reloadData];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom

- (UIBarButtonItem *)editBarItem
{
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"Editar" style:UIBarButtonItemStyleDone target:self action:@selector(editBarButtonAction:)];
	return barItem;
}

- (UIBarButtonItem *)loadingBarItem
{
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[activityIndicator setColor:[B2WAccountManager sharedManager].appLoadingColor];
	[activityIndicator startAnimating];
	
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	return barItem;
}

#pragma mark - Actions

- (IBAction)closeBarButtonAction:(UIBarButtonItem *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editBarButtonAction:(UIBarButtonItem *)sender
{
	if (self.tableView.isEditing)
	{
		[self.tableView setEditing:NO animated:YES];
		[sender setTitle:@"Editar"];
	}
	else
	{
		[self.tableView setEditing:YES animated:YES];
		[sender setTitle:@"OK"];
	}
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddressSegue"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		B2WAddressFormViewController *addressViewController = (B2WAddressFormViewController *)navigationController.topViewController;
		[addressViewController setDelegate:self];
		addressViewController.isCreatingNewAddress = sender ? NO : YES;
	}
}

@end
