//
//  BasketCaseCollectionViewCell.h
//  Solera
//
//  Created by Jacopo Sanguineti on 13/03/16.
//  Copyright © 2016 Jacopo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BasketCaseCollectionViewCellDelegate <NSObject>

- (void)updateQuantity:(NSInteger)quantity forItem:(NSInteger)index;

@end

@interface BasketCaseCollectionViewCell : UICollectionViewCell <UITextFieldDelegate>

@property (nonatomic, weak) id<BasketCaseCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property NSInteger myCellIndex;

- (IBAction)setQuantity:(id)sender;

@end
