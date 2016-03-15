//
//  Item.h
//  Solera
//
//  Created by Jacopo Sanguineti on 10/03/16.
//  Copyright © 2016 Jacopo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, assign) float price;
@property (nonatomic, assign) NSInteger quantity;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *currency;

@end
