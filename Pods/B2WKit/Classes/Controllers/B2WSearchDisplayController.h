//
//  B2WSearchDisplayController.h
//  B2WKit
//
//  Created by Thiago Peres on 23/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol B2WSearchDisplayControllerDelegate <NSObject>
@required

/**
 Tells the delegate that the user either selected a search
 suggestion term or that he performed a search with that term.
 
 @param term The selected search term.
 */
- (void)didSelectSuggestionTerm:(NSString*)term;

/**
 Tells the delegate that the display controller failed to fetch
 search suggestions.
 
 @param error The error object containing the reason search suggestions
 could not be fetched.
 */
- (void)didFailLoadingSuggestionsWithError:(NSError*)error;

@end

@interface B2WSearchDisplayController : UISearchDisplayController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>

/**
 The delegate object to receive update events.
 */
@property (nonatomic, weak) IBOutlet id <B2WSearchDisplayControllerDelegate> suggestionDelegate;

@property (nonatomic, weak) IBOutlet id <UISearchDisplayDelegate> searchDisplayDelegate;

@property (nonatomic, weak) IBOutlet id <UISearchBarDelegate> searchBarDelegate;

- (void)setDimmingViewHidden:(BOOL)hidden;

@end
