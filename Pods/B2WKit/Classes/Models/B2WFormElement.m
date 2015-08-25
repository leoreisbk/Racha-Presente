//
//  B2WFormElement.m
//  B2WKit
//
//  Created by Caio Mello on 27/08/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WFormElement.h"

@implementation B2WFormElement

+ (B2WFormElement *)formElementWithKey:(NSString *)key textField:(UITextField *)textField error:(NSString *)error{
	B2WFormElement *formElement = [B2WFormElement new];
	[formElement setKey:key];
	[formElement setTextField:textField];
	[formElement setError:error];
	return formElement;
}

@end
