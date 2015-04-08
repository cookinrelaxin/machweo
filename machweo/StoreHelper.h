//
//  StoreHelper.h
//  Machweo
//
//  Created by Feldcamp, Zachary Satoshi on 4/7/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface StoreHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic) BOOL areAdsRemoved;

- (void)restore;
- (void)tapsRemoveAds;

@end
