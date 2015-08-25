//
//  B2WAddressTableViewCell.h
//  B2WKit
//
//  Created by Caio Mello on 05/08/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface B2WAddressTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UILabel *additionalInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *cityStateLabel;
@property (nonatomic, strong) IBOutlet UILabel *postalCodeLabel;

@end
