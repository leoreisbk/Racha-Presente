//
//  B2W.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "B2WFreightCalculationProduct.h"

@interface B2WProductFreightCalculatorResultCell : UITableViewCell

@property (strong, nonatomic) B2WFreightCalculationProduct *freightCalculationResult;

@property (strong, nonatomic) IBOutlet UILabel *productFreightCalculatorDaysLabel;
@property (strong, nonatomic) IBOutlet UILabel *productFreightCalculatorPriceLabel;

@property (strong, nonatomic) NSMutableAttributedString *productFreightCalculatorResult;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UILabel *productFreightCalculatorResultLabel;

@end
