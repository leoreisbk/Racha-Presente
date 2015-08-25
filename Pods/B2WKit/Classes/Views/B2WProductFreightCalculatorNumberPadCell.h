//
//  B2WProductFreightCalculatorNumberPadCell.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "B2WProductFreightCalculatorNumberPadProtocol.h"

@interface B2WProductFreightCalculatorNumberPadCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *zeroButton;
@property (weak, nonatomic) IBOutlet UIButton *oneButton;
@property (weak, nonatomic) IBOutlet UIButton *twoButton;
@property (weak, nonatomic) IBOutlet UIButton *threeButton;
@property (weak, nonatomic) IBOutlet UIButton *fourButton;
@property (weak, nonatomic) IBOutlet UIButton *fiveButton;
@property (weak, nonatomic) IBOutlet UIButton *sixButton;
@property (weak, nonatomic) IBOutlet UIButton *sevenButton;
@property (weak, nonatomic) IBOutlet UIButton *eightButton;
@property (weak, nonatomic) IBOutlet UIButton *nineButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *calculateButton;
@property (strong, nonatomic) id<B2WProductFreightCalculatorNumberPadProtocol> delegate;

- (IBAction)freightCalculatorNumberPadButtonPressed:(id)sender;

@end
