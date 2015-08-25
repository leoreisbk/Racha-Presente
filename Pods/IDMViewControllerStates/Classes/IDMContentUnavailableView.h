//
//  ACOMPlaceholderView.h
//  Americanas
//
//  Created by Rodrigo Fontes on 1/7/14.
//  Copyright (c) 2014 Ideais. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^IDMReloadButtonPressedBlock)(void);

@interface IDMContentUnavailableView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (strong, nonatomic) IDMReloadButtonPressedBlock reloadButtonPressedBlock;

- (void)showWithTitle:(NSString*)title
              message:(NSString*)message
reloadButtonPressedBlock:(IDMReloadButtonPressedBlock)block;

- (void)showWithTitle:(NSString*)title
              message:(NSString*)message
		  buttonTitle:(NSString *)buttonTitle
reloadButtonPressedBlock:(IDMReloadButtonPressedBlock)block;

- (void)show;
- (void)dismiss;

@end
