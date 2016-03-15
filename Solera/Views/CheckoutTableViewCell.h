//
//  CheckoutTableViewCell.h
//  Solera
//
//  Created by Jacopo Sanguineti on 13/03/16.
//  Copyright © 2016 Jacopo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckoutTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;


@end
