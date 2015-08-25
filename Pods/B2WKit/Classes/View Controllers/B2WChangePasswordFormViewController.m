//
//  B2WChangePasswordFormViewController.m
//  B2WKit
//
//  Created by Caio Mello on 22/10/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WChangePasswordFormViewController.h"

#import "B2WFormCell.h"
#import "B2WFormElement.h"

#import "B2WCustomerValidator.h"

#import <UICKeyChainStore/UICKeyChainStore.h>

@interface B2WChangePasswordFormViewController ()

@property (nonatomic, strong) IBOutlet UITextField *currentPasswordTextField;

@property (nonatomic, strong) IBOutlet UITextField *passwordNewTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordConfirmTextField;

@property (nonatomic, strong) NSArray *formElementGroups;

@end

@implementation B2WChangePasswordFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.formElementGroups = @[@[[B2WFormElement formElementWithKey:@"password" textField:self.currentPasswordTextField error:@""]],
							   @[[B2WFormElement formElementWithKey:@"newPassword" textField:self.passwordNewTextField error:@""],
								 [B2WFormElement formElementWithKey:@"passwordConfirm" textField:self.passwordConfirmTextField error:@""]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	B2WFormElement *formElement = self.formElementGroups[indexPath.section][indexPath.row];
	
	if (formElement.textField && formElement.error.length > 0)
	{
		B2WFormCell *cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
		
		CGRect errorTextRect = [formElement.error boundingRectWithSize:CGSizeMake(cell.errorLabel.bounds.size.width - 10, 50000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cell.errorLabel.font} context:nil];
		return 8 + cell.textField.bounds.size.height + 8 + errorTextRect.size.height + 7; // Top marging + text field height + spacing + error label height + bottom marging
	}
	
	return 54;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	B2WFormElement *formElement = self.formElementGroups[indexPath.section][indexPath.row];
	
	B2WFormCell *formCell = (B2WFormCell *)cell;
	[formCell.errorLabel setText:formElement.error];
	[formCell.errorLabel setHidden:formElement.error.length == 0];
	[formCell.errorImageView setHidden:formElement.error.length == 0]; formCell.errorImageView.image = [B2WAccountManager alertImage];
}

- (void)updatePassword
{
	NSString *username = [B2WAPIAccount username];
	NSString *newPassword = self.passwordNewTextField.text;
	
	void (^completion)(id, NSError *) = ^(id object, NSError *error) {
		//[self.navigationItem setRightBarButtonItem:[self continueBarItem] animated:YES];
		
		[self.tableView setUserInteractionEnabled:YES];
		
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
				
				if (validationErrors.count == 0) // não há erro de validação
				{
					[B2WAPIAccount setPassword:newPassword];
					
					[self.navigationController popViewControllerAnimated:YES];
					
					[UIAlertView showAlertViewWithTitle:@"Senha alterada com sucesso!"];
				}
				else  // há erro de validação pela API
				{
					[self showValidationErrors:validationErrors];
				}
			}
		}
	};
	
	//[self.navigationItem setRightBarButtonItem:[self loadingBarItem] animated:YES];
	[self.tableView setUserInteractionEnabled:NO];
	
	[B2WAPIAccount updatePasswordForUserNamed:username newPassword:newPassword block:completion];
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
		
		[self setErrorWithKey:fieldKey message:message overwriteCurrentError:NO];
	}
}

#pragma mark - Custom

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

#pragma mark - TextField

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	B2WFormElement *formElement = [self formElementForTextField:textField];
	
	[self setErrorWithKey:formElement.key message:textField.text.length > 0 ? @"" : kEmptyFieldError overwriteCurrentError:YES];
	
	if (textField.text.length > 0)
	{
		if (textField == self.currentPasswordTextField)
		{
			NSString *currentPassword = self.currentPasswordTextField.text;
			
			if (![currentPassword isEqualToString:[B2WAPIAccount password]])
			{
				[self setErrorWithKey:@"password" message:@"Senha incorreta." overwriteCurrentError:YES];
			}
		}
		else if (textField == self.passwordNewTextField)
		{
			PasswordValidation validationResult = [textField.text isValidPassword];
			
			if (validationResult == PasswordValidationErrorTooShort)
			{
				[self setErrorWithKey:@"newPassword" message:@"Senha muito curta." overwriteCurrentError:YES];
			}
			else if (validationResult == PasswordValidationErrorTooLong)
			{
				[self setErrorWithKey:@"newPassword" message:@"Senha muito longa." overwriteCurrentError:YES];
			}
			/*else
			{
				[self removeErrorWithKey:@"newPassword"];
			}*/
		}
		else if (textField == self.passwordConfirmTextField)
		{
			if (![self.passwordNewTextField.text isEqualToString:self.passwordConfirmTextField.text])
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

#pragma mark - Actions

- (IBAction)confirmButtonPressed:(id)sender
{
	[self.tableView endEditing:YES];
	
	for (NSArray *formElementGroup in self.formElementGroups)
	{
		for (B2WFormElement *formElement in formElementGroup)
		{
			if (formElement.textField && formElement.textField.text.length == 0)
			{
				[self setErrorWithKey:formElement.key message:kEmptyFieldError overwriteCurrentError:YES];
			}
		}
	}
	
	for (NSArray *formElementGroup in self.formElementGroups)
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
	
	if (![self.passwordNewTextField.text isEqualToString:self.passwordConfirmTextField.text])
	{
		[self setErrorWithKey:@"passwordConfirm" message:@"Senhas não conferem." overwriteCurrentError:YES];
		return;
	}
	
	[self updatePassword];
}

@end
