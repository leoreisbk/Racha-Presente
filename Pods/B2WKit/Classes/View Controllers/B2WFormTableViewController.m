//
//  B2WFormTableViewController.m
//  B2WKit
//
//  Created by Caio Mello on 08/08/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WFormTableViewController.h"

typedef NS_ENUM(NSInteger, SHOPDefaultCellPosition) {
	SHOPDefaultCellPositionTop,
	SHOPDefaultCellPositionMiddle,
    SHOPDefaultCellPositionBottom,
    SHOPDefaultCellPositionUnique
};

@interface B2WFormTableViewController ()

@end

@implementation B2WFormTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureAppearance];
}

#pragma mark - General

- (void)configureAppearance
{
	// FloatLabeled appearance
	[[JVFloatLabeledTextField appearance] setFloatingLabelTextColor:[UIColor lightGrayColor]];
	[[JVFloatLabeledTextField appearance] setFloatingLabelFont:[UIFont systemFontOfSize:14]];
	
	// self.tableView.separatorColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView setCornerForCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView setCornerForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	/*if ([B2WAccountManager sharedManager].useRoundedBorder)
	{
		cell.backgroundColor = [UIColor clearColor];
		
		UIView *cornerBackgroundView = [cell viewWithTag:1001];
		
		if (! cornerBackgroundView)
		{
			cornerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 320-20, cell.frame.size.height)];
			cornerBackgroundView.backgroundColor = [UIColor whiteColor];
			cornerBackgroundView.tag = 1001;
			[cell insertSubview:cornerBackgroundView atIndex:0];
		}
		else
		{
			cornerBackgroundView.frame = CGRectMake(10, 0, 320-20, cell.frame.size.height);
		}
		
		NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
		SHOPDefaultCellPosition position = [self getCellPositionForIndexPath:indexPath
													 withTotalCellsInSection:numberOfRows];
		
		int radius = 3;
		
		[cornerBackgroundView setMaskRoundCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight
										   radius:0];
		
		switch (position)
		{
			case SHOPDefaultCellPositionUnique:
				[cornerBackgroundView setMaskRoundCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight
												   radius:radius];
				break;
			case SHOPDefaultCellPositionTop:
				[cornerBackgroundView setMaskRoundCorners:UIRectCornerTopLeft|UIRectCornerTopRight
												   radius:radius];
				break;
			case SHOPDefaultCellPositionMiddle:
				//[cornerBackgroundView setMaskRoundCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight
				//                         radius:0];
				break;
			case SHOPDefaultCellPositionBottom:
				[cornerBackgroundView setMaskRoundCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
												   radius:radius];
				break;
		}
	}
	else*/
	{
		cell.backgroundColor = [UIColor whiteColor];
	}
}

- (SHOPDefaultCellPosition)getCellPositionForIndexPath:(NSIndexPath *)indexPath withTotalCellsInSection:(NSInteger)cellsInSection
{
    SHOPDefaultCellPosition position = SHOPDefaultCellPositionUnique;
	
    if (cellsInSection == 1)
    {
        position = SHOPDefaultCellPositionUnique;
    }
    else if (cellsInSection == 2)
    {
        position = indexPath.row == 0 ? SHOPDefaultCellPositionTop : SHOPDefaultCellPositionBottom;
    }
    else if (cellsInSection > 2)
    {
        if (indexPath.row == 0)
        {
            position = SHOPDefaultCellPositionTop;
        }
        else if (indexPath.row == cellsInSection - 1)
        {
            position = SHOPDefaultCellPositionBottom;
        }
        else
        {
            position = SHOPDefaultCellPositionMiddle;
        }
    }
    
    return position;
}

@end
