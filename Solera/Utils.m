//
//  Utils.m
//  Solera
//
//  Created by Jacopo Sanguineti on 10/03/16.
//  Copyright © 2016 Jacopo. All rights reserved.
//

#import "Utils.h"
#import "Item.h"
#import "Globals.h"
#import "Reachability.h"

@implementation Utils

#pragma mark Init methods

+ (id)sharedManager {
    static Utils *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

#pragma mark Load JSON

- (NSMutableArray *)loadLocalJson:(NSString *)path {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:path ofType:nil];
    NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil];
    
    return json;
}

#pragma mark Calculate methods

- (float)calculateTotalAmount:(NSArray*)array forCurrencyRate:(float)currencyRate {
    __block float total = 0;
    
    [array enumerateObjectsUsingBlock:^(Item *item, NSUInteger idx, BOOL * _Nonnull stop) {
        total+=(item.price*item.quantity);
    }];
    
    return total*currencyRate;
    
}

#pragma mark Network methods

- (void)getCurrencies:(void (^)(NSDictionary *dictionary, NSError *error))handler {
    if([self isDeviceConnected]) {
        NSString *url = [NSString stringWithFormat:@"%@list?access_key=%@", CURRENCY_API_URL, CURRENCY_API_KEY];
        [self getRequest:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSError *errorJson;
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
            handler(responseDict, errorJson);
        }];
    } else {
        NSMutableDictionary* errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"No network available" forKey:NSLocalizedDescriptionKey];
        NSError *networkError = [NSError errorWithDomain:@"Solera" code:101 userInfo:errorDetail];
        handler(@{}, networkError);
    }
}

- (void)getExchangeRateForCurrency:(NSString *)currency withHandler:(void (^)(NSDictionary *dictionary, NSError *error))handler {
    if([self isDeviceConnected]) {
        NSString *url = [NSString stringWithFormat:@"%@live?access_key=%@&currencies=%@&source=USD&format=1", CURRENCY_API_URL, CURRENCY_API_KEY, currency];
        [self getRequest:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSError *errorJson;
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
            handler(responseDict, errorJson);
        }];
    } else {
        NSMutableDictionary* errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"No network available" forKey:NSLocalizedDescriptionKey];
        NSError *networkError = [NSError errorWithDomain:@"Solera" code:101 userInfo:errorDetail];
        handler(@{}, networkError);
    }
}

/**
 * This method is private because it's used only internally, but for a real app it should be public and improved accepting
 * other typical network params like method, headers, etc
 */
-(void)getRequest:(NSString *)urlString withHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        block(data, response, error);
    }] resume];
}

#pragma mark Check reachability 

- (BOOL)isDeviceConnected {
    Reachability *hostReachability = [Reachability reachabilityWithHostName:@"http://www.apple.com"];
    return [hostReachability currentReachabilityStatus] != NotReachable;
}

@end
