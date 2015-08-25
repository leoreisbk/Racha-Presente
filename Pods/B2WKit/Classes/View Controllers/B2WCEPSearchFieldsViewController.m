//
//  B2WCEPSearchFieldsViewController.m
//  B2WKit
//
//  Created by Caio Mello on 30/09/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WCEPSearchFieldsViewController.h"

@interface B2WCEPSearchFieldsViewController () <UITextFieldDelegate>

@end

@implementation B2WCEPSearchFieldsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	if (textField == self.cityTextField){
		NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
		[textField setText:text];
		
		[self.delegate cityTextFieldDidChange:text];
		
		return NO;
	}
	
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
	[self.delegate searchFieldDidClear];
	
	return YES;
}

@end
