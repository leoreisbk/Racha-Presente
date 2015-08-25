//
//  B2WCEPSearchFieldsViewController.h
//  B2WKit
//
//  Created by Caio Mello on 30/09/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CEPSearchFieldsDelegate <NSObject>

- (void)cityTextFieldDidChange:(NSString *)text;
- (void)searchFieldDidReturn:(UITextField *)textField;
- (void)searchFieldDidClear;

@end

@interface B2WCEPSearchFieldsViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UITextField *addressTextField;
@property (nonatomic, strong) IBOutlet UITextField *cityTextField;

@property (nonatomic, weak) id<CEPSearchFieldsDelegate> delegate;

@end
