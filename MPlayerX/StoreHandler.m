//
//  StoreHandler.m
//  MPlayerX
//
//  Created by Sicheng Zhu on 6/29/11.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import "StoreHandler.h"

NSString * const SPlayerXBundleID           = @"org.splayer.splayerx";
NSString * const SPlayerXRevisedBundleID       = @"org.splayer.splayerx.revised";

#ifdef HAVE_STOREKIT

@implementation StoreHandler

// ***** define methods in protocol *****
+ (void) initialize
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    
    [ud registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithBool:NO], kUDKeyReceipt,
      [NSDate date], kUDKeyReceiptDueDate,
      [NSNumber numberWithBool:NO], kUDKeyTrial,
      nil]];
}

- (id) init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        ud = [NSUserDefaults standardUserDefaults];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        // add trial
        if (![[ud objectForKey:kUDKeyTrial] boolValue])
        {
            [ud setObject:[NSNumber numberWithBool:YES] forKey:kUDKeyTrial];
            [ud setObject:[NSNumber numberWithBool:YES] forKey:kUDKeyReceipt];
            [ud setObject:[NSDate dateWithTimeIntervalSinceNow:(SERVICE_TRIAL_DURATION * 3600 * 24)] 
                   forKey:kUDKeyReceiptDueDate];
        }
        
        // refresh subtitle service status
        if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:SPlayerXBundleID])
        {
            [ud setObject:[NSNumber numberWithBool:YES] forKey:kUDKeySmartSubMatching];
        }
        else if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:SPlayerXRevisedBundleID]) 
        {
            if (![self checkServiceAuth])
            {
                [ud setObject:[NSNumber numberWithBool:NO] forKey:kUDKeyReceipt];
                [ud setObject:[NSNumber numberWithBool:NO] forKey:kUDKeySmartSubMatching];
            }
        }
    }
    return self;
}

- (void) productsRequest:(SKProductsRequest *)request 
      didReceiveResponse:(SKProductsResponse *)response
{
    [productsRequest release];
    
    SKProduct *product = [response.products objectAtIndex:0];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) paymentQueue:(SKPaymentQueue *)queue 
  updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) 
    {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completedPurchaseTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoredPurchaseTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self handleFailedTransaction:transaction];
                break;
        }
    }
}


// ***** own methods *****
+ (BOOL) expireReminder
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUDKeyReceipt])
    {
        NSDate *dueDate = [[NSUserDefaults standardUserDefaults] 
                           objectForKey:kUDKeyReceiptDueDate];
        
        if ([dueDate timeIntervalSinceNow] < 3600 * 24 * ALERT_DAY_BEFORE_EXPIRE)
            return YES;
    }
    return NO;
}

+ (int) subscriptionLeftDay
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUDKeyReceipt]) 
        return -1;
    NSDate *dueDate = [[NSUserDefaults standardUserDefaults]
                       objectForKey:kUDKeyReceiptDueDate];
    return ( (int)[dueDate timeIntervalSinceNow] / 3600 / 24 + 1);
}

- (void) completedPurchaseTransaction: (SKPaymentTransaction *) transaction
{   
    if ([ud boolForKey:kUDKeyReceipt])
    {
        NSDate *duedate = [ud objectForKey:kUDKeyReceiptDueDate];
        [ud setObject:[NSDate dateWithTimeInterval:(365 * 24 * 3600)
                                         sinceDate:duedate]
               forKey:kUDKeyReceiptDueDate];
    }
    else 
    {
        [ud setObject:[NSNumber numberWithBool:YES] forKey:kUDKeyReceipt];
        [ud setObject:[NSDate dateWithTimeIntervalSinceNow:(365 * 24 * 3600)]
               forKey:kUDKeyReceiptDueDate];
        [ud setObject:[NSNumber numberWithBool:YES] forKey:kUDKeySmartSubMatching];
    }
    
    [ud synchronize];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"RefreshButton" object:self];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

// not sure about this function. needing pending
- (void) restoredPurchaseTransaction: (SKPaymentTransaction *) transaction
{
    [ud setObject:[NSNumber numberWithBool:YES] forKey:kUDKeyReceipt];
    NSDate *date = transaction.originalTransaction.transactionDate;
    [ud setObject:[NSDate dateWithTimeInterval:(2*365*24*3600) sinceDate:date]
           forKey:kUDKeyReceiptDueDate];
    [ud setObject:[NSNumber numberWithBool:YES] forKey:kUDKeySmartSubMatching];
    
    [ud synchronize];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"RefreshButton" object:self];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) handleFailedTransaction: (SKPaymentTransaction *) transaction
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc postNotificationName:@"RefreshButton" object:self];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) sendRequest
{
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:
                       [NSSet setWithObject: SERVICE_PRODUCT_ID]];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (BOOL) checkServiceAuth
{
    if (![ud boolForKey:kUDKeyReceipt])return NO;
    NSDate *dueDate = [ud objectForKey:kUDKeyReceiptDueDate];
    if ([dueDate compare:[NSDate date]] == NSOrderedDescending)
        return YES;
    [ud setObject:[NSNumber numberWithBool:NO]
           forKey:kUDKeyReceipt];
    [ud synchronize];
    return NO;
}

// *** for testing
- (void)reset
{
    [ud setObject:[NSNumber numberWithBool:NO] forKey:kUDKeyReceipt];
    [ud synchronize];
}
// ***
@end

#endif
