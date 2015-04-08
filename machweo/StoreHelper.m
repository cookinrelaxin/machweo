//
//  StoreHelper.m
//  Machweo
//
//  Created by Feldcamp, Zachary Satoshi on 4/7/15.
//  Copyright (c) 2015 Zachary Feldcamp. All rights reserved.
//

#import "StoreHelper.h"
#import "Constants.h"

@implementation StoreHelper

#define kRemoveAdsProductIdentifier @"remove_ads"

- (void)tapsRemoveAds{
    NSLog(@"User requests to remove ads");
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifier]];
        productsRequest.delegate = self;
        [productsRequest start];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"processing initialized" object:nil];
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    NSUInteger count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) restore{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"processing initialized" object:nil];
    //this is called when the user restores purchases, you should hook this up to a button
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            [self doRemoveAds];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

-(void)doRemoveAds{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"processing over" object:nil];
    [Constants sharedInstance].enableAds = false;
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"areAdsRemoved"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"SKPaymentTransactionStatePurchased");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self doRemoveAds];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"SKPaymentTransactionStateRestored");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                if(transaction.error.code != SKErrorPaymentCancelled){
                    NSLog(@"SKPaymentTransactionStateFailed");
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
            case SKPaymentTransactionStateDeferred:
            break;
        }
    }
}

@end
