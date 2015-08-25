//
//  B2WCreditCardCVVViewController.m
//  
//
//  Created by Caio Mello on 7/6/15.
//
//

#import "B2WCreditCardCVVViewController.h"

@interface B2WCreditCardCVVViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@end

@implementation B2WCreditCardCVVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.imageView setImage:self.image];
	[self.titleLabel setText:self.instructions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
