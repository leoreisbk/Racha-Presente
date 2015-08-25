//
//  B2WCollectionViewFlowLayoutProvider.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WAPIClient.h"
#import "B2WCollectionViewFlowLayoutProvider.h"

@implementation B2WCollectionViewFlowLayoutProvider

+ (UIImage*)imageForLayoutType:(B2WCollectionLayoutType)type
{
    NSString *imgName;
    switch (type) {
        case B2WCollectionLayoutTypeGrid:
            imgName = @"icn-grid.png";
            break;
        case B2WCollectionLayoutTypeList:
            imgName = @"icn-list.png";
            break;
        default:
            break;
    }
    
    return [UIImage imageNamed:imgName];
}

+ (UINib*)nibForLayoutType:(B2WCollectionLayoutType)type
{
    NSString *nibName;
    switch (type) {
        case B2WCollectionLayoutTypeGrid:
            nibName = [[B2WAPIClient brandCode] stringByAppendingString:@"ProductCell"];
            break;
        case B2WCollectionLayoutTypeList:
            nibName = [[B2WAPIClient brandCode] stringByAppendingString:@"ProductListCell"];
            break;
        default:
            break;
    }
    
    return [UINib nibWithNibName:nibName bundle:nil];
}

+ (UICollectionViewFlowLayout*)layoutForLayoutType:(B2WCollectionLayoutType)type
{
    switch (type) {
        case B2WCollectionLayoutTypeGrid:
            return [B2WCollectionViewFlowLayoutProvider gridCollectionViewFlowLayout];
            break;
            
        case B2WCollectionLayoutTypeList:
            return [B2WCollectionViewFlowLayoutProvider listCollectionViewFlowLayout];
            break;
        default:
            break;
    }
    return [B2WCollectionViewFlowLayoutProvider gridCollectionViewFlowLayout];
}

+ (UICollectionViewFlowLayout*)gridCollectionViewFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize                    = CGSizeMake(159.5, 214);
    layout.minimumLineSpacing          = 1;
    layout.minimumInteritemSpacing     =  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 1 : 0.75;
    
    layout.sectionInset = UIEdgeInsetsZero;
    
    return layout;
}

+ (UICollectionViewFlowLayout*)listCollectionViewFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize                    = CGSizeMake(320, 100);
    layout.minimumLineSpacing          = 1;
    layout.minimumInteritemSpacing     = 1;
    
    layout.sectionInset                = UIEdgeInsetsZero;
    
    return layout;
}

@end
