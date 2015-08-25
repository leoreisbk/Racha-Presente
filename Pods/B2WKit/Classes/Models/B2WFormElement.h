//
//  B2WFormElement.h
//  B2WKit
//
//  Created by Caio Mello on 27/08/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface B2WFormElement : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSString *error;

+ (B2WFormElement *)formElementWithKey:(NSString *)key textField:(UITextField *)textField error:(NSString *)error;

@end
