//
//  StoreHandler.m
//  MPlayerX
//
//  Created by Sicheng Zhu on 6/29/11.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import "StoreHandler.h"

// *** normal code ***
//NSString * const SPlayerXBundleID           = @"org.splayer.splayerx";
//NSString * const SPlayerXLiteBundleID       = @"Unknown";
// *** test code
NSString * const SPlayerXBundleID           = @"Unknown";
NSString * const SPlayerXLiteBundleID       = @"org.splayer.splayerx";
// ***

@implementation StoreHandler

// ***** define methods in protocol *****
+ (void) initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithObjectsAndKeys:
	  [NSNumber numberWithBool:NO], kUDKeyReceipt,
      [NSDate date], kUDKeyReceiptDueDate,
      [NSDate date], kUDKeyReceiptExpireRemindDate,
	  nil]];
}

- (id) init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        ud = [NSUserDefaults standardUserDefaults];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        // *** for testing
        
        [ud setObject:[NSNumber numberWithBool:YES] forKey:kUDKeyReceipt];
        [ud setObject:[NSDate dateWithTimeIntervalSinceNow:(2 * 24 * 3600)]
                                                    forKey:kUDKeyReceiptDueDate];
        [ud setObject:[NSDate dateWithTimeIntervalSinceNow:
                       (( 2 - ALERT_DAY_BEFORE_EXPIRE ) * 24 * 3600)] 
                                                    forKey:kUDKeyReceiptExpireRemindDate];
        [ud setObject:[NSNumber numberWithBool:YES] forKey:kUDKeySmartSubMatching];
        
        // ***
        
        // refresh subtitle service status
        if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:SPlayerXBundleID])
        {
            [ud setObject:[NSNumber numberWithBool:YES] forKey:kUDKeySmartSubMatching];
        }
        else if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:SPlayerXLiteBundleID]) 
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
+ (void) expireAlert
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUDKeyReceipt])
    {
        NSDate *remindDate = [[NSUserDefaults standardUserDefaults] 
                              objectForKey:kUDKeyReceiptExpireRemindDate];
        if ([remindDate compare:[NSDate date]]== NSOrderedAscending)
        {
            NSDate *dueDate = [[NSUserDefaults standardUserDefaults] 
                               objectForKey:kUDKeyReceiptDueDate];
            int leftDay = ( (int)[dueDate timeIntervalSinceNow] / (3600 * 24) ) + 1;
            NSString *text = [kMPXStringStoreAlertInformativeTextOne 
                              stringByAppendingFormat:@"%d", leftDay];
            text = [text stringByAppendingString:kMPXStringStoreAlertInformativeTextTwo];
            
            NSAlert *alert = [NSAlert alertWithMessageText:kMPXStringStoreAlertTitle
                                             defaultButton:kMPXStringStoreAlertButton
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:text];

            [alert runModal];
            
            if (leftDay < 4) [[NSUserDefaults standardUserDefaults] 
                              setObject:[NSDate dateWithTimeIntervalSinceNow:(24 * 3600)] 
                              forKey:kUDKeyReceiptExpireRemindDate];
            else [[NSUserDefaults standardUserDefaults] 
                  setObject:[NSDate dateWithTimeIntervalSinceNow:ALERT_TIME_BEFORE_REMINDING] 
                  forKey:kUDKeyReceiptExpireRemindDate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void) completedPurchaseTransaction: (SKPaymentTransaction *) transaction
{   
    if ([ud boolForKey:kUDKeyReceipt])
    {
        NSDate *duedate = [ud objectForKey:kUDKeyReceiptDueDate];
        [ud setObject:[NSDate dateWithTimeInterval:(365 * 24 * 3600)
                                         sinceDate:duedate]
               forKey:kUDKeyReceiptDueDate];
        [ud setObject:[NSDate dateWithTimeInterval:
                       ((365 - ALERT_DAY_BEFORE_EXPIRE ) * 24 * 3600) 
                                         sinceDate:duedate] 
               forKey:kUDKeyReceiptExpireRemindDate];
    }
    else 
    {
        [ud setObject:[NSNumber numberWithBool:YES] forKey:kUDKeyReceipt];
        [ud setObject:[NSDate dateWithTimeIntervalSinceNow:(365 * 24 * 3600)]
               forKey:kUDKeyReceiptDueDate];
        [ud setObject:[NSDate dateWithTimeIntervalSinceNow:
                       ((365 - ALERT_DAY_BEFORE_EXPIRE ) * 24 * 3600)]
               forKey:kUDKeyReceiptExpireRemindDate];
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
    
    // *** for testing
    /*[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
                                              forKey:kUDKeyReceipt];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:(2*365*24*3600)]
                                              forKey:kUDKeyReceiptDueDate];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
                                              forKey:kUDKeySmartSubMatching];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"RefreshButton" object:self];*/
    // ***
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

- (BOOL) checkSubscriptable
{
    if (![self checkServiceAuth]) return YES;
    NSDate *dueDate = [ud objectForKey:kUDKeyReceiptDueDate];
    NSTimeInterval timeToExpire = [dueDate timeIntervalSinceNow];
    if (timeToExpire < (ALERT_DAY_BEFORE_EXPIRE * 24 * 60 * 60)) return YES;
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
