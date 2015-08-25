//
//  B2WProductFreightCalculatorResultCell.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WProductFreightCalculatorResultCell.h"

@implementation B2WProductFreightCalculatorResultCell

- (void)setFreightCalculationResult:(B2WFreightCalculationProduct *)freightCalculationResult
{
	_freightCalculationResult = freightCalculationResult;
    self.productFreightCalculatorDaysLabel.text = self.freightCalculationResult.daysString;
    self.productFreightCalculatorPriceLabel.text = self.freightCalculationResult.priceString;
}

- (void)setProductFreightCalculatorResult:(NSMutableAttributedString *)productFreightCalculatorResult
{
    _productFreightCalculatorResult = productFreightCalculatorResult;
    if (productFreightCalculatorResult)
    {
        [self hideLoadingMessage];
        self.productFreightCalculatorResultLabel.attributedText = productFreightCalculatorResult;
    }
    else
    {
        [self showLoadingMessage];
    }
}

- (void)showLoadingMessage
{
    self.loading.hidden = NO;
    [self.loading startAnimating];
    self.productFreightCalculatorResultLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@"    Calculando frete..."];
}

- (void)hideLoadingMessage
{
    self.loading.hidden = YES;
    [self.loading stopAnimating];
    self.productFreightCalculatorResultLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
}

@end
