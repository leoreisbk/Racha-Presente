//
//  SHOPAddressFormViewController.m
//  B2WKit
//
//  Created by Eduardo Callado on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WAddressFormViewController.h"

#import "B2WAddressValidator.h"
#import "B2WAPICustomer.h"
#import "B2WAPIPostalCode.h"
#import "B2WPostalCodeSearchTableViewController.h"

#import "B2WFormCell.h"

#import "B2WFormElement.h"

@interface B2WAddressFormViewController () <UITextFieldDelegate, PostalCodeSearchControllerDelegate>

@property (nonatomic, strong) IBOutlet UITextField *postalCodeTextField;

@property (nonatomic, strong) IBOutlet UILabel *cityStateLabel;
@property (nonatomic, strong) IBOutlet UITextField *addressTextField;
@property (nonatomic, strong) IBOutlet UITextField *neighborhoodTextField;
@property (nonatomic, strong) IBOutlet UITextField *numberTextField;
@property (nonatomic, strong) IBOutlet UITextField *complementTextField;
@property (nonatomic, strong) IBOutlet UITextField *referenceTextField;

@property (nonatomic, strong) NSArray *formElementGroups;

@property (nonatomic, assign) BOOL hasAddress;

@end


@implementation B2WAddressFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
	
	if (customerManager.isCreatingNewAccount)
	{
		self.navigationItem.leftBarButtonItem = nil;
		
		[B2WAccountManager sharedManager].address = [B2WAddress new];
		
		// [self refreshFormWithAddress:customerManager.address];
    }
	else
	{
		if (self.isCreatingNewAddress)
		{
			[self.navigationItem.rightBarButtonItem setTitle:@"Adicionar"];
			
			[B2WAccountManager sharedManager].address = [B2WAddress new];
		}
		else
		{
			[self.navigationItem.rightBarButtonItem setTitle:@"Salvar"];
			
			[self refreshFormWithAddress:customerManager.address];
		}
	}
	
	[self.cityStateLabel setText:@""];
	
	self.formElementGroups = @[@[[B2WFormElement formElementWithKey:@"zipCode" textField:self.postalCodeTextField error:@""]],
							   @[[B2WFormElement formElementWithKey:nil textField:nil error:nil],
								 [B2WFormElement formElementWithKey:@"address" textField:self.addressTextField error:@""],
								 [B2WFormElement formElementWithKey:@"neighborhood" textField:self.neighborhoodTextField error:@""],
								 [B2WFormElement formElementWithKey:@"number" textField:self.numberTextField error:@""],
								 [B2WFormElement formElementWithKey:@"reference" textField:self.referenceTextField error:@""]]];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackScreenView"
                                                        object:self
													  userInfo:@{@"screenName" : @"Cadastro - Info Endereço"}];
	
	if (self.postalCodeTextField.text.length == 0)
	{
		[self.postalCodeTextField becomeFirstResponder];
	}
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (!self.hasAddress)
	{
		return 1;
	}

	return [super numberOfSectionsInTableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 44;
    }
	
	return [super tableView:tableView heightForFooterInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIButton *postalCodeSearchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [postalCodeSearchButton setTitle:@"Consultar CEP" forState:UIControlStateNormal];
        [postalCodeSearchButton addTarget:self action:@selector(postalCodeSearchButtonAction) forControlEvents:UIControlEventTouchUpInside];
		
		UIColor *tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
        [postalCodeSearchButton setTitleColor:tintColor forState:UIControlStateNormal];
        return postalCodeSearchButton;
    }
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1 && indexPath.row == 0)
	{
		CGRect cityStateTextRect = [self.cityStateLabel.text boundingRectWithSize:CGSizeMake(self.cityStateLabel.bounds.size.width - 10, 50000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.cityStateLabel.font} context:nil];
		return 7 + cityStateTextRect.size.height + 6 + 10;
	}
	else
	{
		B2WFormElement *formElement = self.formElementGroups[indexPath.section][indexPath.row];
		
		if (formElement.error.length > 0)
		{
			B2WFormCell *cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			
			CGRect errorTextRect = [formElement.error boundingRectWithSize:CGSizeMake(cell.errorLabel.bounds.size.width - 10, 50000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cell.errorLabel.font} context:nil];
			return 7 + cell.textField.bounds.size.height + 9 + errorTextRect.size.height + 7; // Top marging + text field height + spacing + error label height + bottom marging
		}
		
		return 54;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!(indexPath.section == 1 && indexPath.row == 0))
	{
		B2WFormElement *formElement = self.formElementGroups[indexPath.section][indexPath.row];
		
		B2WFormCell *formCell = (B2WFormCell *)cell;
		[formCell.errorLabel setText:formElement.error];
		[formCell.errorLabel setHidden:formElement.error.length == 0];
		[formCell.errorImageView setHidden:formElement.error.length == 0]; formCell.errorImageView.image = [B2WAccountManager alertImage];
	}
}
	
#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *finalText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.postalCodeTextField)
	{
		if (finalText.length == kPOSTALCODE_FIELD_MAX_CHARS && textField.text.length == kPOSTALCODE_FIELD_MAX_CHARS - 1)
		{
			[self requestAddressWithPostalCode:finalText];
		}
		else if (finalText.length == 0)
		{
			[self.cityStateLabel setText:@""];
			[self.addressTextField setText:@""];
			[self.neighborhoodTextField setText:@""];
			
			if (self.hasAddress)
			{
				self.hasAddress = NO;
				
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
			}
			
			[self refreshTextFields];
			[self removeErrors];
		}
		
		[textField setText:finalText.maskedPostalCodeString];
		
		return NO;
	}
	
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	if (textField == self.postalCodeTextField)
	{
		if (self.hasAddress)
		{
			self.hasAddress = NO;
			
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
		}
		
		[self refreshTextFields];
		[self removeErrors];
	}
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	B2WFormElement *formElement = [self formElementForTextField:textField];
	
	[self setErrorWithKey:formElement.key message:textField.text.length > 0 ? @"" : kEmptyFieldError overwriteCurrentError:YES];
}

#pragma mark - Customer Manager

- (void)refreshFormWithAddress:(B2WAddress *)address
{
	if (!self.hasAddress)
	{
		self.hasAddress = YES;
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
	}
	
	self.postalCodeTextField.text = [address.postalCode maskedPostalCodeString];
	self.addressTextField.text = [address.address isKindOfClass:[NSNull class]] ? @"" : address.address;
    self.neighborhoodTextField.text = [address.neighborhood isKindOfClass:[NSNull class]] ? @"" : address.neighborhood;
	self.numberTextField.text = address.number;
    self.complementTextField.text = address.additionalInfo;
    self.referenceTextField.text = address.reference;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if (![address.city isKindOfClass:[NSNull class]] && ![address.state isKindOfClass:[NSNull class]])
		{
			//if (address.city && address.state)
			{
				self.cityStateLabel.text = [NSString stringWithFormat:@"%@ - %@", address.city, address.state];
			}
		}
	});
	
	[self refreshTextFields];
}

- (void)setAddressFromForm
{
	B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
	
    B2WAddress *address = (B2WAddress *)customerManager.address;
	address.main = customerManager.isCreatingNewAccount;
    address.addressType = B2WAddressTypePersonal;
    
    address.postalCode = self.postalCodeTextField.text;
    address.address = self.addressTextField.text;
    address.number = self.numberTextField.text;
    address.additionalInfo = self.complementTextField.text;
    address.reference = self.referenceTextField.text;
	address.city = [self.cityStateLabel.text componentsSeparatedByString:@" - "].firstObject;
    address.state = [self.cityStateLabel.text componentsSeparatedByString:@" - "].lastObject;
    address.neighborhood = self.neighborhoodTextField.text;
    
    address.name = @"Principal";
	
	if (customerManager.customerType == CustomerTypeIndividual)
    {
        address.recipientName = customerManager.individualCustomer.fullName;
    }
    else
    {
        address.recipientName = customerManager.businessCustomer.responsibleName;
    }
}

#pragma mark - Errors

- (void)setErrorWithKey:(NSString *)key message:(NSString *)errorMessage overwriteCurrentError:(BOOL)shouldOverwrite
{
	B2WFormElement *formElement = [self formElementForKey:key];
	
	if (formElement && (shouldOverwrite || formElement.error.length == 0))
	{
		[formElement setError:errorMessage];
		
		B2WFormCell *cell = (B2WFormCell *)[self.tableView cellForRowAtIndexPath:[self indexPathForTextField:formElement.textField]];
		[cell.errorLabel setText:formElement.error];
		[cell.errorLabel setHidden:formElement.error.length == 0];
		[cell.errorImageView setHidden:formElement.error.length == 0]; cell.errorImageView.image = [B2WAccountManager alertImage];
		[self.tableView beginUpdates];
		[self.tableView endUpdates];
	}
}

- (void)showValidationErrors:(NSArray *)errors
{
	for (NSDictionary *error in errors)
	{
		NSString *key = error[@"fieldName"];
		NSString *fieldKey = [key componentsSeparatedByString:@"."].lastObject;
		NSString *message = error[@"message"];
		
		[self setErrorWithKey:fieldKey message:message overwriteCurrentError:NO];
	}
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
	{
		case 0:
			NSLog(@"0");
			break;
			
		case 1:
			[self postalCodeSearchButtonAction];
			break;
			
		default:
			break;
	}
}

#pragma mark - Networking

- (void)requestAddressWithPostalCode:(NSString *)postalCode
{
	[self.navigationItem setRightBarButtonItem:[self loadingBarItem] animated:YES];
	
	[B2WAPIPostalCode cancelAllRequests];
    
    [B2WAPIPostalCode requestAddressInformationWithPostalCode:postalCode block:^(id object, NSError *error) {
		[self.tableView endEditing:YES];
		
		[self.navigationItem setRightBarButtonItem:[self continueBarItem] animated:YES];
		
        if (error)
        {
			if (error.code == -1009)
			{
				[UIAlertView showAlertViewWithTitle:@"A conexão parece estar offline. Tente novamente."];
			}
			else
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CEP Não Encontrado" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Consultar CEP", nil];
				alert.delegate = self;
				[alert show];
			}
		}
		else
		{
			NSMutableDictionary *addressDict = [[NSMutableDictionary alloc] initWithDictionary:object];
			[addressDict removeObjectForKey:@"number"];
			
			B2WAddress *address = [[B2WAddress alloc] initWithDictionary:addressDict];
			[address setPostalCode:postalCode];
			
			[self refreshFormWithAddress:address];
			
			if (!self.hasAddress)
			{
				self.hasAddress = YES;
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
			}
			
			[self refreshTextFields];
			[self removeErrors];
		}
	}];
}

- (void)registerAddress
{
    void (^completion)(id, NSError *) = ^(id object, NSError *error) {
		[self.navigationItem setRightBarButtonItem:[self continueBarItem] animated:YES];
		[self.tableView setUserInteractionEnabled:YES];
        
        if (error)
        {
			NSDictionary *localizedDescription = (NSDictionary *)error.localizedDescription;

			if ([localizedDescription isKindOfClass:[NSString class]])
			{
				[UIAlertView showAlertViewWithTitle:(NSString *)localizedDescription];
			}
			else
			// if ([localizedDescription isKindOfClass:[NSDictionary class]])
			{
				if (localizedDescription && (! [localizedDescription.allKeys containsObject:@"validationErrors"])) // erro do servidor
				{
					[UIAlertView showAlertViewWithTitle:localizedDescription[@"message"]];
				}
				else // é possível ter erro de validação
				{
					NSMutableArray *validationErrors = [[NSMutableArray alloc] initWithArray:localizedDescription[@"validationErrors"]];
					
					if (validationErrors.count > 0) // há erro de validação
					{
						[self showValidationErrors:validationErrors];
					}
				}
			}
        }
        else
        {
            if ([B2WAccountManager sharedManager].isCreatingNewAccount)
			{
                if ([B2WAccountManager sharedManager].shouldPresentOneClickActivationPopUpAfterSignUp) {
                    [[B2WAccountManager sharedManager] presentSignUpCompletedViewController];
                }
				
				[B2WAccountManager loginUserWithEmail:[B2WAccountManager currentCustomer].email
											 password:[B2WAccountManager currentCustomer].password];
				
				// [B2WAccountManager sharedManager].isCreatingNewAccount = NO;
				
                [self dismissViewControllerAnimated:YES completion:^{
                    if ( ! [B2WAccountManager sharedManager].shouldPresentOneClickActivationPopUpAfterSignUp ) {
                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"NewAccountAddressSelected" object:nil];
                        if (self.accountCreationDelegate && [self.accountCreationDelegate respondsToSelector:@selector(addressSelected)]) {
                            [self.accountCreationDelegate addressSelected];
                        }
                    }
                }];
			}
			else
			{
				if (self.isCreatingNewAddress)
				{
					// [UIAlertView showAlertViewWithTitle:@"Endereço adicionado com sucesso!"];
					
					[self.delegate addressFormViewController:self didCreateAddress:[B2WAccountManager sharedManager].address];
				}
				else
				{
					[UIAlertView showAlertViewWithTitle:@"Dados atualizados com sucesso!"];
					
					[self.delegate addressFormViewController:self didEditAddress:[B2WAccountManager sharedManager].address];
				}
			}
        }
    };
	
	[self.navigationItem setRightBarButtonItem:[self loadingBarItem] animated:YES];
	[self.tableView setUserInteractionEnabled:NO];
	
	B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
	
	[B2WAPICustomer setPersistenceEnabled:YES];
	
	if (customerManager.isCreatingNewAccount)
	{
		[[B2WAccountManager currentCustomer] createWithAddress:customerManager.address block:completion];
	}
	else
	{
		if (self.isCreatingNewAddress)
		{
			[[B2WAccountManager sharedManager].address addNewWithBlock:completion];
		}
		else
		{
			[[B2WAccountManager sharedManager].address updateWithBlock:completion];
		}
	}
}

#pragma mark - PostalCodeSearchController

- (void)postalCodeSearchController:(B2WPostalCodeSearchTableViewController *)searchController didSelectAddress:(NSDictionary *)addressDictionary
{
	NSString *city = [addressDictionary[@"city"] isKindOfClass:[NSNull class]] ? @"" : addressDictionary[@"city"];
	NSString *state = [addressDictionary[@"state"] isKindOfClass:[NSNull class]] ? @"" : addressDictionary[@"state"];
	NSString *address = [addressDictionary[@"address"] isKindOfClass:[NSNull class]] ? @"" : addressDictionary[@"address"];
	NSString *postalCode = [addressDictionary[@"number"] isKindOfClass:[NSNull class]] ? @"" : addressDictionary[@"number"];
	NSString *neighborhood = [addressDictionary[@"neighborhood"] isKindOfClass:[NSNull class]] ? @"" : addressDictionary[@"neighborhood"];
	
	[self.postalCodeTextField setText:[postalCode maskedPostalCodeString]];
	[self.cityStateLabel setText:[NSString stringWithFormat:@"%@ - %@", city, state]];
	
	[self.addressTextField setText:address];
	[self.neighborhoodTextField setText:neighborhood];
	
	[self setErrorWithKey:@"zipCode" message:@"" overwriteCurrentError:YES];
	
	if (!self.hasAddress)
	{
		self.hasAddress = YES;
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	}
	
	[self refreshTextFields];
	[self removeErrors];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom

- (void)refreshTextFields
{
	if (self.hasAddress && self.addressTextField.text.length == 0)
	{
		[self.addressTextField setUserInteractionEnabled:YES];
		[self.addressTextField setTextColor:[UIColor blackColor]];
	}
	else
	{
		[self.addressTextField setUserInteractionEnabled:NO];
		[self.addressTextField setTextColor:[UIColor grayColor]];
	}
	
	if (self.hasAddress && self.neighborhoodTextField.text.length == 0)
	{
		[self.neighborhoodTextField setUserInteractionEnabled:YES];
		[self.neighborhoodTextField setTextColor:[UIColor blackColor]];
	}
	else
	{
		[self.neighborhoodTextField setUserInteractionEnabled:NO];
		[self.neighborhoodTextField setTextColor:[UIColor grayColor]];
	}
}

- (NSIndexPath *)indexPathForTextField:(UITextField *)textField
{
	for (NSArray *formElementGroup in self.formElementGroups)
	{
		B2WFormElement *formElement = [formElementGroup filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.textField == %@", textField]].firstObject;
		
		if (formElement)
		{
			return [NSIndexPath indexPathForRow:[formElementGroup indexOfObject:formElement] inSection:[self.formElementGroups indexOfObject:formElementGroup]];
		}
	}
	
	return nil;
}

- (B2WFormElement *)formElementForTextField:(UITextField *)textField
{
	for (NSArray *formElementGroup in self.formElementGroups)
	{
		B2WFormElement *formElement = [formElementGroup filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.textField == %@", textField]].firstObject;
		
		if (formElement)
		{
			return formElement;
		}
	}
	
	return nil;
}

- (B2WFormElement *)formElementForKey:(NSString *)key
{
	for (NSArray *formElementGroup in self.formElementGroups)
	{
		B2WFormElement *formElement = [formElementGroup filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.key == %@", key]].firstObject;
		
		if (formElement)
		{
			return formElement;
		}
	}
	
	return nil;
}

- (UIBarButtonItem *)continueBarItem
{
	NSString *title = self.isCreatingNewAddress ? @"Adicionar" : @"Salvar";
	
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(confirmButtonPressed)];
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

- (void)removeErrors
{
	for (NSArray *formElementGroup in self.formElementGroups)
	{
		for (B2WFormElement *formElement in formElementGroup)
		{
			[self setErrorWithKey:formElement.key message:@"" overwriteCurrentError:YES];
		}
	}
}

#pragma mark - Actions

- (IBAction)cancelBarButtonAction:(UIBarButtonItem *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmButtonPressed
{
	[self.tableView endEditing:YES];
	
	for (NSArray *formElementGroup in self.formElementGroups)
	{
		for (B2WFormElement *formElement in formElementGroup)
		{
			if (formElement.textField && formElement.textField.text.length == 0)
			{
				[self setErrorWithKey:formElement.key message:kEmptyFieldError overwriteCurrentError:YES];
				
				if (!self.hasAddress)
				{
					break;
				}
			}
		}
		
		if (!self.hasAddress)
		{
			break;
		}
	}
	
	// Check for errors
	for (NSArray *formElementArray in self.formElementGroups) {
		for (B2WFormElement *formElement in formElementArray) {
			if (formElement.error.length > 0) {
				[self.tableView scrollToRowAtIndexPath:[self indexPathForTextField:formElement.textField] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
				return;
			}
		}
	}
	
	if (!self.hasAddress)
	{
		[UIAlertView showAlertViewWithTitle:@"Você Precisa Buscar Um Endereço Para Continuar"];
		
		return;
	}
	
	[self setAddressFromForm];
	
	[self registerAddress];
}

- (void)postalCodeSearchButtonAction
{
    [self performSegueWithIdentifier:@"PostalCodeSearchSegue" sender:nil];
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PostalCodeSearchSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        B2WPostalCodeSearchTableViewController *postalCodeSearchViewController = (B2WPostalCodeSearchTableViewController *)navigationController.topViewController;
        [postalCodeSearchViewController setDelegate:self];
    }
}

@end
