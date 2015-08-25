//
//  B2WPostalCodeSearchTableViewController.m
//  B2WKit
//
//  Created by Eduardo Callado on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WPostalCodeSearchTableViewController.h"

#import "B2WAddressTableViewCell.h"

#import "B2WAPIPostalCode.h"

#import "B2WCEPSearchFieldsViewController.h"

#import "B2WAddressValidator.h"

@interface B2WPostalCodeSearchTableViewController () <CEPSearchFieldsDelegate>

@property (nonatomic, strong) B2WCEPSearchFieldsViewController *searchFieldsController;

@property (nonatomic, strong) NSTimer *requestTimer;

@property (nonatomic, strong) NSMutableArray *cities;
@property (nonatomic, strong) NSArray *filteredCities;

@property (nonatomic, strong) NSArray *addresses;

@end


@implementation B2WPostalCodeSearchTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self setupDataSource];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackScreenView"
														object:self
													  userInfo:@{@"screenName" : @"Cadastro - Busca de CEP"}];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	if (self.filteredCities.count > 0 || self.addresses.count > 0){
		return 1;
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.addresses.count > 0)
	{
		return @"Selecione o seu CEP";
	}
	
	return @"Selecione a sua cidade";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.addresses.count > 0)
	{
		return self.addresses.count;
	}
	
	return self.filteredCities.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.addresses.count > 0)
	{
		return 66;
	}
	
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.addresses.count > 0)
	{
		NSDictionary *addressDictionary = self.addresses[indexPath.row];
		
		B2WAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell" forIndexPath:indexPath];
		[cell.postalCodeLabel setText:[addressDictionary[@"number"] maskedPostalCodeString]];
		
		NSString *address;
		
		if (![addressDictionary[@"address"] isKindOfClass:[NSNull class]])
		{
			address = addressDictionary[@"address"];
		}
		else
		{
			address = @"";
		}
		
		NSString *neighborhood;
		
		if (![addressDictionary[@"neighborhood"] isKindOfClass:[NSNull class]])
		{
			neighborhood = addressDictionary[@"neighborhood"];
		}
		else
		{
			neighborhood = @"";
		}
		
		if (address.length > 0 && neighborhood.length > 0){
			[cell.addressLabel setText:[NSString stringWithFormat:@"%@, %@", address, neighborhood]];
		}
		else if (address.length > 0){
			[cell.addressLabel setText:address];
		}
		else if (neighborhood.length > 0){
			[cell.addressLabel setText:neighborhood];
		}
		else{
			[cell.addressLabel setText:@"-"];
		}
		
		return cell;
	}
	else
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
		[cell.textLabel setText:self.filteredCities[indexPath.row]];
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.addresses.count > 0)
	{
		[self.delegate postalCodeSearchController:self didSelectAddress:self.addresses[indexPath.row]];
	}
	else
	{
		[self.searchFieldsController.cityTextField setText:self.filteredCities[indexPath.row]];
		
		self.filteredCities = nil;
		[self.tableView reloadData];
		
		[self requestAddresses];
	}
}

#pragma mark - Networking

- (void)requestAddresses
{
	[self.navigationItem setRightBarButtonItem:[self loadingBarItem] animated:YES];
	
	[B2WAPIPostalCode cancelAllRequests];
	
	NSString *city = [self.searchFieldsController.cityTextField.text componentsSeparatedByString:@" - "].firstObject;
	NSString *state = [self.searchFieldsController.cityTextField.text componentsSeparatedByString:@" - "].lastObject;
	
	[B2WAPIPostalCode requestPostalCodeWithStreet:self.searchFieldsController.addressTextField.text city:city state:state block:^(id object, NSError *error) {
		[self.navigationItem setRightBarButtonItem:[self searchBarItem] animated:YES];
		
		if (error)
        {
			if (error.code == -1009)
			{
				[UIAlertView showAlertViewWithTitle:@"A conexão parece estar offline. Tente novamente."];
			}
			else
			{
				[UIAlertView showAlertViewWithTitle:@"Não Foi Encontrado Nenhum CEP Para Este Endereço"];
			}
        }
		else
		{
			self.addresses = object;
			
			[self.tableView reloadData];
			
			[self.tableView endEditing:YES];
		}
	}];
}

#pragma mark - SearchFieldsController

- (void)cityTextFieldDidChange:(NSString *)text{
	self.addresses = nil;
	self.filteredCities = [self.cities filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", text]];
	[self.tableView reloadData];
}

- (void)searchFieldDidReturn:(UITextField *)textField{
	if (textField == self.searchFieldsController.addressTextField){
		[self.searchFieldsController.cityTextField becomeFirstResponder];
	}
}

- (void)searchFieldDidClear{
	self.addresses = nil;
	self.filteredCities = nil;
	[self.tableView reloadData];
}

#pragma mark - Custom

- (void)setupDataSource
{
	self.cities = [NSMutableArray new];
	
	NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle B2WKitBundle] pathForResource:@"estados-cidades" ofType:@"json"]];
	
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
	
	for (NSDictionary *stateDictionary in dictionary[@"estados"])
	{
		NSString *state = stateDictionary[@"sigla"];
		
		for (NSString *city in stateDictionary[@"cidades"])
		{
			[self.cities addObject:[NSString stringWithFormat:@"%@ - %@", city, state]];
		}
	}
	
	[self.cities sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj1 caseInsensitiveCompare:obj2];
	}];
}

- (UIBarButtonItem *)searchBarItem
{
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"Buscar" style:UIBarButtonItemStyleDone target:self action:@selector(searchBarButtonAction:)];
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

- (IBAction)cancelBarButtonAction:(UIBarButtonItem *)sender
{
	[B2WAPIPostalCode cancelAllRequests];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)searchBarButtonAction:(UIBarButtonItem *)sender
{
	[self requestAddresses];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	self.searchFieldsController = segue.destinationViewController;
	[self.searchFieldsController setDelegate:self];
}

@end
