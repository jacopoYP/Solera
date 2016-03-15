//
//  CheckoutViewController.m
//  Solera
//
//  Created by Jacopo Sanguineti on 12/03/16.
//  Copyright © 2016 Jacopo. All rights reserved.
//

#import "CheckoutViewController.h"
#import "CheckoutTableViewCell.h"
#import "Item.h"
#import "Utils.h"
#import "Globals.h"

#define TABLE_CELL_HEIGHT   65.0

@interface CheckoutViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>

/// All necessary IBOutlets
@property (weak, nonatomic) IBOutlet UIPickerView *currencyPickerView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbarCurrencyPicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *currencyBarButton;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *totalActivityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemsTableViewHeightConstraint;

@property (nonatomic, strong) NSMutableArray *arrayCurrencies;
@property (nonatomic, strong) NSString *currentCurrency;
@property (nonatomic, assign) float currentCurrencyExchangeRate;
@property (nonatomic, assign) float total;

///IBActions invoked by currencyBarButton
- (IBAction)openCurrencyPicker:(id)sender;
- (IBAction)hideCurrencyPicker:(id)sender;

@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // The item table height can change based on number of items purchased
    // Thanks to constraints priority, it can't be too big
    self.itemsTableViewHeightConstraint.constant = (self.itemsArray.count*TABLE_CELL_HEIGHT);
    
    //Default values
    self.currencyBarButton.title = [NSString stringWithFormat:@"Currency: %@", DEFAULT_CURRENCY];
    self.currencyPickerView.hidden = YES;
    self.toolbarCurrencyPicker.hidden = YES;
    [self.totalActivityIndicator stopAnimating];

    self.currentCurrency = DEFAULT_CURRENCY;
    self.currentCurrencyExchangeRate = DEFAULT_CURRENCY_RATE;
    
    [self calculateTotalAmount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UITableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CheckoutCell";

    CheckoutTableViewCell *cell = (CheckoutTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[CheckoutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.contentView.backgroundColor = [UIColor clearColor];
    Item *item = [self.itemsArray objectAtIndex:indexPath.row];

    cell.titleLabel.text = item.title;
    cell.descriptionLabel.text = item.desc;
    cell.quantityLabel.text = [NSString stringWithFormat:@"%li", (long)item.quantity];
    cell.priceLabel.text = [NSString stringWithFormat:@"%.2f", (item.price*self.currentCurrencyExchangeRate)];
    cell.totalLabel.text = [NSString stringWithFormat:@"%.2f", (item.quantity*item.price*self.currentCurrencyExchangeRate)];
    UIImage *theImage = [UIImage imageNamed:item.image];
    cell.image.image = theImage;
    
    return cell;
}

#pragma mark IBActions methods

- (IBAction)openCurrencyPicker:(id)sender {
    [self.currencyBarButton setEnabled:NO];
    
    self.arrayCurrencies = [NSMutableArray new];
    
    /*
     Improvement: to avoid several network calls, it would be better even to load all currencies once just when page is loaded
     */
    
    [[Utils sharedManager] getCurrencies:^(NSDictionary *dictionary, NSError *error) {
        if(!error) {
            NSDictionary *currencyDictionary = dictionary[@"currencies"];
            
            //Sorting the dictionary
            NSArray *arraySortedKeys = [currencyDictionary keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
                return [obj1 compare:obj2];
            }];
            
            [arraySortedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger index, BOOL * _Nonnull stop) {
                [self.arrayCurrencies addObject:@{@"key": key, @"value": currencyDictionary[key]}];
            }];
        } else {
            [self displayStandardErrorMessage:@"No network available. Only the default currency can be chosen"];
            [self.arrayCurrencies addObject:@{@"key": DEFAULT_CURRENCY, @"value": @""}];
        }
        
        [self performSelectorOnMainThread:@selector(updateCurrencyPicker) withObject:nil waitUntilDone:NO];
    }];
}

- (IBAction)hideCurrencyPicker:(id)sender {
    self.currencyPickerView.hidden = YES;
    self.toolbarCurrencyPicker.hidden = YES;
    self.currencyBarButton.enabled = YES;
    
    //As soon as picker is hidden, I update the total amount based on selected currency
    NSDictionary *currency = self.arrayCurrencies[[self.currencyPickerView selectedRowInComponent:0]];
    self.currentCurrency = currency[@"key"];
    [self.totalActivityIndicator startAnimating];
    
    [[Utils sharedManager] getExchangeRateForCurrency:self.currentCurrency withHandler:^(NSDictionary *dictionary, NSError *error) {
        if(!error) {
            NSString *quote = [NSString stringWithFormat:@"USD%@", self.currentCurrency];
            if(dictionary[@"quotes"][quote]) {
                self.currentCurrencyExchangeRate = [dictionary[@"quotes"][quote] floatValue];
            }
        } else {
            //I set the default currency
            self.currentCurrency = DEFAULT_CURRENCY;
            self.currentCurrencyExchangeRate = DEFAULT_CURRENCY_RATE;
            [self displayStandardErrorMessage:@"No network available. The total amount is available only on default currency"];
        }
        
        [self calculateTotalAmount];
    }];
}



- (void)updateCurrencyPicker {
    self.currencyPickerView.hidden = NO;
    self.toolbarCurrencyPicker.hidden = NO;
    [self.currencyPickerView reloadAllComponents];
}

#pragma mark - Calculate total amout

- (void)calculateTotalAmount {
    self.total = [[Utils sharedManager] calculateTotalAmount:self.itemsArray forCurrencyRate:self.currentCurrencyExchangeRate];
    [self performSelectorOnMainThread:@selector(updateTotal) withObject:nil waitUntilDone:NO];
}

- (void)updateTotal {
    [self.itemsTableView reloadData];
    self.totalLabel.text = [NSString stringWithFormat:@"%@ %.2f", self.currentCurrency, self.total];
    self.currencyBarButton.title = [NSString stringWithFormat:@"Currency: %@", self.currentCurrency];
    [self.totalActivityIndicator stopAnimating];
}

#pragma mark - Picker data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arrayCurrencies.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *currency = self.arrayCurrencies[row];
    return [NSString stringWithFormat:@"%@ - %@", currency[@"key"], currency[@"value"]];
}

#pragma mark - Picker delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSDictionary *currency = self.arrayCurrencies[row];
    self.currentCurrency = currency[@"key"];
}

#pragma mark UIAlert methods

- (void)displayStandardErrorMessage:(NSString *)message {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Attention" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}


@end
