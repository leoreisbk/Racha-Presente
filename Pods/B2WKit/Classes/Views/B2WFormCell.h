//
//  B2WFormCell.h
//  B2WKit
//
//  Created by Caio Mello on 19/08/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface B2WFormCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) IBOutlet UIImageView *errorImageView;

@end
