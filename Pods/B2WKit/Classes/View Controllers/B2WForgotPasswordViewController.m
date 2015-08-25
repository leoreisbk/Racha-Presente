//
//  B2WForgotPasswordViewController.m
//  B2WKit
//
//  Created by Caio Mello on 25/08/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WForgotPasswordViewController.h"

#import "IDMUtils.h"

#import "B2WAPIAccount.h"

#import <SVProgressHUD/SVProgressHUD.h>

#import "B2WAccountManager.h"

@interface B2WForgotPasswordViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;

@end

@implementation B2WForgotPasswordViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.view setTintColor:[B2WAccountManager sharedManager].appPrimaryColor];
	
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[self.activityIndicator setColor:self.view.tintColor];
	
	UIBarButtonItem *activityIndicatorItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
	[self.navigationItem setRightBarButtonItem:activityIndicatorItem];
	
	[self.emailTextField setText:self.email];
	
	UIView *textFieldContainerView = self.emailTextField.superview;
	[textFieldContainerView.layer applyShadow];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *finalText = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	[textField setText:finalText];
	
	[self.sendButton setEnabled:self.emailTextField.text.length > 0];
	
	return NO;
}

#pragma mark - Actions

- (IBAction)sendButtonAction:(UIButton *)sender
{
	if (self.emailTextField.text.length == 0)
	{
		[UIAlertView showAlertViewWithTitle:@"Preencha o campo Email"];
		return;
	}
	
	if ([self.emailTextField.text rangeOfString:@"@"].location == NSNotFound)
	{
		[UIAlertView showAlertViewWithTitle:@"Email inválido"];
		return;
	}
	
	if ([self.emailTextField.text rangeOfString:@" "].location != NSNotFound)
	{
		[UIAlertView showAlertViewWithTitle:@"Email inválido"];
		return;
	}
	
	// [SVProgressHUD showWithStatus:@"Enviando Email..."];
	
	[self.activityIndicator startAnimating];
	[self.sendButton setEnabled:NO];
	
	[B2WAPIAccount requestPasswordRetrievalForUsernamed:self.emailTextField.text block:^(id object, NSError *error) {
		/*NSData *data = [error.localizedDescription dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
		 NSDictionary *localizedDescription = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
		 //NSString *errorCode = data ? localizedDescription[@"errorCode"] : nil;*/
		
		[SVProgressHUD dismiss];
		
		if (error)
		{
			if ([error.localizedDescription isKindOfClass:[NSString class]])
			{
				[UIAlertView showAlertViewWithTitle:error.localizedDescription];
			}
			else
			{
				NSDictionary *localizedDescription = (NSDictionary *)error.localizedDescription;
				
				NSMutableArray *validationErrors = [[NSMutableArray alloc] initWithArray:localizedDescription[@"validationErrors"]];
				
				if (validationErrors.count == 0)
				{
					[UIAlertView showAlertViewWithTitle:localizedDescription[@"message"]];
				}
				else
				{
					[UIAlertView showAlertViewWithTitle:validationErrors[0][@"message"]];
				}
			}
		}
		else
		{
			NSString *message = [NSString stringWithFormat:@"Enviamos um email para %@ com as instruções para recuperar sua senha. Caso você não receba o email em alguns minutos, verifique sua caixa de spam ou envie seu email novamente.", self.emailTextField.text];
			
			[UIAlertView showAlertViewWithTitle:@"Email Enviado" message:message];
			
			[self.navigationController popToRootViewControllerAnimated:YES];
		}
		
		[self.activityIndicator stopAnimating];
		[self.sendButton setEnabled:YES];
	}];
}

@end
