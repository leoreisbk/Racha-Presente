//
//  B2WNotificationSettingsViewController.h
//  B2WKit
//
//  Created by Flávio Caetano on 4/11/14.
//  Copyright (c) 2014 Ideais. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface B2WNotificationSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UILabel *helpTextLabel;

@end
