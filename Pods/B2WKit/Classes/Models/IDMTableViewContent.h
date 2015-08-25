//
//  TPTableViewContent.h
//  Katapakote
//
//  Created by Thiago Peres on 12/21/11.
//  Copyright (c) 2011 Thiago Peres. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNoIdentifier @"noId"
#define kCellKey @"cell"
#define kCellsKey @"cells"
#define kTitleKey @"title"
#define kCellIdKey @"cellId"

@interface NSMutableArray (IDMTableViewContent)

// Creating
- (NSInteger)addSectionWithTitle:(NSString*)title;
- (void)addSectionAtIndex:(NSInteger)section title:(NSString*)title;
- (void)addSection;

// Adding cells
- (void)addCell:(id)cell;
- (void)addCell:(id)cell withIdentifier:(NSString*)identifier;
- (void)addCell:(id)cell forSection:(NSInteger)section;
- (void)addCell:(id)cell forSection:(NSInteger)section withIdentifier:(NSString*)identifier;
- (void)addCell:(id)cell forSection:(NSInteger)section atIndex:(NSInteger)index;
- (void)addCell:(id)cell forSection:(NSInteger)section atIndex:(NSInteger)index withIdentifier:(NSString*)identifier;
- (void)addCells:(NSArray*)cells forSection:(NSInteger)section;

// Retrieving
- (NSArray*)allCells;

- (BOOL)containsCellWithIdentifier:(NSString*)identifier;
- (id)cellForIdentifier:(NSString*)identifier;
- (NSArray*)cellsForIdentifier:(NSString*)identifier;

- (NSString*)titleForSection:(NSInteger)section;
- (NSMutableArray*)cellsForSection:(NSInteger)section;
- (NSInteger)sectionForCellWithIdentifier:(NSString*)identifier;
- (NSInteger)numberOfCellsForSection:(NSInteger)section;

- (id)cellForSection:(NSInteger)section row:(NSInteger)row;
- (id)cellForIndexPath:(NSIndexPath*)indexPath;

- (NSIndexPath*)indexPathForCell:(id)cell;
- (NSIndexPath*)indexPathForIdentifier:(NSString*)identifier;

- (NSString*)identifierForIndexPath:(NSIndexPath*)indexPath;

// Removing
- (void)removeCellsForSection:(NSInteger)section;
- (void)removeCellforSection:(NSInteger)section atIndex:(NSInteger)index;
- (void)removeCellforSection:(NSInteger)section withIdentifier:(NSString*)identifier;
- (void)removeSectionAtIndex:(NSInteger)section;
- (void)removeAllSections;

@end
