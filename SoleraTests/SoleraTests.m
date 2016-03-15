//
//  SoleraTests.m
//  SoleraTests
//
//  Created by Jacopo Sanguineti on 09/03/16.
//  Copyright © 2016 Jacopo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Utils.h"
#import "Item.h"
#import "Globals.h"

@interface SoleraTests : XCTestCase

@property (nonatomic, strong) NSMutableArray *itemsArray;

@end

@implementation SoleraTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

- (void)testLoadJSON {
    self.itemsArray = [NSMutableArray new];
    self.itemsArray = [[Utils sharedManager] loadLocalJson:JSON_ITEMS];
    XCTAssertEqual(self.itemsArray.count, 4);
}

- (void)testSum {
    NSMutableArray *items = [NSMutableArray new];
    Item *item = [Item new];
    item.price = 1.1;
    item.quantity = 2;
    [items addObject:item];
    
    float total = [[Utils sharedManager] calculateTotalAmount:items forCurrencyRate:1.5];
    XCTAssertEqualWithAccuracy(total, 3.3f, 0.001, @"");
    
}

@end
