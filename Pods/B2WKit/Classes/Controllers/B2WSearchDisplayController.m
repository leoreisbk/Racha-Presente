//
//  B2WSearchDisplayController.m
//  B2WKit
//
//  Created by Thiago Peres on 23/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WSearchDisplayController.h"
#import "B2WAPISearch.h"
#import "B2WSearchHistoryManager.h"

@implementation UIView (viewRecursion)

- (NSMutableArray*)allSubViews
{
    NSMutableArray *subviews = [[NSMutableArray alloc] init];
    [subviews addObject:self];
    
    for (UIView *subview in self.subviews)
    {
        [subviews addObjectsFromArray:(NSArray*)[subview allSubViews]];
    }
    
    return subviews;
}

- (BOOL)isInPopover
{
    UIView *currentView = self;
    
    while( currentView )
    {
        NSString *classNameOfCurrentView = NSStringFromClass([currentView class]);
        NSLog( @"CLASS-DETECTED: %@", classNameOfCurrentView );
        NSString *searchString = @"UIPopoverView";
        if ( [classNameOfCurrentView rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound )
        {
            return YES;
        }
        currentView = currentView.superview;
    }
    
    return NO;
}

@end

@implementation NSString (customHighlighting)

- (NSAttributedString*)attributedStringByHighlightingTerms:(NSArray*)terms
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self];
    for (__strong NSString *term in terms)
    {
        //
        // Remove diacritic accents and special marks
        // and lowercases the string
        //
        NSData *data = [term dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        term = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        term = [term lowercaseString];
        
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:term
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        
        if (!error)
        {
            NSArray *allMatches = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
            for (NSTextCheckingResult *aMatch in allMatches)
            {
                [string addAttribute:NSFontAttributeName
                                         value:[UIFont boldSystemFontOfSize:16]
                                         range:[aMatch range]];
            }
        }
    }
    return string;
}

@end

@interface B2WSearchDisplayController ()

@property (nonatomic, strong) NSArray *suggestions;
@property (nonatomic, strong) NSTimer *requestTimer;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end

@implementation B2WSearchDisplayController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.searchResultsDataSource     = self;
    self.searchResultsDelegate       = self;
    self.delegate                    = self;
    self.searchBar.delegate          = self;
    
    //
    // We handle the cancel button behavior manually when it's
    // displayed in a navigation bar
    //
    self.searchBar.showsCancelButton = !self.displaysSearchBarInNavigationBar;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchHistoryDidChange)
                                                 name:B2WSearchHistoryManagerDidAddSearchTermNotification
                                               object:nil];
}

- (void)searchHistoryDidChange
{
    [self.searchResultsTableView reloadData];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    //[aSearchBar resignFirstResponder];
    
    if (aSearchBar.text.length > 0)
    {
        [self _didSelectSearchTerm:aSearchBar.text];
    }
    
    // Forwarding the method call
    if (self.searchBarDelegate && [self.searchBarDelegate respondsToSelector:_cmd])
    {
        [self.searchBarDelegate performSelector:_cmd withObject:aSearchBar];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Forwarding the method call
    if (self.searchBarDelegate && [self.searchBarDelegate respondsToSelector:_cmd])
    {
        [self.searchBarDelegate performSelector:_cmd withObject:searchBar];
    }
}

- (void)setDimmingViewHidden:(BOOL)hidden
{
    // Stores the dimming view alpha;
    static CGFloat dimmingViewAlpha = 0.0f;
    
    //
    // Hacks UISearchDisplayController behavior to show search history
    //
    UIView *targetView = self.searchContentsController.view;
    
    for (UIView *view in [targetView allSubViews])
    {
        if ([view isKindOfClass:NSClassFromString(@"UISearchResultsTableView")])
        {
            [view.superview.superview bringSubviewToFront:view.superview];
        }
        if ([view isKindOfClass:NSClassFromString(@"_UISearchDisplayControllerDimmingView")])
        {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                dimmingViewAlpha = view.alpha;
            });
            CGFloat alpha = hidden ? 0.0f : dimmingViewAlpha;
            
            [view setAlpha: alpha];
            [view setHidden: hidden];
            
            //
            // Corrects the diming view frame frame when placed inside
            // a UINavigationBar
            //
            if (self.displaysSearchBarInNavigationBar)
            {
                CGRect dimmingFrame = view.frame;
                dimmingFrame.origin.y = self.searchBar.frame.origin.y;
                dimmingFrame.size.height = self.searchContentsController.view.frame.size.height - dimmingFrame.origin.y;
                view.superview.frame = dimmingFrame;
            }
            
            break;
        }
    }
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    if (self.displaysSearchBarInNavigationBar)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    [self _removeLoadingView];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [self _adjustSearchResultsTableViewFrame];
    self.suggestions = [NSArray array];
    
	NSArray *historyArray = [B2WSearchHistoryManager history];
    if (historyArray.count > 0)
    {
        [self.searchResultsTableView setHidden:NO];
        [self setDimmingViewHidden:YES];
        [self.searchResultsTableView setUserInteractionEnabled:YES];
    }
    [self.searchResultsTableView reloadData];
    
    self.searchResultsTableView.scrollEnabled = YES;
    
    //
    // Adds cancel button when it's contained in a navigation bar
    //
    if (self.displaysSearchBarInNavigationBar == YES)
    {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Cancelar"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(_cancelSearchButtonPressed)];
        [self.navigationItem setRightBarButtonItem:item animated:YES];
    }
    
    // Forwards the method call
    if (self.searchDisplayDelegate && [self.searchDisplayDelegate respondsToSelector:_cmd])
    {
        [self.searchDisplayDelegate performSelector:_cmd withObject:controller];
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.searchResultsTableView.hidden = YES;
    if (self.displaysSearchBarInNavigationBar)
    {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
    
    // Forwards the method call
    if (self.searchDisplayDelegate && [self.searchDisplayDelegate respondsToSelector:_cmd])
    {
        [self.searchDisplayDelegate performSelector:_cmd withObject:controller];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //
    // Fixes a glitch in which the search results table view would go down 20 pixels for no reason when displayed insided a UIPopover
    //
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [self.searchResultsTableView isInPopover])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect bounds = self.searchResultsTableView.frame;
            bounds.origin.y = -20;
            [self.searchResultsTableView setFrame:bounds];
        });
    }
    
    if (searchString.length == 0)
    {
        self.suggestions = [NSArray array];
        [self setDimmingViewHidden:NO];
        return YES;
    }
    
    if (searchString.length >= 2)
    {
        //
        // Invalidates an existing timer
        // and request
        //
        if (self.requestTimer)
        {
            [self.requestTimer invalidate];
            self.requestTimer = nil;
        }
        
        if (self.requestOperation && self.requestOperation.isExecuting)
        {
            //[self.requestOperation cancel];
            self.requestOperation = nil;
        }
        
        //
        // Creates a new timer that requests suggestions
        //
        // This minimizes the number of requests made to the server
        //
        self.requestTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                                             target:self
                                                           selector:@selector(_requestSuggestions:)
                                                           userInfo:nil
                                                            repeats:NO];
    }
    
    // Forwards the method call
    if (self.searchDisplayDelegate && [self.searchDisplayDelegate respondsToSelector:_cmd])
    {
        [self.searchDisplayDelegate searchDisplayController:controller shouldReloadTableForSearchString:searchString];
    }
    
    return NO;
}

#pragma mark - UITableView Delegate

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.suggestions.count)
    {
        return @"Sugestões";
    }
    if (self.searchBar.text.length > 0)
    {
        return nil;
    }
    if ([B2WSearchHistoryManager history].count)
    {
        return @"Últimas buscas";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (self.suggestions.count)
    {
        [self _didSelectSearchTerm:self.suggestions[indexPath.row]];
    }
    else if ([B2WSearchHistoryManager history].count)
    {
        [self _didSelectSearchTerm:[B2WSearchHistoryManager history][indexPath.row]];
    }
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.suggestions.count)
    {
        return self.suggestions.count;
    }
    if (self.searchBar.text.length > 0)
    {
        return 0;
    }
    return [B2WSearchHistoryManager history].count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    
    if (self.suggestions.count)
    {
        @autoreleasepool {
            //
            // Creates an attributed string from markdown,
            // highlighting the search suggestion text with the user provided search term
            //
            NSArray *searchBarStringTerms = [self.searchBar.text componentsSeparatedByString:@" "];
            cell.textLabel.attributedText = [self.suggestions[indexPath.row] attributedStringByHighlightingTerms:searchBarStringTerms];
        }
    }
    else
    {
        NSArray *history = [B2WSearchHistoryManager history];
        
        if (history.count > indexPath.row)
        {
            cell.textLabel.text = history[indexPath.row];
        }
    }
    
    return cell;
}

#pragma mark - Private Methods

- (void)_cancelSearchButtonPressed
{
    [self setActive:NO animated:YES];
}

- (void)_adjustSearchResultsTableViewFrame
{
    if (self.displaysSearchBarInNavigationBar)
    {
        CGRect navBarFrame = self.searchContentsController.navigationController.navigationBar.frame;
        
        CGFloat heighDelta = navBarFrame.origin.y + navBarFrame.size.height;
        
		self.searchResultsTableView.contentInset = UIEdgeInsetsMake(heighDelta, 0, 0, 0);
    }
}

- (void)_requestSuggestions:(NSTimer*)timer
{
    //
    // Only add the loading view when the interface is not
    // showing any suggestions
    //
    if (self.suggestions.count == 0)
    {
        [self _addLoadingView];
    }
    
    self.requestOperation = [B2WAPISearch requestSuggestionsWithQuery:self.searchBar.text block:^(NSArray *suggestions, NSError *error){
        [self _removeLoadingView];
        if (error && self.suggestionDelegate)
        {
            [self.suggestionDelegate didFailLoadingSuggestionsWithError:error];
            return;
        }
        
        [self setDimmingViewHidden:(suggestions.count > 0)];
        
        self.suggestions = suggestions;
        [self.searchResultsTableView reloadData];
    }];
}

- (void)_addLoadingView
{
    CGRect loadingViewFrame = self.searchResultsTableView.frame;
    loadingViewFrame.origin.y = 0;
    
    UIView *view = [[UIView alloc] initWithFrame:loadingViewFrame];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator setHidesWhenStopped:YES];
    [indicator startAnimating];
    
    CGPoint p = view.center;
    p.y /= 2;
    indicator.center = p;
    [view addSubview:indicator];
    
    view.tag = 1111;
    
    [self.searchResultsTableView addSubview:view];
}

- (void)_removeLoadingView
{
    [[self.searchResultsTableView viewWithTag:1111] removeFromSuperview];
}

- (void)_didSelectSearchTerm:(NSString*)searchTerm
{
    if (self.suggestionDelegate)
    {
        [B2WSearchHistoryManager addSearchTerm:searchTerm];
        [self.suggestionDelegate didSelectSuggestionTerm:searchTerm];
    }
}

@end
