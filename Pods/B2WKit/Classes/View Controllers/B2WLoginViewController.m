//
//  B2WLoginViewController.m
//  B2WKit
//
//  Created by Eduardo Callado on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WLoginViewController.h"
#import "B2WForgotPasswordViewController.h"
#import "IDMUtils.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface B2WLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;

@property (nonatomic, strong) IBOutlet UIButton *enterButton;

@end


@implementation B2WLoginViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userSignInFailedNotification:)
												 name:@"UserSignInFailed"
											   object:nil];
	
	[self.navigationController.navigationBar setBarTintColor:nil];
	[self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
	[self.navigationController.navigationBar setTintColor:[B2WAccountManager sharedManager].appPrimaryColor];
	[self.view setTintColor:[B2WAccountManager sharedManager].appPrimaryColor];
	
	[self.navigationItem setTitle:[NSString stringWithFormat:@"Login %@", [B2WAccountManager sharedManager].brandName]];
	
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[self.activityIndicator setColor:self.view.tintColor];
	
	UIBarButtonItem *activityIndicatorItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
	[self.navigationItem setRightBarButtonItem:activityIndicatorItem];
	
	[self.enterButton setEnabled:NO];
	
	UIView *textFieldContainerView = self.emailTextField.superview;
	[textFieldContainerView.layer applyShadow];
	
	if ([[B2WAccountManager sharedManager].brandName isEqualToString:@"Shoptime"])
	{
		self.emailTextField.placeholder = @"Email ou CPF/CNPJ";
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.emailTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *finalText = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if (textField == self.emailTextField)
	{
		[self.enterButton setEnabled:(finalText.length > 0 && self.passwordTextField.text.length > 0)];
	}
	else if (textField == self.passwordTextField)
	{
		[self.enterButton setEnabled:(self.emailTextField.text.length > 0 && finalText.length > 0)];
	}
	
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	[self.enterButton setEnabled:NO];
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.emailTextField)
	{
		[self.passwordTextField becomeFirstResponder];
	}
	else
	{
		[self signIn];
	}
	
	return YES;
}

#pragma mark - Custom

- (void)signIn
{
	[self.emailTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];
	
	self.emailTextField.text = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if (self.emailTextField.text.length == 0 || self.passwordTextField.text.length == 0)
	{
		[UIAlertView showAlertViewWithTitle:@"Preencha os campos Email e Senha"];
		return;
	}
	
	if (! [[B2WAccountManager sharedManager].brandName isEqualToString:@"Shoptime"])
	{
		if ([self.emailTextField.text rangeOfString:@"@"].location == NSNotFound)
		{
			[UIAlertView showAlertViewWithTitle:@"Email inválido"];
			return;
		}
	}
	
	if ([self.emailTextField.text rangeOfString:@" "].location != NSNotFound)
	{
		[UIAlertView showAlertViewWithTitle:@"Email inválido"];
		return;
	}
	
	[self.activityIndicator startAnimating];
	
	[self.emailTextField setEnabled:NO];
	[self.passwordTextField setEnabled:NO];
	
	[self.enterButton setEnabled:NO];
	
	[B2WAccountManager loginUserWithEmail:self.emailTextField.text password:self.passwordTextField.text];
}

#pragma mark - Actions

- (void)userSignInFailedNotification:(NSNotification *)notification
{
	[self.activityIndicator stopAnimating];
	
	[self.emailTextField setEnabled:YES];
	[self.passwordTextField setEnabled:YES];
	
	[self.enterButton setEnabled:YES];
}

- (IBAction)forgotButtonAction:(UIButton *)sender
{
	[self.emailTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];
	
	[self performSegueWithIdentifier:@"ForgotPasswordSegue" sender:nil];
}

- (IBAction)cancelButtonAction:(UIButton *)sender
{
	[self.delegate loginViewControllerDidCancel:self];
}

- (IBAction)enterButtonAction:(UIButton *)sender
{
	[self signIn];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ForgotPasswordSegue"])
	{
		B2WForgotPasswordViewController *destination = segue.destinationViewController;
		[destination setEmail:self.emailTextField.text];
	}
}

@end
