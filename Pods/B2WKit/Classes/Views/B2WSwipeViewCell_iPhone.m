//
//  B2WSwipeViewCell_iPhone.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WSwipeViewCell_iPhone.h"
#import "B2WAPIClient.h"

@implementation B2WSwipeViewCell_iPhone

+ (id)new
{
	UINib *nib = [UINib nibWithNibName:@"B2WSwipeViewCell_iPhone" bundle:nil];
	return [nib instantiateWithOwner:self options:nil].firstObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSString *nibName = [[B2WAPIClient brandCode] stringByAppendingString:@"ProductHomeCell_iPhone"];
    self.swipeViewNib = [UINib nibWithNibName:nibName bundle:nil];
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
	return CGSizeMake(136, 214);
}

- (UIImage *)defaultImageForRatingStar
{
    return [UIImage imageNamed:@"icn-star.png"];
}

- (UIImage *)highlitedImageForRatingStar
{
    return [UIImage imageNamed:@"icn-star-highlighted.png"];
}

@end
