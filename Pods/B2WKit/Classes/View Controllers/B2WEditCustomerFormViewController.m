//
//  B2WEditCustomerFormViewController.m
//  B2WKit
//
//  Created by Caio Mello on 22/10/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WEditCustomerFormViewController.h"

#import "B2WCustomerValidator.h"

#import "B2WFormCell.h"
#import "B2WFormElement.h"

#import "UIViewController+States.h"

typedef NS_ENUM(NSInteger, FormRow){
	FormRowGender,
	FormRowTaxInformation,
	FormRowStateRegistration,
	FormRowCorporate,
	FormRowName,
	FormRowBirthDate,
	FormRowPhone
};

@interface B2WEditCustomerFormViewController ()

@property (nonatomic, strong) IBOutlet UISegmentedControl *genderSegmentedControl;
@property (nonatomic, strong) IBOutlet UITextField *taxInformationTextField;
@property (nonatomic, strong) IBOutlet UITextField *stateRegistrationTextField;
@property (nonatomic, strong) IBOutlet UITextField *corporateTextField;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *birthDateTextField;
@property (nonatomic, strong) IBOutlet UITextField *phoneTextField;

@property (nonatomic, strong) UIPickerView *taxPickerView;
@property (nonatomic, strong) UIPickerView *statePickerView;

@property (nonatomic, strong) NSArray *individualFormElementGroups;
@property (nonatomic, strong) NSArray *businessFormElementGroups;

@property (nonatomic, strong) NSMutableArray *states;
@property (nonatomic, strong) NSArray *taxInformationTypes;

@property (nonatomic, assign) BOOL shouldShowCustomerInfo;

@end

@implementation B2WEditCustomerFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationItem.rightBarButtonItem setTitle:@"Salvar"];
	
	self.individualFormElementGroups = @[@[[B2WFormElement formElementWithKey:nil textField:nil error:nil],
										   [B2WFormElement formElementWithKey:nil textField:nil error:nil]],
										 @[[B2WFormElement formElementWithKey:nil textField:nil error:nil],
										   [B2WFormElement formElementWithKey:@"fullName" textField:self.nameTextField error:@""],
										   [B2WFormElement formElementWithKey:@"birthday" textField:self.birthDateTextField error:@""],
										   [B2WFormElement formElementWithKey:@"phone" textField:self.phoneTextField error:@""]]];
	
	self.businessFormElementGroups = @[@[[B2WFormElement formElementWithKey:nil textField:nil error:nil],
										 [B2WFormElement formElementWithKey:nil textField:nil error:nil]],
									   @[[B2WFormElement formElementWithKey:@"indicatorIERecipient" textField:self.taxInformationTextField error:@""],
										 [B2WFormElement formElementWithKey:@"stateInscription" textField:self.stateRegistrationTextField error:@""],
										 [B2WFormElement formElementWithKey:@"corporateName" textField:self.corporateTextField error:@""],
										 [B2WFormElement formElementWithKey:@"responsibleName" textField:self.nameTextField error:@""],
										 [B2WFormElement formElementWithKey:@"phone" textField:self.phoneTextField error:@""]].mutableCopy];
	
	// [[B2WAccountManager sharedManager] setCustomerType:CustomerTypeBusiness];
	
	[self.nameTextField setPlaceholder:[B2WAccountManager sharedManager].customerType == CustomerTypeIndividual ? @"Nome completo" : @"Responsável"];
	
	[self refreshFormWithCustomer:[B2WAccountManager currentCustomer]];
	
	[self requestCustomerInfomation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Networking

- (void)updateCustomerInformation
{
	void (^completion)(id, NSError *) = ^(id object, NSError *error) {
		[self.navigationItem setRightBarButtonItem:[self saveBarItem] animated:YES];
		
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
						[UIAlertView showAlertViewWithTitle:@"Dados atualizados com sucesso!"];
						
						[self dismissViewControllerAnimated:YES completion:nil];
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
	
	[B2WAPICustomer setPersistenceEnabled:YES];
	
	[[B2WAccountManager currentCustomer] updateWithBlock:completion];
}

#pragma mark - Requests

- (void)requestCustomerInfomation
{
	[self.navigationItem setRightBarButtonItem:[self loadingBarItem] animated:YES];
	
	[self.loadingView show];

	[B2WAPICustomer requestWithMethod:@"GET" resource:B2WAPICustomerResourceNone resourceIdentifier:nil parameters:nil block:^(NSArray *object, NSError *error) {
		
		[self.loadingView dismiss];
		
		if (error)
		{
			[self.tableView setUserInteractionEnabled:YES];
			
			NSString *title   = kDefaultConnectionErrorTitle;
			NSString *message = kDefaultConnectionErrorMessage;
			
			[self.contentUnavailableView showWithTitle:title message:message buttonTitle:@"Tentar novamente" reloadButtonPressedBlock:^() {
				[self.contentUnavailableView dismiss];
				[self.loadingView show];
				[self requestCustomerInfomation];
			}];
		}
		else
		{
			B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
			
			B2WCustomer *customer = object.firstObject;
			
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
			
			[self refreshFormWithCustomer:customer];
			
			if (!self.shouldShowCustomerInfo){
				self.shouldShowCustomerInfo = YES;
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
			}
		}
		
		[self.navigationItem setRightBarButtonItem:[self saveBarItem] animated:YES];
	}];
}

#pragma mark - Customer Manager

/*- (void)refreshFormWithCustomer:(B2WCustomer *)customer
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
}*/

- (void)setIndividualCustomerFromForm
{
	B2WIndividualCustomer *customer = (B2WIndividualCustomer *)[B2WAccountManager currentCustomer];
	//customer.email = self.emailTextField.text;
	//customer.password = self.passwordTextField.text;
	customer.fullName = self.nameTextField.text;
	customer.gender = self.genderSegmentedControl.selectedSegmentIndex;
	//customer.cpf = self.CPFCNPJTextField.text;
	customer.mainPhone = self.phoneTextField.text;
	customer.birthDate = self.birthDateTextField.text;
	
	// TODO: Testar se o tratamento abaixo resolve o problema de usuários sem apelidos cadastrados
	if (customer.nickname.length == 0)
	{
		customer.nickname = [self.nameTextField.text componentsSeparatedByString:@" "].firstObject;
	}
	
	/*if (customer.fullName.length < 3)
	{
		customer.nickname = @"...";
	}
	else
	{
		customer.nickname = [self.nameTextField.text componentsSeparatedByString:@" "].firstObject;
	}*/
}

- (void)setBusinessCustomerFromForm
{
	B2WBusinessCustomer *customer = (B2WBusinessCustomer *)[B2WAccountManager currentCustomer];
	customer.corporateName = self.corporateTextField.text;
	customer.responsibleName = self.nameTextField.text;
	//customer.cnpj = self.CPFCNPJTextField.text;
	customer.mainPhone = self.phoneTextField.text;
	//customer.email = self.emailTextField.text;
	//customer.password = self.passwordTextField.text;
	customer.IERecipientindicator = [self.taxInformationTypes indexOfObject:self.taxInformationTextField.text];
	customer.stateInscription = self.stateRegistrationTextField.text;
	
	/*NSString *state = self.stateTextField.text;
	if (state.length == 0) state = @"RJ"; // Placeholder caso a pessoa júridica seja isenta de impostos
	
	B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
	B2WAddress *address = [customerManager address];
	[customerManager fillUpAddressWithEmptyValues];
	address.state = state;
	address.number = @"000000"; // Placeholder para API do Customer-v2 não ter conflito de keys*/
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
	NSArray *formElementGroups = [B2WAccountManager sharedManager].customerType == CustomerTypeIndividual ? self.individualFormElementGroups : self.businessFormElementGroups;
	
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

- (B2WFormElement *)formElementForTextField:(UITextField *)textField{
	NSArray *formElementGroups = [B2WAccountManager sharedManager].customerType == CustomerTypeIndividual ? self.individualFormElementGroups : self.businessFormElementGroups;
	
	for (NSArray *formElementGroup in formElementGroups){
		B2WFormElement *formElement = [formElementGroup filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.textField == %@", textField]].firstObject;
		
		if (formElement){
			return formElement;
		}
	}
	
	return nil;
}

- (B2WFormElement *)formElementForKey:(NSString *)key{
	NSArray *formElementGroups = [B2WAccountManager sharedManager].customerType == CustomerTypeIndividual ? self.individualFormElementGroups : self.businessFormElementGroups;
	
	for (NSArray *formElementGroup in formElementGroups){
		B2WFormElement *formElement = [formElementGroup filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.key == %@", key]].firstObject;
		
		if (formElement){
			return formElement;
		}
	}
	
	return nil;
}

- (UIBarButtonItem *)saveBarItem
{
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"Salvar" style:UIBarButtonItemStyleDone target:self action:@selector(saveBarButtonAction:)];
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
	NSArray *formElementGroups = [B2WAccountManager sharedManager].customerType == CustomerTypeIndividual ? self.individualFormElementGroups : self.businessFormElementGroups;
	
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
	
	//[self.emailTextField setText:@""];
	//[self.passwordTextField setText:@""];
	//[self.passwordConfirmTextField setText:@""];
	[self.genderSegmentedControl setSelectedSegmentIndex:0];
	[self.taxInformationTextField setText:@""];
	//[self.stateTextField setText:@""];
	[self.stateRegistrationTextField setText:@""];
	[self.nameTextField setText:@""];
	[self.corporateTextField setText:@""];
	//[self.CPFCNPJTextField setText:@""];
	[self.birthDateTextField setText:@""];
	[self.phoneTextField setText:@""];
	
	[self.taxPickerView selectRow:0 inComponent:0 animated:NO];
	[self.statePickerView selectRow:0 inComponent:0 animated:NO];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (!self.shouldShowCustomerInfo)
	{
		return 1;
	}
	
	return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 1)
	{
		NSArray *formElementGroups = [B2WAccountManager sharedManager].customerType == CustomerTypeIndividual ? self.individualFormElementGroups : self.businessFormElementGroups;
		
		return [formElementGroups[section] count];
	}
	
	return [super tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{
		return 44;
	}
	else if (indexPath.section == 1)
	{
		B2WFormElement *formElement = [B2WAccountManager sharedManager].customerType == CustomerTypeIndividual ? self.individualFormElementGroups[indexPath.section][indexPath.row] : self.businessFormElementGroups[indexPath.section][indexPath.row];
		
		if (formElement.textField && formElement.error.length > 0)
		{
			B2WFormCell *cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
			
			CGRect errorTextRect = [formElement.error boundingRectWithSize:CGSizeMake(cell.errorLabel.bounds.size.width - 10, 50000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cell.errorLabel.font} context:nil];
			return 8 + cell.textField.bounds.size.height + 8 + errorTextRect.size.height + 7; // Top marging + text field height + spacing + error label height + bottom marging
		}
	}
	
	return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	B2WFormElement *formElement = [B2WAccountManager sharedManager].customerType == CustomerTypeIndividual ? self.individualFormElementGroups[indexPath.section][indexPath.row] : self.businessFormElementGroups[indexPath.section][indexPath.row];
	
	B2WFormCell *cell;
	
	if (indexPath.section == 1)
	{
		if ([B2WAccountManager sharedManager].customerType == CustomerTypeIndividual)
		{
			if (indexPath.row > 0)
			{
				cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
				switch (indexPath.row) {
					case 0: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowGender inSection:indexPath.section]]; break;
					case 1: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowName inSection:indexPath.section]]; break;
					case 2: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowBirthDate inSection:indexPath.section]]; break;
					case 3: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowPhone inSection:indexPath.section]]; break;
					default: break;
				}
			}
		}
		else
		{
			switch (indexPath.row) {
				case 0: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowTaxInformation inSection:indexPath.section]]; break;
				case 1: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowStateRegistration inSection:indexPath.section]]; break;
				case 2: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowCorporate inSection:indexPath.section]]; break;
				case 3: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowName inSection:indexPath.section]]; break;
				case 4: cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:FormRowPhone inSection:indexPath.section]]; break;
				default: break;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	B2WFormElement *formElement = [B2WAccountManager sharedManager].customerType == CustomerTypeIndividual ? self.individualFormElementGroups[indexPath.section][indexPath.row] : self.businessFormElementGroups[indexPath.section][indexPath.row];
	
	B2WFormCell *formCell = (B2WFormCell *)cell;
	[formCell.errorLabel setText:formElement.error];
	[formCell.errorLabel setHidden:formElement.error.length == 0];
	[formCell.errorImageView setHidden:formElement.error.length == 0]; formCell.errorImageView.image = [B2WAccountManager alertImage];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0)
	{
		/*if (indexPath.row == 0)
		{
			[self performSegueWithIdentifier:@"ChangeEmailSegue" sender:nil];
		}
		else if (indexPath.row == 1)
		{
			[self performSegueWithIdentifier:@"ChangePasswordSegue" sender:nil];
		}*/
		
		[self performSegueWithIdentifier:@"ChangePasswordSegue" sender:nil];
	}
}

#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *finalText = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	/*if (textField == self.CPFCNPJTextField)
	{
		if (self.customerTypeSegmentedControl.selectedSegmentIndex == CustomerTypeIndividual)
			[textField setText:finalText.maskedCPFString];
		else
			[textField setText:finalText.maskedCNPJString];
		
		return NO;
	}
	else*/ if (textField == self.birthDateTextField)
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
	
	/*if (textField.text.length > 0)
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
				[self setErrorWithKey:@"password" message:@"Senha muito curta" overwriteCurrentError:YES];
			}
			else if (validationResult == PasswordValidationErrorTooLong)
			{
				[self setErrorWithKey:@"password" message:@"Senha muito longa" overwriteCurrentError:YES];
			}
			else
			{
				[self removeErrorWithKey:@"password"];
			}
		}
		else if (textField == self.passwordConfirmTextField)
		{
			if (![self.passwordTextField.text isEqualToString:self.passwordConfirmTextField.text])
			{
				[self setErrorWithKey:@"passwordConfirm" message:@"Senhas não conferem" overwriteCurrentError:YES];
			}
			else
			{
				[self removeErrorWithKey:@"passwordConfirm"];
			}
		}
	}*/
}

#pragma mark - Custom

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
	self.nameTextField.text = customer.fullName;
	self.genderSegmentedControl.selectedSegmentIndex = customer.gender;
	self.birthDateTextField.text = customer.birthDate;
	self.phoneTextField.text = customer.mainPhone;
}

- (void)refreshFormWithBusinessCustomer:(B2WBusinessCustomer *)customer
{
	self.taxInformationTextField.text = [NSString stringWithFormat:@"%ld", customer.IERecipientindicator];
	self.stateRegistrationTextField.text = customer.stateInscription;
	self.corporateTextField.text = customer.corporateName;
	self.nameTextField.text = customer.responsibleName;
	self.phoneTextField.text = customer.mainPhone;
}

#pragma mark - Actions

- (IBAction)cancelBarButtonAction:(UIBarButtonItem *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveBarButtonAction:(UIBarButtonItem *)sender
{
	[self.tableView endEditing:YES];
	
	NSArray *formElementGroups = [B2WAccountManager sharedManager].customerType == CustomerTypeIndividual ? self.individualFormElementGroups : self.businessFormElementGroups;
	
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
	
	if ([B2WAccountManager sharedManager].customerType == CustomerTypeIndividual)
	{
		[self setIndividualCustomerFromForm];
	}
	else
	{
		[self setBusinessCustomerFromForm];
	}
	
	[self updateCustomerInformation];
}

@end
