//
//  B2WCreditCardListTableViewController.m
//  B2WKit
//
//  Created by rodrigo.fontes on 15/07/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WCreditCardListTableViewController.h"

#import "B2WCreditCardTableViewCell.h"
#import "B2WCreditCardFormViewController.h"

#import "UIViewController+States.h"

@interface B2WCreditCardListTableViewController () <B2WCreditCardFormViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *creditCards;

@end

@implementation B2WCreditCardListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    [self requestCreditCards];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self.navigationItem setRightBarButtonItem:(self.creditCards.count == 0) ? nil : [self editBarItem] animated:YES];
    return self.creditCards.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.creditCards count])
    {
        return 44;
    }
    
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.creditCards count])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell" forIndexPath:indexPath];
        cell.textLabel.textColor = [B2WAccountManager sharedManager].appPrimaryColor;
        
        return cell;
    }
    else
    {
        B2WCreditCard *creditCard = [self.creditCards objectAtIndex:indexPath.row];
        
        B2WCreditCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        [cell setCreditCard:creditCard];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.creditCards count])
    {
        [self performSegueWithIdentifier:@"CreditCardSegue" sender:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing || indexPath.row == [self.creditCards count])
    {
        return NO;
    }
    
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remover";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        B2WCreditCard *creditCard = [self.creditCards objectAtIndex:indexPath.row];
        
        [self.creditCards removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self deleteCreditCard:creditCard];
    }
}

#pragma mark - Networking

- (void)requestCreditCards
{
    [self.loadingView show];
    
    [[B2WAccountManager currentCustomer] requestCreditCardsWithBlock:^(id object, NSError *error) {
        
        [self.loadingView dismiss];
        
        if (error)
        {
            NSString *title   = kDefaultConnectionErrorTitle;
            NSString *message = kDefaultConnectionErrorMessage;
            
            [self.contentUnavailableView showWithTitle:title message:message buttonTitle:@"Tentar novamente" reloadButtonPressedBlock:^() {
                [self.contentUnavailableView dismiss];
                [self.loadingView show];
                [self requestCreditCards];
            }];
        }
        else
        {
            self.creditCards = object;
            NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:self.creditCards.count];
            for (int i = 0; i < self.creditCards.count; i++)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:indexPath];
            }
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
}

- (void)deleteCreditCard:(B2WCreditCard *)creditCard
{
    //[self.loadingView show];
    
    [creditCard removeWithBlock:^(id object, NSError *error) {
        
        //[self.loadingView dismiss];
        
        if (error)
        {
            /*if (error.code == -1009)
             {
             [UIAlertView showAlertViewWithTitle:@"A conexão parece estar offline. Tente novamente."];
             }
             else
             {
             NSDictionary *localizedDescription = (NSDictionary *)error.localizedDescription;
             
             if (localizedDescription && (! [localizedDescription.allKeys containsObject:@"validationErrors"]))
             {
             [UIAlertView showAlertViewWithTitle:localizedDescription[@"message"]];
             }
             else
             {
             [UIAlertView showAlertViewWithTitle:error.localizedDescription];
             }
             }*/
        }
        else
        {
            // [UIAlertView showAlertViewWithTitle:@"Endereço removido com sucesso!"];
        }
    }];
}

#pragma mark - CreditCardViewController

- (void)creditCardFormViewController:(B2WCreditCardFormViewController *)controller didCreateCreditCard:(B2WCreditCard *)creditCard
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        [self.creditCards insertObject:creditCard atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

#pragma mark - Custom

- (UIBarButtonItem *)editBarItem
{
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"Editar" style:UIBarButtonItemStyleDone target:self action:@selector(editBarButtonAction:)];
    return barItem;
}

- (UIBarButtonItem *)loadingBarItem
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator setColor:[B2WAccountManager sharedManager].appLoadingColor];
    [activityIndicator startAnimating];
    
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    return barItem;
}

#pragma mark - Actions

- (IBAction)closeBarButtonAction:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editBarButtonAction:(UIBarButtonItem *)sender
{
    if (self.tableView.isEditing)
    {
        [self.tableView setEditing:NO animated:YES];
        [sender setTitle:@"Editar"];
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        [sender setTitle:@"OK"];
    }
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CreditCardSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        B2WCreditCardFormViewController *creditCardFormViewController = (B2WCreditCardFormViewController *)navigationController.topViewController;
        [creditCardFormViewController setCreditCardFormViewControllerDelegate:self];
        creditCardFormViewController.isOneClickActivation = NO;
    }
}

@end
