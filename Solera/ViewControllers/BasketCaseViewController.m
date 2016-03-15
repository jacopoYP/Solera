//
//  BasketCaseViewController.m
//  Solera
//
//  Created by Jacopo Sanguineti on 10/03/16.
//  Copyright © 2016 Jacopo. All rights reserved.
//

#import "BasketCaseViewController.h"
#import "CheckoutViewController.h"
#import "BasketCaseCollectionViewCell.h"
#import "Globals.h"
#import "Utils.h"
#import "Item.h"

@interface BasketCaseViewController () <UICollectionViewDataSource, UICollectionViewDelegate, BasketCaseCollectionViewCellDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (nonatomic, retain) NSMutableArray *itemsArray;
@property (nonatomic, retain) NSMutableArray *filteredItemsArray;
@property (nonatomic, assign) BOOL isFiltered;
@end

@implementation BasketCaseViewController

static NSString * const reuseIdentifier = @"BasketCaseCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16], NSFontAttributeName, [UIColor orangeColor], NSForegroundColorAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    self.title = @"Shopping";
    
    //Loading items via local JSON file. It could be easily changed to fetch data remotely
    self.itemsArray = [NSMutableArray new];
    NSMutableArray *itemsArrayFromJSON = [[Utils sharedManager] loadLocalJson:JSON_ITEMS];
    
    self.searchBar.delegate = self;
    self.checkoutButton.enabled = NO;
    
    //Creating array of Item objects
    [itemsArrayFromJSON enumerateObjectsUsingBlock:^(NSDictionary  *dictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        Item *item = [Item new];
        item.title = dictionary[@"title"];
        item.desc = dictionary[@"description"];
        item.price = [dictionary[@"price"] floatValue];
        item.image = dictionary[@"image"];
        item.quantity = 0;
        item.currency = dictionary[@"currency"];
        [self.itemsArray addObject:item];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"Checkout"]) {
        CheckoutViewController *checkoutViewController = [segue destinationViewController];
        
        //Removing items with quantity = 0;
        NSMutableArray *itemsOrderedArray = [NSMutableArray new];
        [self.itemsArray enumerateObjectsUsingBlock:^(Item *item, NSUInteger index, BOOL * _Nonnull stop) {
            if(item.quantity) {
                [itemsOrderedArray addObject:item];
            }
        }];
        
        checkoutViewController.itemsArray = itemsOrderedArray;
    }
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(self.isFiltered)
        return self.filteredItemsArray.count;
    else
        return self.itemsArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), 120);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BasketCaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    Item *item;

    if(self.isFiltered)
        item = [self.filteredItemsArray objectAtIndex:indexPath.row];
    else
        item = [self.itemsArray objectAtIndex:indexPath.row];

    cell.titleLabel.text = item.title;
    cell.descriptionLabel.text = item.desc;
    cell.priceLabel.text = [NSString stringWithFormat:@"%@ %.2f", item.currency, item.price];
    cell.delegate = self;
    [cell setMyCellIndex:indexPath.row];
    UIImage *theImage = [UIImage imageNamed:item.image];
    cell.image.image = theImage;

    cell.layer.cornerRadius = 3;
    cell.layer.masksToBounds = YES;

    cell.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    cell.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    cell.layer.shadowOpacity = 1.0f;
    cell.layer.shadowRadius = 1.0f;
    cell.layer.masksToBounds = NO;
    
    return cell;
}

#pragma mark - Basket Case Collection View Cell Delegate

- (void)updateQuantity:(NSInteger)quantity forItem:(NSInteger)index {
    Item *item = [self.itemsArray objectAtIndex:index];
    item.quantity = quantity;
    [self.itemsArray replaceObjectAtIndex:index withObject:item];
    __block BOOL checkoutEnabled = NO;
    
    [self.itemsArray enumerateObjectsUsingBlock:^(Item *item, NSUInteger idx, BOOL * _Nonnull stop) {
        if(item.quantity>0) {
            *stop = YES;
            checkoutEnabled = YES;
        }
    }];
    
    self.checkoutButton.enabled = checkoutEnabled;
}


#pragma mark Search Bar delegate methods

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        self.isFiltered = FALSE;
    }
    else
    {
        self.isFiltered = true;
        self.filteredItemsArray = [[NSMutableArray alloc] init];
        
        for (Item* item in self.itemsArray)
        {
            NSRange nameRange = [item.title rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [item.desc rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound)
            {
                [self.filteredItemsArray addObject:item];
            }
        }
    }
    
    [self.collectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - viewWillTransitionToSize
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.collectionView.collectionViewLayout invalidateLayout];
}


@end
