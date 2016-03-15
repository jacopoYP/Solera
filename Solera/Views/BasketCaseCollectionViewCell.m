//
//  BasketCaseCollectionViewCell.m
//  Solera
//
//  Created by Jacopo Sanguineti on 13/03/16.
//  Copyright © 2016 Jacopo. All rights reserved.
//

#import "BasketCaseCollectionViewCell.h"

@implementation BasketCaseCollectionViewCell

- (IBAction)setQuantity:(id)sender {
    UIButton *button = (UIButton*)sender;
    int tag = (int)button.tag;
    NSInteger quantity = [self.quantityTextField.text integerValue];
    
    if(tag==1) {
        quantity++;
    } else {
        quantity>0 ? quantity-- : 0;
    }
    
    self.quantityTextField.text = [NSString stringWithFormat:@"%li", (long)quantity];
    
    [self.delegate updateQuantity:quantity forItem:self.myCellIndex];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(searchStr.length && [self isNumber:searchStr]) {
        [self.delegate updateQuantity:[searchStr intValue] forItem:self.myCellIndex];
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)isNumber:(NSString *)string {
    NSPredicate *numberPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '^[0-9]+$'"];
    return [numberPredicate evaluateWithObject:string];
}

@end
