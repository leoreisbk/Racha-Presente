//
//  B2WNotificationSettingsTableViewCell.m
//  B2WKit
//
//  Created by Flávio Caetano on 4/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WNotificationSettingsTableViewCell.h"

@interface B2WNotificationSettingsTableViewCell ()

@end

@implementation B2WNotificationSettingsTableViewCell

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    
    if (self.loading)
    {
        [self.activityIndicator startAnimating];
    }
    else
    {
        [self.activityIndicator stopAnimating];
    }
    
    self.switchView.hidden = self.activityIndicator.isAnimating;
}

@end
