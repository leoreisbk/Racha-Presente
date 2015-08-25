//
//  B2WCreditCardTableViewCell.m
//  B2WKit
//
//  Created by rodrigo.fontes on 15/07/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WCreditCardTableViewCell.h"
#import <B2WAPIPayment.h>
#import <B2WAccountManager.h>

@implementation B2WCreditCardTableViewCell

-(void)setCreditCard:(B2WCreditCard *)creditCard
{
    NSString *bin = [creditCard.number substringWithRange:NSMakeRange(0, 6)];
    [B2WAPIPayment requestCreditCardIdWithBin:bin block:^(id object, NSError *error) {
        
        NSString *brandID = [object valueForKey:@"id"];
        [UIView transitionWithView:self.cardImage
                          duration:kAnimationDuration
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{[self.cardImage setImage:[B2WAccountManager cardImageForBrand:brandID]];}
                        completion:NULL];
        
        
    }];
    
    [self.numberLabel setText:[creditCard.number maskedCardNumberString]];
    [self.nameLabel setText:creditCard.holderName];
    [self.dateLabel setText:[NSString stringWithFormat:@"%lu/%lu", (unsigned long)creditCard.expirationMonth, (unsigned long)creditCard.expirationYear]];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.cardImage.image = nil;
}

@end
