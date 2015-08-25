//
//  B2WCollectionViewFlowLayoutProvider.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, B2WCollectionLayoutType) {
    B2WCollectionLayoutTypeNone,
    B2WCollectionLayoutTypeGrid,
    B2WCollectionLayoutTypeList
};

typedef NS_ENUM(NSInteger, B2WCollectionLayoutOrientation) {
    B2WCollectionLayoutOrientationPortrait,
    B2WCollectionLayoutOrientationLandscape,
};

@interface B2WCollectionViewFlowLayoutProvider : NSObject

+ (UICollectionViewFlowLayout*)gridCollectionViewFlowLayout;
+ (UICollectionViewFlowLayout*)listCollectionViewFlowLayout;
+ (UICollectionViewFlowLayout*)layoutForLayoutType:(B2WCollectionLayoutType)type;
+ (UINib*)nibForLayoutType:(B2WCollectionLayoutType)type;
+ (UIImage*)imageForLayoutType:(B2WCollectionLayoutType)type;

@end
