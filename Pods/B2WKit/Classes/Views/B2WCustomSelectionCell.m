//
//  B2WCustomSelectionCell.m
//  B2WKit
//
//  Created by Caio Mello on 25/08/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WCustomSelectionCell.h"

@implementation B2WCustomSelectionCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
	[super setHighlighted:highlighted animated:animated];
	
	if (highlighted){
		[self setAlpha:0.8];
	}
	else{
		[self setAlpha:1];
	}
}

@end
