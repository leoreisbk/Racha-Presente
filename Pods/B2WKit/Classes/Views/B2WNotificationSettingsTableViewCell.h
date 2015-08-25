//
//  B2WNotificationSettingsTableViewCell.h
//  B2WKit
//
//  Created by Flávio Caetano on 4/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface B2WNotificationSettingsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, readwrite) BOOL loading;

@end
