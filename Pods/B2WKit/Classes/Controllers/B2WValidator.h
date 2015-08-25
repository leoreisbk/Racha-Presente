//
//  B2WCardValidator.h
//  B2WKit
//
//  Created by Thiago Peres on 12/8/12.
//  Copyright (c) 2012 Eduardo Callado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface B2WValidator : NSObject

@end

@interface NSString (Masks)

- (NSString *)stringByRemovingMask;

@end
