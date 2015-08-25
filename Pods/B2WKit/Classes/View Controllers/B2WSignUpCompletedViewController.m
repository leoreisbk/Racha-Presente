//
//  B2WSignUpCompletedViewController.m
//  B2WKit
//
//  Created by Eduardo Callado on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WSignUpCompletedViewController.h"

@interface B2WSignUpCompletedViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) IBOutlet UIButton *confirmButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;

@end


@implementation B2WSignUpCompletedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationController.navigationBar setBarTintColor:nil];
	[self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
	[self.navigationController.navigationBar setTintColor:[B2WAccountManager sharedManager].appPrimaryColor];
	[self.view setTintColor:[B2WAccountManager sharedManager].appPrimaryColor];
	
	[self.backgroundImageView setImage:[B2WAccountManager sharedManager].oneClickBackgroundImage];
	[self.titleLabel setText:[B2WAccountManager sharedManager].oneClickTitle];
	[self.titleLabel setTextColor:[B2WAccountManager sharedManager].appTextColor];
	[self.subtitleLabel setTextColor:[B2WAccountManager sharedManager].appTextColor];
	[self.confirmButton setTitle:[NSString stringWithFormat:@"Ativar %@", [B2WAccountManager sharedManager].oneClickBrandName] forState:UIControlStateNormal];
	[self.confirmButton setBackgroundImage:[UIImage imageWithColor:[B2WAccountManager sharedManager].appSecondaryColor] forState:UIControlStateNormal];
	[self.cancelButton setTintColor:[B2WAccountManager sharedManager].appThirdColor];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackScreenView"
														object:self
													  userInfo:@{@"screenName" : @"Cadastro - Finalizado"}];
}

#pragma mark - Actions

- (IBAction)cancelButtonAction:(UIButton *)sender
{
	[B2WAccountManager sharedManager].isCreatingNewAccount = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackEvent"
														object:self
													  userInfo:@{@"category" : @"ui_action",
																 @"action" : @"button_press",
																 @"label" : @"one_click_not_now",
																 @"value" : @""}];
	
	[self.delegate SignUpCompletedViewControllerDidCancel:self];
}

- (IBAction)confirmButtonAction:(UIButton *)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackEvent"
														object:self
													  userInfo:@{@"category" : @"ui_action",
																 @"action" : @"button_press",
																 @"label" : @"one_click_activate",
																 @"value" : @""}];
	
	[self.delegate SignUpCompletedViewControllerDidConfirm:self];
}

@end
