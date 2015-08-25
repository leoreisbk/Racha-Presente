//
//  B2WCreditCardTableViewCell.h
//  B2WKit
//
//  Created by rodrigo.fontes on 15/07/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <B2WCreditCard.h>

@interface B2WCreditCardTableViewCell : UITableViewCell

@property (nonatomic, strong) B2WCreditCard *creditCard;

@property (nonatomic, weak) IBOutlet UIImageView *cardImage;
@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@end
