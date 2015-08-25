//
//  B2WProductFreightCalculatorButtonsCell.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "B2WProductFreightCalculatorButtonsProtocol.h"

@interface B2WProductFreightCalculatorButtonsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *calculateButton;
@property (weak, nonatomic) IBOutlet UIButton *recalculateButton;
@property (strong, nonatomic) id<B2WProductFreightCalculatorButtonsProtocol> delegate;

- (IBAction)calculateButtonPressed:(id)sender;
- (IBAction)recalculateButtonPressed:(id)sender;

@end
