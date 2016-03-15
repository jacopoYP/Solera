//
//  Utils.h
//  Solera
//
//  Created by Jacopo Sanguineti on 10/03/16.
//  Copyright © 2016 Jacopo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (id)sharedManager;

/**
 * Load a local JSON File. This method could easily improved to load also a remote JSON from
 * a service
 * @param path NSString
 * @return An array of items
 */
- (NSMutableArray *)loadLocalJson:(NSString *)path;

/**
 * Given the items array, this method calculates the shopping cart total amount
 * @param array Array of all items
 * @param currencyRate The currency rate
 * @return The sum of all items purchased
 */
- (float)calculateTotalAmount:(NSArray*)array forCurrencyRate:(float)currencyRate;

/**
 * This method return the list of all available currencies and it returns a dictionary thanks a block
 * @param block Array of all items
 */
- (void)getCurrencies:(void (^)(NSDictionary *dictionary, NSError *error))block;

/**
 * This method return the exchange rate for a given currency.
 * @param block Array of all items
 */
- (void)getExchangeRateForCurrency:(NSString *)currency withHandler:(void (^)(NSDictionary *dictionary, NSError *error))handler;

@end
