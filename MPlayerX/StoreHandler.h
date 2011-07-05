//
//  StoreHandler.h
//  MPlayerX
//
//  Created by Sicheng Zhu on 6/29/11.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "UserDefaults.h"
#import "Appirater.h"
#import "LocalizedStrings.h"

extern NSString *const SPlayerXBundleID;
extern NSString *const SPlayerXLiteBundleID;

// IAP Product ID (edit in itunesconnect)
#define SERVICE_PRODUCT_ID              @"org.splayer.splayerx.p01.1.0"

// Customize "app give expiring alert xx days before expire date"
#define ALERT_DAY_BEFORE_EXPIRE         15

// In how long (seconds) will next expire alert popped
#define ALERT_TIME_BEFORE_REMINDING     2


@interface StoreHandler : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate> 
{
    NSUserDefaults *ud;
    SKProductsRequest *productsRequest;
}

/* CALLED: when app did finish lauching
 * FUNC: check the left days in subscription and pop NSAlert
 * disabled when there's no valid receipt
 */
+ (void) expireAlert;

/* Three functions CALLED in observer delegate protocol function
 * FUNC: handling the received transactions from app store
 */
- (void) completedPurchaseTransaction: (SKPaymentTransaction *) transaction;
- (void) restoredPurchaseTransaction: (SKPaymentTransaction *) transaction;
- (void) handleFailedTransaction: (SKPaymentTransaction *) transaction;

/* CALLED by the button action in PrefController
 * FUNC: send payment request (including adding to payment queue)
 */
- (void) sendRequest;

/* CALLED when refreshing button state in PrefController and internal functions
 * FUNC: check the receipt to see if service enabled or expired 
 */
- (BOOL) checkServiceAuth;

/* CALLED to disable the Subscribe button in pref
 * FUNC: return YES if we don't have valid receipt or receipt is going to expire
 */
- (BOOL) checkSubscriptable;

// *** for testing
- (void)reset;
// ***

@end
