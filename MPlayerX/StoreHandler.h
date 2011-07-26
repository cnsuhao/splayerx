//
//  StoreHandler.h
//  MPlayerX
//
//  Created by Sicheng Zhu on 6/29/11.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SPlayerXBundleID;
extern NSString *const SPlayerXRevisedBundleID;

#ifdef NS_AVAILABLE_MAC
#import <StoreKit/StoreKit.h>

#import "UserDefaults.h"
#import "Appirater.h"
#import "LocalizedStrings.h"

#define     HAVE_STOREKIT   YES

// IAP Product ID (edit in itunesconnect)
#define SERVICE_PRODUCT_ID           @"org.splayer.splayerx.revised.p01"

// Customize "app give expiring alert xx days before expire date"
#define ALERT_DAY_BEFORE_EXPIRE         15

// Customize how many days for trial of smart subtitle matching service
#define SERVICE_TRIAL_DURATION  60

@interface StoreHandler : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate> 
{
    NSUserDefaults *ud;
    SKProductsRequest *productsRequest;
}

/* 
 * FUNC: return subscription left valid day
 */
+ (int) subscriptionLeftDay;

/* CALLED in ssclThread class to determine if we need OSD expire reminder
 * FUNC: return YES if we don't have valid receipt or receipt is going to expire
 */
+ (BOOL) expireReminder;

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

// *** for testing
- (void)reset;
// ***

@end

#endif
