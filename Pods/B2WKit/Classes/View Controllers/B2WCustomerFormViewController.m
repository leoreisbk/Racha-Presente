//
//  B2WCustomerFormViewController.m
//  B2WKit
//
//  Created by Eduardo Callado on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WCustomerFormViewController.h"

#import "B2WAddressFormViewController.h"
#import "B2WCustomerValidator.h"
#import "B2WAPICustomer.h"
#import "B2WAccountManager.h"
#import "B2WFormCell.h"

#import "B2WFormElement.h"

typedef NS_ENUM(NSInteger, FormRow) {
	FormRowGender,
	FormRowTaxInformation,
	FormRowState,
	FormRowStateRegistration,
	FormRowCorporate,
	FormRowName,
	FormRowCPFCNPJ,
	FormRowBirthDate,
	FormRowPhone
};

@interface B2WCustomerFormViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UISegmentedControl *customerTypeSegmentedControl;

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordConfirmTextField;

@property (nonatomic, strong) IBOutlet UISegmentedControl *genderSegmentedControl;
@property (nonatomic, strong) IBOutlet UITextField *taxInformationTextField; // indicatorIERecipient
@property (nonatomic, strong) IBOutlet UITextField *stateTextField;
@property (nonatomic, strong) IBOutlet UITextField *stateRegistrationTextField; // stateInscription
@property (nonatomic, strong) IBOutlet UITextField *corporateTextField;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *CPFCNPJTextField;
@property (nonatomic, strong) IBOutlet UITextField *birthDateTextField;
@property (nonatomic, strong) IBOutlet UITextField *phoneTextField;

@property (nonatomic, strong) UIPickerView *taxPickerView;
@property (nonatomic, strong) UIPickerView *statePickerView;

@property (nonatomic, strong) NSArray *individualFormElementGroups;
@property (nonatomic, strong) NSArray *businessFormElementGroups;

@property (nonatomic, strong) NSMutableArray *states;
@property (nonatomic, strong) NSArray *taxInformationTypes;

@end

@implementation B2WCustomerFormViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[B2WAccountManager resetAccountSavedData];
	
	self.individualFormElementGroups = @[@[[B2WFormElement formElementWithKey:@"email" textField:self.emailTextField error:@""],
										   [B2WFormElement formElementWithKey:@"password" textField:self.passwordTextField error:@""],
										   [B2WFormElement formElementWithKey:@"passwordConfirm" textField:self.passwordConfirmTextField error:@""]],
										 @[[B2WFormElement formElementWithKey:nil textField:nil error:nil],
										   [B2WFormElement formElementWithKey:@"fullName" textField:self.nameTextField error:@""],
										   [B2WFormElement formElementWithKey:@"cpf" textField:self.CPFCNPJTextField error:@""],
										   [B2WFormElement formElementWithKey:@"birthday" textField:self.birthDateTextField error:@""],
										   [B2WFormElement formElementWithKey:@"phone" textField:self.phoneTextField error:@""]]];
	
	self.businessFormElementGroups = @[@[[B2WFormElement formElementWithKey:@"email" textField:self.emailTextField error:@""],
										 [B2WFormElement formElementWithKey:@"password" textField:self.passwordTextField error:@""],
										 [B2WFormElement formElementWithKey:@"passwordConfirm" textField:self.passwordConfirmTextField error:@""]],
									   @[[B2WFormElement formElementWithKey:@"indicatorIERecipient" textField:self.taxInformationTextField error:@""],
										 [B2WFormElement formElementWithKey:@"corporateName" textField:self.corporateTextField error:@""],
										 [B2WFormElement formElementWithKey:@"responsibleName" textField:self.nameTextField error:@""],
										 [B2WFormElement formElementWithKey:@"cnpj" textField:self.CPFCNPJTextField error:@""],
										 [B2WFormElement formElementWithKey:@"phone" textField:self.phoneTextField error:@""]].mutableCopy];
	
	[self loadStates];
	
	self.taxInformationTypes = @[@"Contribuinte ICMS", @"Não contribuinte", @"Isento de inscrição estadual"];
	
	self.taxPickerView = [UIPickerView new];
	[self.taxPickerView setDataSource:self];
	[self.taxPickerView setDelegate:self];
	
	[self.taxInformationTextField setInputView:self.taxPickerView];
	
	self.statePickerView = [UIPickerView new];
	[self.statePickerView setDataSource:self];
	[self.statePickerView setDelegate:self];
	
	[self.stateTextField setInputView:self.statePickerView];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackScreenView"
														object:self
													  userInfo:@{@"screenName" : @"Cadastro - Info Pessoais"}];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *formElementGroups = self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual ? self.individualFormElementGroups : self.businessFormElementGroups;
	
	return [formElementGroups[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	B2WFormElement *formElement = self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual ? self.individualFormElementGroups[indexPath.section][indexPath.row] : self.businessFormElementGroups[indexPath.section][indexPath.row];
	
	if (formElement.textField && formElement.error.length > 0)
    {
		B2WFormCell *cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		
		CGRect errorTextRect = [formElement.error boundingRectWithSize:CGSizeMake(cell.errorLabel.bounds.size.width - 10, 50000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cell.errorLabel.font} context:nil];
		return 8 + cell.textField.bounds.size.height + 8 + errorTextRect.size.height + 7; // Top marging + text field height + spacing + error label height + bottom marging
    }
	
	return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	B2WFormElement *formElement = self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual ? self.individualFormElementGroups[indexPath.section][indexPath.row] : self.businessFormElementGroups[indexPath.section][indexPath.row];
	
	B2WFormCell *cell;
	
	if (indexPath.section == 1)
    {
		if (self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual)
		{
			if (indexPath.row > 0)
            {
				cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
				switch (indexPath.row) {
					case 0: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowGender inSection:indexPath.section]]; break;
					case 1: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowName inSection:indexPath.section]]; break;
					case 2: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowCPFCNPJ inSection:indexPath.section]]; break;
					case 3: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowBirthDate inSection:indexPath.section]]; break;
					case 4: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowPhone inSection:indexPath.section]]; break;
					default: break;
				}
			}
		}
		else
		{
			if (self.taxInformationTextField.text.length > 0 && ![self.taxInformationTextField.text isEqualToString:self.taxInformationTypes.lastObject]){
				if (self.stateTextField.text.length > 0){
					switch (indexPath.row) {
						case 0: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowTaxInformation inSection:indexPath.section]]; break;
						case 1: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowState inSection:indexPath.section]]; break;
						case 2: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowStateRegistration inSection:indexPath.section]]; break;
						case 3: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowCorporate inSection:indexPath.section]]; break;
						case 4: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowName inSection:indexPath.section]]; break;
						case 5: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowCPFCNPJ inSection:indexPath.section]]; break;
						case 6: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowPhone inSection:indexPath.section]]; break;
						default: break;
					}
				}
				else{
					switch (indexPath.row) {
						case 0: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowTaxInformation inSection:indexPath.section]]; break;
						case 1: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowState inSection:indexPath.section]]; break;
						case 2: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowCorporate inSection:indexPath.section]]; break;
						case 3: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowName inSection:indexPath.section]]; break;
						case 4: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowCPFCNPJ inSection:indexPath.section]]; break;
						case 5: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowPhone inSection:indexPath.section]]; break;
						default: break;
					}
				}
			}
			else{
				switch (indexPath.row) {
					case 0: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowTaxInformation inSection:indexPath.section]]; break;
					case 1: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowCorporate inSection:indexPath.section]]; break;
					case 2: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowName inSection:indexPath.section]]; break;
					case 3: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowCPFCNPJ inSection:indexPath.section]]; break;
					case 4: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowPhone inSection:indexPath.section]]; break;
					default: break;
				}
			}
		}
	}
	
	if (!cell)
    {
		cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	}
	
	[cell.errorLabel setText:formElement.error];
	[cell.errorImageView setHidden:formElement.error.length == 0]; cell.errorImageView.image = [B2WAccountManager alertImage];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	B2WFormElement *formElement = self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual ? self.individualFormElementGroups[indexPath.section][indexPath.row] : self.businessFormElementGroups[indexPath.section][indexPath.row];
	
	B2WFormCell *formCell = (B2WFormCell *)cell;
	[formCell.errorLabel setText:formElement.error];
	[formCell.errorLabel setHidden:formElement.error.length == 0];
	[formCell.errorImageView setHidden:formElement.error.length == 0]; formCell.errorImageView.image = [B2WAccountManager alertImage];
}

#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *finalText = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if (textField == self.CPFCNPJTextField)
	{
		if (self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual)
			[textField setText:finalText.maskedCPFString];
		else
			[textField setText:finalText.maskedCNPJString];
		
		return NO;
	}
	else if (textField == self.birthDateTextField)
	{
		[textField setText:finalText.maskedBirthDate];
		
		return NO;
	}
	else if (textField == self.phoneTextField)
	{
		[textField setText:finalText.maskedPhoneString];
		
		return NO;
	}
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	B2WFormElement *formElement = [self formElementForTextField:textField];
	
	[self setErrorWithKey:formElement.key message:textField.text.length > 0 ? @"" : kEmptyFieldError overwriteCurrentError:YES];
	
	if (textField.text.length > 0)
	{
		if (textField == self.emailTextField)
		{
			[self checkEmailAvailability];
		}
		else if (textField == self.passwordTextField)
		{
			PasswordValidation validationResult = [textField.text isValidPassword];
			
			if (validationResult == PasswordValidationErrorTooShort)
			{
				[self setErrorWithKey:@"password" message:@"Senha muito curta." overwriteCurrentError:YES];
			}
			else if (validationResult == PasswordValidationErrorTooLong)
			{
				[self setErrorWithKey:@"password" message:@"Senha muito longa." overwriteCurrentError:YES];
			}
			/*else
			{
				[self removeErrorWithKey:@"password"];
			}*/
		}
		else if (textField == self.passwordConfirmTextField)
		{
			if (![self.passwordTextField.text isEqualToString:self.passwordConfirmTextField.text])
			{
				[self setErrorWithKey:@"passwordConfirm" message:@"Senhas não conferem." overwriteCurrentError:YES];
			}
			/*else
			{
				[self removeErrorWithKey:@"passwordConfirm"];
			}*/
		}
	}
}

#pragma mark - PickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (pickerView == self.taxPickerView){
		return self.taxInformationTypes.count + 1;
	}
	else{
		return self.states.count + 1;
	}
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (row == 0)
	{
		return @"-";
	}
	else{
		if (pickerView == self.taxPickerView){
			return self.taxInformationTypes[row - 1];
		}
		else{
			return self.states[row - 1];
		}
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if (pickerView == self.taxPickerView){
		if (row == 0){
			if (self.taxInformationTextField.text.length > 0 && ![self.taxInformationTextField.text isEqualToString:self.taxInformationTypes.lastObject]){
				[self.taxInformationTextField setText:@""];
				
				if ([self.tableView numberOfRowsInSection:1] == 7){
					NSMutableArray *formElementGroup = self.businessFormElementGroups.lastObject;
					[formElementGroup removeObjectAtIndex:2];
					[formElementGroup removeObjectAtIndex:1];
					
					[self.stateTextField setText:@""];
					[self.statePickerView selectRow:0 inComponent:0 animated:NO];
					[self.stateRegistrationTextField setText:@""];
					
					[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1],
															 [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
				}
				else if ([self.tableView numberOfRowsInSection:1] == 6){
					NSMutableArray *formElementGroup = self.businessFormElementGroups.lastObject;
					[formElementGroup removeObjectAtIndex:1];
					
					[self.stateTextField setText:@""];
					[self.statePickerView selectRow:0 inComponent:0 animated:NO];
					
					[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
				}
			}
			else{
				[self.taxInformationTextField setText:@""];
			}
		}
		else if (row == 3){
			if (self.taxInformationTextField.text.length > 0 && ![self.taxInformationTextField.text isEqualToString:self.taxInformationTypes.lastObject]){
				[self.taxInformationTextField setText:self.taxInformationTypes[row - 1]];
				
				[self.stateRegistrationTextField setText:@""];
				
				if ([self.tableView numberOfRowsInSection:1] == 7){
					NSMutableArray *formElementGroup = self.businessFormElementGroups.lastObject;
					[formElementGroup removeObjectAtIndex:2];
					[formElementGroup removeObjectAtIndex:1];
					
					[self.stateTextField setText:@""];
					[self.statePickerView selectRow:0 inComponent:0 animated:NO];
					[self.stateRegistrationTextField setText:@""];
					
					[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1],
															 [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
				}
				else if ([self.tableView numberOfRowsInSection:1] == 6){
					NSMutableArray *formElementGroup = self.businessFormElementGroups.lastObject;
					[formElementGroup removeObjectAtIndex:1];
					
					[self.stateTextField setText:@""];
					[self.statePickerView selectRow:0 inComponent:0 animated:NO];
					
					[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
				}
			}
			else{
				[self.taxInformationTextField setText:self.taxInformationTypes[row - 1]];
			}
		}
		else{
			if (self.taxInformationTextField.text.length == 0 || [self.taxInformationTextField.text isEqualToString:self.taxInformationTypes.lastObject]){
				[self.taxInformationTextField setText:self.taxInformationTypes[row - 1]];
				
				NSMutableArray *formElementGroup = self.businessFormElementGroups.lastObject;
				[formElementGroup insertObject:[B2WFormElement formElementWithKey:@"state" textField:self.stateTextField error:@""] atIndex:1];
				
				[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
			}
			else{
				[self.taxInformationTextField setText:self.taxInformationTypes[row - 1]];
			}
		}
	}
	else{
		if (row == 0){
			if (self.stateTextField.text.length > 0){
				[self.stateTextField setText:@""];
				[self.statePickerView selectRow:0 inComponent:0 animated:NO];
				
				NSMutableArray *formElementGroup = self.businessFormElementGroups.lastObject;
				[formElementGroup removeObjectAtIndex:2];
				
				[self.stateRegistrationTextField setText:@""];
				
				[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
			}
			else{
				[self.stateTextField setText:@""];
				[self.statePickerView selectRow:0 inComponent:0 animated:NO];
			}
		}
		else{
			if (self.stateTextField.text.length == 0){
				[self.stateTextField setText:self.states[row - 1]];
				
				NSMutableArray *formElementGroup = self.businessFormElementGroups.lastObject;
				[formElementGroup insertObject:[B2WFormElement formElementWithKey:@"stateInscription" textField:self.stateRegistrationTextField error:@""] atIndex:2];
				
				[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
			}
			else{
				[self.stateTextField setText:self.states[row - 1]];
			}
		}
	}
}

#pragma mark - Networking

- (void)registerNewCustomer
{
    void (^completion)(id, NSError *) = ^(id object, NSError *error) {
		[self.navigationItem setRightBarButtonItem:[self continueBarItem] animated:YES];
		[self.tableView setUserInteractionEnabled:YES];
		
		NSDictionary *localizedDescription = (NSDictionary *)error.localizedDescription;
		
		if ([localizedDescription isKindOfClass:[NSString class]])
		{
			[UIAlertView showAlertViewWithTitle:(NSString *)localizedDescription];
		}
		else
		// if ([localizedDescription isKindOfClass:[NSDictionary class]])
		{
			NSString *errorCode = localizedDescription[@"errorCode"];
		
			if ([errorCode isEqualToString:@"409"]) // email ja cadastrado
			{
				[self setErrorWithKey:@"email" message:@"Email já cadastrado." overwriteCurrentError:YES];
			}
			else
			{
				if (localizedDescription && (! [localizedDescription.allKeys containsObject:@"validationErrors"])) // erro do servidor
				{
					[UIAlertView showAlertViewWithTitle:localizedDescription[@"message"]];
				}
				else // é possível ter erro de validação
				{
					NSMutableArray *validationErrors = [[NSMutableArray alloc] initWithArray:localizedDescription[@"validationErrors"]];
					
					
					// TODO: Rever tratamento para a v4
					{
						NSPredicate *pred = [NSPredicate predicateWithFormat:@"fieldName CONTAINS %@", @"address"];
						[validationErrors removeObjectsInArray:[validationErrors filteredArrayUsingPredicate:pred]];
						
						// usando valor placeholder no request para nao conflitar com telefone
						//pred = [NSPredicate predicateWithFormat:@"fieldName == %@", @"number"];
						//[validationErrors removeObjectsInArray:[validationErrors filteredArrayUsingPredicate:pred]];
						
						pred = [NSPredicate predicateWithFormat:@"fieldName == %@", @"neighborhood"];
						[validationErrors removeObjectsInArray:[validationErrors filteredArrayUsingPredicate:pred]];
						
						pred = [NSPredicate predicateWithFormat:@"fieldName == %@", @"city"];
						[validationErrors removeObjectsInArray:[validationErrors filteredArrayUsingPredicate:pred]];
						
						pred = [NSPredicate predicateWithFormat:@"fieldName == %@", @"zipCode"];
						[validationErrors removeObjectsInArray:[validationErrors filteredArrayUsingPredicate:pred]];
						
						pred = [NSPredicate predicateWithFormat:@"fieldName == %@", @"name"];
						[validationErrors removeObjectsInArray:[validationErrors filteredArrayUsingPredicate:pred]];
						
						pred = [NSPredicate predicateWithFormat:@"fieldName == %@", @"reference"];
						[validationErrors removeObjectsInArray:[validationErrors filteredArrayUsingPredicate:pred]];
					}
					
					
					if (validationErrors.count == 0) // não há erro de validação
					{
						[self performSegueWithIdentifier:@"AddressSegue" sender:nil];
					}
					else  // há erro de validação pela API
					{
						[self showValidationErrors:validationErrors];
					}
				}
			}
		}
    };
	
	[self.navigationItem setRightBarButtonItem:[self loadingBarItem] animated:YES];
	[self.tableView setUserInteractionEnabled:NO];
    
    B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
	
	[B2WAPICustomer setPersistenceEnabled:NO];
	
	if (self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual)
	{
		[[B2WAccountManager currentCustomer] createWithAddress:nil block:completion];
	}
	else
	{
		[[B2WAccountManager currentCustomer] createWithAddress:customerManager.address block:completion];
	}
}

- (void)checkEmailAvailability
{
    B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
    
    if (self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual)
    {
        customerManager.customerType = CustomerTypeIndividual;
        
        [customerManager setupCustomerWithEmptyValues];
        
        customerManager.individualCustomer.email = self.emailTextField.text;
    }
    else
    {
        customerManager.customerType = CustomerTypeBusiness;
        
        [customerManager setupCustomerWithEmptyValues];
		
        customerManager.businessCustomer.email = self.emailTextField.text;
    }
    
    void (^completion)(id, NSError *) = ^(id object, NSError *error) {
		NSDictionary *localizedDescription = (NSDictionary *)error.localizedDescription;
		
		if ([localizedDescription isKindOfClass:[NSDictionary class]])
		{
			NSString *errorCode = localizedDescription[@"errorCode"];
			
			if ([errorCode isEqualToString:@"409"]) // email ja cadastrado
			{
				[self setErrorWithKey:@"email" message:@"Email já cadastrado." overwriteCurrentError:YES];
			}
			else // email disponivel
			{
				[self setErrorWithKey:@"email" message:@"" overwriteCurrentError:YES];
			}
		}
    };
	
	[B2WAPICustomer setPersistenceEnabled:NO];
	
	[[B2WAccountManager currentCustomer] createWithAddress:nil block:completion];
}

#pragma mark - Customer Manager

- (void)refreshFormWithCustomer:(B2WCustomer *)customer
{
	if ([customer isKindOfClass:[B2WIndividualCustomer class]])
	{
		[self refreshFormWithIndividualCustomer:(B2WIndividualCustomer *)customer];
	}
	else
	{
		[self refreshFormWithBusinessCustomer:(B2WBusinessCustomer *)customer];
	}
}

- (void)refreshFormWithIndividualCustomer:(B2WIndividualCustomer *)customer
{
	self.customerTypeSegmentedControl.selectedSegmentIndex = CustomerTypeIndividual;
	
	self.passwordTextField.text = customer.password;
	self.passwordConfirmTextField.text = customer.password;
	
	self.emailTextField.text = customer.email;
	self.nameTextField.text = customer.fullName;
	self.genderSegmentedControl.selectedSegmentIndex = customer.gender;
	self.CPFCNPJTextField.text = customer.cpf;
	self.birthDateTextField.text = customer.birthDate;
	self.phoneTextField.text = customer.mainPhone;
}

- (void)refreshFormWithBusinessCustomer:(B2WBusinessCustomer *)customer
{
	self.customerTypeSegmentedControl.selectedSegmentIndex = CustomerTypeBusiness;
	
	self.passwordTextField.text = customer.password;
	self.passwordConfirmTextField.text = customer.password;
	
	self.emailTextField.text = customer.email;
	self.corporateTextField.text = customer.corporateName;
	self.nameTextField.text = customer.responsibleName;
	self.CPFCNPJTextField.text = customer.cnpj;
	self.phoneTextField.text = customer.mainPhone;
}

- (void)setIndividualCustomerFromForm
{
	B2WIndividualCustomer *customer = (B2WIndividualCustomer *)[B2WAccountManager currentCustomer];
	customer.email = self.emailTextField.text;
	customer.password = self.passwordTextField.text;
	customer.fullName = self.nameTextField.text;
	customer.gender = self.genderSegmentedControl.selectedSegmentIndex;
	customer.cpf = self.CPFCNPJTextField.text;
	customer.mainPhone = self.phoneTextField.text;
	customer.birthDate = self.birthDateTextField.text;
	
	if (customer.fullName.length < 3)
	{
		customer.nickname = @"...";
	}
	else
	{
		customer.nickname = [self.nameTextField.text componentsSeparatedByString:@" "].firstObject;
	}
}

- (void)setBusinessCustomerFromForm
{
	B2WBusinessCustomer *customer = (B2WBusinessCustomer *)[B2WAccountManager currentCustomer];
	customer.corporateName = self.corporateTextField.text;
	customer.responsibleName = self.nameTextField.text;
	customer.cnpj = self.CPFCNPJTextField.text;
	customer.mainPhone = self.phoneTextField.text;
	customer.email = self.emailTextField.text;
	customer.password = self.passwordTextField.text;
	customer.IERecipientindicator = [self.taxInformationTypes indexOfObject:self.taxInformationTextField.text];
	customer.stateInscription = self.stateRegistrationTextField.text;
	
	NSString *state = self.stateTextField.text;
	if (state.length == 0) state = @"RJ"; // Placeholder caso a pessoa júridica seja isenta de impostos
	
	B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
	B2WAddress *address = [customerManager address];
	[customerManager setupAddressWithEmptyValues];
	address.state = state;
	address.number = @"000000"; // Placeholder para API do Customer-v2 não ter conflito de keys
}

#pragma mark - Errors

- (void)removeErrorWithKey:(NSString *)key
{
	[self setErrorWithKey:key message:@"" overwriteCurrentError:YES];
}

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
		
		if ([fieldKey isEqualToString:@"number"] || [fieldKey isEqualToString:@"ddd"])
		{
			fieldKey = @"phone";
		}
		
		[self setErrorWithKey:fieldKey message:message overwriteCurrentError:NO];
	}
}

#pragma mark - Custom

- (NSIndexPath *)indexPathForTextField:(UITextField *)textField
{
	NSArray *formElementGroups = self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual ? self.individualFormElementGroups : self.businessFormElementGroups;
	
	for (NSArray *formElementGroup in formElementGroups)
	{
		B2WFormElement *formElement = [formElementGroup filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.textField == %@", textField]].firstObject;
		
		if (formElement)
		{
			return [NSIndexPath indexPathForRow:[formElementGroup indexOfObject:formElement] inSection:[formElementGroups indexOfObject:formElementGroup]];
		}
	}
	
	return nil;
}

- (B2WFormElement *)formElementForTextField:(UITextField *)textField
{
	NSArray *formElementGroups = self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual ? self.individualFormElementGroups : self.businessFormElementGroups;
	
	for (NSArray *formElementGroup in formElementGroups)
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
	NSArray *formElementGroups = self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual ? self.individualFormElementGroups : self.businessFormElementGroups;
	
	for (NSArray *formElementGroup in formElementGroups)
	{
		B2WFormElement *formElement = [formElementGroup filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.key == %@", key]].firstObject;
		
		if (formElement)
		{
			return formElement;
		}
	}
	
	return nil;
}

- (void)removeErrors
{
	NSArray *formElementGroups = self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual ? self.individualFormElementGroups : self.businessFormElementGroups;
	
	for (NSArray *formElementGroup in formElementGroups)
	{
		for (B2WFormElement *formElement in formElementGroup)
		{
			[self setErrorWithKey:formElement.key message:@"" overwriteCurrentError:YES];
		}
	}
}

- (void)resetForm
{
	[self removeErrors];
	
	[self.emailTextField setText:@""];
	[self.passwordTextField setText:@""];
	[self.passwordConfirmTextField setText:@""];
	[self.genderSegmentedControl setSelectedSegmentIndex:0];
	[self.taxInformationTextField setText:@""];
	[self.stateTextField setText:@""];
	[self.stateRegistrationTextField setText:@""];
	[self.nameTextField setText:@""];
	[self.corporateTextField setText:@""];
	[self.CPFCNPJTextField setText:@""];
	[self.birthDateTextField setText:@""];
	[self.phoneTextField setText:@""];
	
	[self.taxPickerView selectRow:0 inComponent:0 animated:NO];
	[self.statePickerView selectRow:0 inComponent:0 animated:NO];
}

- (void)loadStates
{
	self.states = [NSMutableArray new];
	
	NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle B2WKitBundle] pathForResource:@"estados-cidades" ofType:@"json"]];
	
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
	
	for (NSDictionary *stateDictionary in dictionary[@"estados"])
	{
		NSString *state = stateDictionary[@"sigla"];
		
		[self.states addObject:state];
	}
	
	[self.states sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj1 caseInsensitiveCompare:obj2];
	}];
}

- (UIBarButtonItem *)continueBarItem
{
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"Continuar" style:UIBarButtonItemStyleDone target:self action:@selector(confirmButtonPressed)];
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

- (IBAction)segmentedControlValueChangedAction:(UISegmentedControl *)sender
{
	if (self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual)
	{
		[self.nameTextField setPlaceholder:@"Nome completo"];
		[self.CPFCNPJTextField setPlaceholder:@"CPF"];
	}
	else
	{
		[self.nameTextField setPlaceholder:@"Responsável"];
		[self.CPFCNPJTextField setPlaceholder:@"CNPJ"];
	}
	
	if ([self.tableView numberOfRowsInSection:1] == 7)
	{
		NSMutableArray *formElementGroup = self.businessFormElementGroups.lastObject;
		[formElementGroup removeObjectAtIndex:2];
		[formElementGroup removeObjectAtIndex:1];
		
		[self.stateTextField setText:@""];
		[self.statePickerView selectRow:0 inComponent:0 animated:NO];
		[self.stateRegistrationTextField setText:@""];
		
		[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1],
												 [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	else if ([self.tableView numberOfRowsInSection:1] == 6)
	{
		NSMutableArray *formElementGroup = self.businessFormElementGroups.lastObject;
		[formElementGroup removeObjectAtIndex:1];
		
		[self.stateTextField setText:@""];
		[self.statePickerView selectRow:0 inComponent:0 animated:NO];
		
		[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1],
											 [NSIndexPath indexPathForRow:1 inSection:1],
											 [NSIndexPath indexPathForRow:2 inSection:1],
											 [NSIndexPath indexPathForRow:3 inSection:1],
											 [NSIndexPath indexPathForRow:4 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self resetForm];
}

- (IBAction)cancelBarButtonAction:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmButtonPressed
{
	[self.tableView endEditing:YES];
    
	NSArray *formElementGroups = self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual ? self.individualFormElementGroups : self.businessFormElementGroups;
	
	for (NSArray *formElementGroup in formElementGroups)
	{
		for (B2WFormElement *formElement in formElementGroup)
		{
			if (formElement.textField && formElement.textField.text.length == 0)
			{
				[self setErrorWithKey:formElement.key message:kEmptyFieldError overwriteCurrentError:YES];
			}
		}
	}
	
	for (NSArray *formElementGroup in formElementGroups)
	{
		for (B2WFormElement *formElement in formElementGroup)
		{
			if (formElement.error.length > 0)
			{
				[self.tableView scrollToRowAtIndexPath:[self indexPathForTextField:formElement.textField] atScrollPosition:UITableViewScrollPositionTop animated:YES];
				return;
			}
		}
	}
	
	if (self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual)
	{
		[self setIndividualCustomerFromForm];
	}
	else
	{
		[self setBusinessCustomerFromForm];
	}
	
	[self registerNewCustomer];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddressSegue"])
	{
        B2WAddressFormViewController *addressFormViewController = (B2WAddressFormViewController *) segue.destinationViewController;
        addressFormViewController.accountCreationDelegate = self.accountCreationDelegate;
    }
}

@end
