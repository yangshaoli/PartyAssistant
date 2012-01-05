//
//  ECPurchase.m
//  myPurchase
//
//  Created by ris on 10-4-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECPurchase.h"
#import "SBJSON.h"
#import "GTMBase64.h"
#import "UserObjectService.h"
#import "UserObject.h"
#import "DeviceDetection.h"
#import "RegexKitLite.h"
/******************************
 SKProduct extend
 *****************************/
@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    [numberFormatter release];
    return formattedString;
}

@end

/***********************************
 ECPurchaseFormDataRequest
 ***********************************/
@implementation ECPurchaseFormDataRequest
@synthesize productIdentifier = _productIdentifier;
@synthesize userID = _userID;

@end

/***********************************
 ECPurchaseHTTPRequest
 ***********************************/
@implementation ECPurchaseHTTPRequest
@synthesize productIdentifier = _productIdentifier;
@synthesize userID = _userID;

@end

/******************************
 ECPurchase
 ******************************/
@implementation ECPurchase
@synthesize productDelegate = _productDelegate;
@synthesize transactionDelegate =_transactionDelegate;
@synthesize verifyRecepitMode = _verifyRecepitMode;

SINGLETON_IMPLEMENTATION(ECPurchase);

//you can init the object here as the object init is in SINGLETON_IMPLEMENTATION
-(void)postInit
{
	_verifyRecepitMode = ECVerifyRecepitModeNone;
	[self registerNotifications];
}

- (void)requestProductData:(NSArray *)proIdentifiers{
    [_productDelegate didBeginProductsRequest];
    NSSet *sets = [NSSet setWithArray:proIdentifiers];
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:sets];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSArray *products = response.products;
#ifdef ECPURCHASE_TEST_MODE	
	NSMutableString *result = [[NSMutableString alloc] init];
	for (int i = 0; i < [products count]; ++i) {
		SKProduct *proUpgradeProduct = [products objectAtIndex:i];
		[result appendFormat:@"%@,%@,%@,%@\n",
		 proUpgradeProduct.localizedTitle,proUpgradeProduct.localizedDescription,proUpgradeProduct.price,proUpgradeProduct.productIdentifier];
	}
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
		[result appendFormat:@"Invalid product id: %@",invalidProductId];
    }
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iap" message:result
										delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[_productDelegate didReceivedProducts:products];
#else
	[_productDelegate didReceivedProducts:products];

#endif   
	[_productsRequest release];
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    [_productDelegate requestDidFail];
}

-(void)addTransactionObserver{
	_storeObserver = [[ECStoreObserver alloc] init];
	[[SKPaymentQueue defaultQueue] addTransactionObserver:_storeObserver];
}

-(void)removeTransactionObserver{
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:_storeObserver];
}

-(void)addPayment:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark -
#pragma mark NSNotificationCenter Methods
-(void)completeTransaction:(NSNotification *)note{
	SKPaymentTransaction *trans = [[note userInfo] objectForKey:@"transaction"];
	
    UserObject *user = [[UserObjectService sharedUserObjectService] getUserObject];
    NSString *userID = [[NSNumber numberWithInt:[user uID]] stringValue];
    NSDictionary *purchaseInfo = [NSDictionary dictionaryWithObjectsAndKeys: userID, @"userID",
                                    trans.payment.productIdentifier, @"identifier",
                                    trans.transactionReceipt, @"receipt",
                                    nil];
    [self storeTempUserReceipt:purchaseInfo];
    
    if (_verifyRecepitMode == ECVerifyRecepitModeNone) {
		[_transactionDelegate didCompleteTransaction:trans.payment.productIdentifier];
	}
	else if(_verifyRecepitMode == ECVerifyRecepitModeiPhone){
		[self verifyReceipt:trans];
	}
	else if(_verifyRecepitMode == ECVerifyRecepitModeServer){
		[self verifyReceipt:trans];
	}
	
}

-(void)failedTransaction:(NSNotification *)note{
	SKPaymentTransaction *trans = [[note userInfo] objectForKey:@"transaction"];
	[_transactionDelegate didFailedTransaction:trans.payment.productIdentifier];
}

-(void)restoreTransaction:(NSNotification *)note{
	SKPaymentTransaction *trans = [[note userInfo] objectForKey:@"transaction"];
	[_transactionDelegate didRestoreTransaction:trans.payment.productIdentifier];
}

-(void)registerNotifications{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeTransaction:) name:@"completeTransaction" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedTransaction:) name:@"failedTransaction" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreTransaction:) name:@"restoreTransaction" object:nil];
}

-(void)verifyReceipt:(SKPaymentTransaction *)transaction
{
    _networkQueue = [ASINetworkQueue queue];
	[_networkQueue retain];
	NSURL *verifyURL = [NSURL URLWithString:VAILDATING_RECEIPTS_URL];

	ECPurchaseFormDataRequest *request = [[ECPurchaseFormDataRequest alloc] initWithURL:verifyURL];
	[request setProductIdentifier:transaction.payment.productIdentifier];
	[request setRequestMethod: @"POST"];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(didFinishVerify:)];
    [request setDidFailSelector:@selector(didFailedVerify:)];
	[request addRequestHeader: @"Content-Type" value: @"application/json"];
	
	NSString *recepit = [GTMBase64 stringByEncodingData:transaction.transactionReceipt];
	
    UserObject *user = [[UserObjectService sharedUserObjectService] getUserObject];
    NSString *userID = [[NSNumber numberWithInt:[user uID]] stringValue];
    
    [request setUserID:userID];
	[request setPostValue:recepit forKey:@"receipt-data"];
    [request setPostValue:userID forKey:@"user-ID"];
    
    NSString *platform = [DeviceDetection platform];
    
    [request setPostValue:platform forKey:@"device-platform"];
    
    NSString *regexString = @"([a-zA-Z]+)(\\d+),(\\d+)";
    
    if ([platform isMatchedByRegex:regexString]) {
        NSString *deviceType = [platform stringByMatching:regexString capture:1L];
        NSString *deviceVersion = [platform stringByMatching:regexString capture:2L];
        NSString *deviceSubVersion = [platform stringByMatching:regexString capture:3L];
    
        if (deviceType) [request setPostValue:deviceType forKey:@"deviceType"];
        if (deviceVersion) [request setPostValue:deviceVersion forKey:@"deviceVersion"];
        if (deviceSubVersion) [request setPostValue:deviceSubVersion forKey:@"deviceSubVersion"];
    }
    
    [_networkQueue addOperation: request];
	[_networkQueue go];
}

-(void)didFinishVerify:(ECPurchaseFormDataRequest *)request
{
    NSString *response = [request responseString];
    SBJsonParser *parser = [SBJsonParser new];
	NSDictionary* jsonData = [parser objectWithString: response];
    NSDictionary* datasource = [jsonData objectForKey:@"datasource"];
	[parser release];
    NSString *ourServerStatus = [jsonData objectForKey: @"status"];
    if ([ourServerStatus intValue] == 200) {
        NSString *status = [datasource objectForKey: @"status"];
        if ([status intValue] == 0) {
            NSDictionary *receipt = [datasource objectForKey: @"receipt"];
            NSString *productIdentifier = [receipt objectForKey: @"product_id"];
            [_transactionDelegate didCompleteTransactionAndVerifySucceed:productIdentifier];
            [self removeReceiptWithUserID:request.userID andIdentifier:request.productIdentifier];
        }
        else {
            NSString *exception = [datasource objectForKey: @"exception"];
            [_transactionDelegate didCompleteTransactionAndVerifyFailed:request.productIdentifier 
                                                              withError:exception];
        }

    } else {
        NSString *exception = [datasource objectForKey: @"exception"];
        [_transactionDelegate didCompleteTransactionAndVerifyFailed:request.productIdentifier
                                                          withError:exception];
    }
}
-(void)didFailedVerify:(ECPurchaseFormDataRequest *)request {
    NSString *response = [request responseString];
    SBJsonParser *parser = [SBJsonParser new];
	NSDictionary* jsonData = [parser objectWithString: response];
	[parser release];
}

-(void)verifyReceipt:(NSData *)receipt ForUserProduct:(NSDictionary *)productInfo{
    _networkQueue = [ASINetworkQueue queue];
	[_networkQueue retain];
	NSURL *verifyURL = [NSURL URLWithString:VAILDATING_RECEIPTS_URL];
    
    NSString *userID = [productInfo objectForKey:@"userID"];
    
	ECPurchaseFormDataRequest *request = [[ECPurchaseFormDataRequest alloc] initWithURL:verifyURL];
	request.userID = userID;
    [request setProductIdentifier:[productInfo objectForKey:@"identifier"]];
	[request setRequestMethod: @"POST"];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(didFinishVerifyReceiptBefore:)];
	
	[request addRequestHeader: @"Content-Type" value: @"application/json"];
	
	NSString *recepit = [GTMBase64 stringByEncodingData:receipt];
    
    NSString *platform = [DeviceDetection platform];
    
	[request setPostValue:recepit forKey:@"receipt-data"];
    [request setPostValue:userID forKey:@"user-ID"];
    [request setPostValue:platform forKey:@"device-platform"];
	
    [_networkQueue addOperation: request];
	[_networkQueue go];
}

-(void)didFinishVerifyReceiptBefore:(ECPurchaseFormDataRequest *)request{
    NSString *response = [request responseString];
    SBJsonParser *parser = [SBJsonParser new];
	NSDictionary* jsonData = [parser objectWithString: response];
    NSDictionary* datasource = [jsonData objectForKey:@"datasource"];
	[parser release];
    NSString *ourServerStatus = [jsonData objectForKey: @"status"];
    if ([ourServerStatus intValue] == 200) {
        NSString *status = [datasource objectForKey: @"status"];
        if ([status intValue] == 0) {
            NSDictionary *receipt = [datasource objectForKey: @"receipt"];
            NSString *productIdentifier = [receipt objectForKey: @"product_id"];
            [_transactionDelegate didCompleteTransactionAndVerifySucceed:productIdentifier];
            [self removeReceiptWithUserID:request.userID andIdentifier:request.productIdentifier];
        }
        else {
            NSString *exception = [datasource objectForKey: @"exception"];
            [_transactionDelegate didCompleteTransactionAndVerifyFailed:request.productIdentifier withError:exception];
        }
    } else {
        NSString *exception = [datasource objectForKey: @"exception"];
        [_transactionDelegate didCompleteTransactionAndVerifyFailed:request.productIdentifier withError:exception];
    }
    [self removeReceiptWithUserID:request.userID andIdentifier:request.productIdentifier];
}

-(void)didFailedVerifyReceiptBefore:(ECPurchaseFormDataRequest *)request{
    
}

#pragma mark -
#pragma mark Get Property From ECStoreObserver
-(NSMutableArray *)getCompleteTrans{
	return _storeObserver.completeTrans;
}

-(NSMutableArray *)getRestoreTrans{
	return _storeObserver.restoreTrans;
}

-(NSMutableArray *)getFailedTrans{
	return _storeObserver.failedTrans;
}

#pragma mark -
#pragma mark Temp Receipt Store
-(NSMutableDictionary *)getLocalStoredReceipt{
   /*
    NSString *path=[[NSBundle mainBundle] pathForResource:@"tempReceipt" ofType:@"plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExist = [fileManager fileExistsAtPath:path];
    if (!fileExist) {
        NSData *newData = (NSData *)[[NSMutableDictionary alloc] init];
        NSLog(@"%@",[fileManager createFileAtPath:path contents:newData attributes:nil] ? @"YES" : @"NO");
        [newData release];
    }
    NSDictionary *tempDic = [[NSDictionary alloc] initWithContentsOfFile:path];
    */
    NSDictionary *tempDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"LocalReceipts"];
    NSMutableDictionary *mutableDic = [tempDic mutableCopy];
    return [mutableDic autorelease];
}

- (void)setLocalStoredReceipt:(NSDictionary *)receipts {
    [[NSUserDefaults standardUserDefaults] setObject:receipts forKey:@"LocalReceipts"];
}

-(void)storeTempUserReceipt:(NSDictionary *)userTransInfo{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableDictionary *localStoredReceipt = [self getLocalStoredReceipt];
    if (!localStoredReceipt) {
        localStoredReceipt = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    NSString *userID = [userTransInfo objectForKey:@"userID"];
    NSString *productIdentifier = [userTransInfo objectForKey:@"identifier"];
    NSData *transactionReceipt = [userTransInfo objectForKey:@"receipt"];
    
    NSMutableDictionary *theUserReceipts = [[localStoredReceipt objectForKey:userID] mutableCopy];
    if (!theUserReceipts) {
        theUserReceipts = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    [theUserReceipts setObject:transactionReceipt forKey:productIdentifier];
    
    [localStoredReceipt setObject:theUserReceipts forKey:userID];
    
    [self setLocalStoredReceipt:localStoredReceipt];
    
    [theUserReceipts release];
    [pool release];
}

-(BOOL)isSameReceiptNotVerifyWithServerWithUserInfo:(NSDictionary *)userPurchaseInfo{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableDictionary *localStoredReceipt = [self getLocalStoredReceipt];
    
    NSString *userID = [userPurchaseInfo objectForKey:@"userID"];
    NSString *productIdentifier = [userPurchaseInfo objectForKey:@"identifier"];
    
    NSDictionary *theUserReceipts = [localStoredReceipt objectForKey:userID];
    BOOL isHaveThisProduct = [theUserReceipts objectForKey:productIdentifier] ? YES : NO;
    
    [pool release];
    
    return isHaveThisProduct;
}

-(void)removeReceiptWithUserID:(NSString *)userID andIdentifier:(NSString *)identifier{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableDictionary *localStoredReceipt = [self getLocalStoredReceipt];
    NSMutableDictionary *theUserReceipts = [[localStoredReceipt objectForKey:userID] mutableCopy];
    [theUserReceipts removeObjectForKey:identifier];
    if (!theUserReceipts) {
        [localStoredReceipt removeObjectForKey:userID];
        [theUserReceipts release];
        [pool release];
        return;
    }
    
    [localStoredReceipt setObject:theUserReceipts forKey:userID];
    
    [self setLocalStoredReceipt:theUserReceipts];
    
    [theUserReceipts release];
    [pool release];
}

-(void)verifyProductReceiptUserPurchasedBefore:(NSDictionary *)productInfo{
    NSMutableDictionary *localStoredReceipt = [self getLocalStoredReceipt];
    
    NSString *userID = [productInfo objectForKey:@"userID"];
    NSString *productIdentifier = [productInfo objectForKey:@"identifier"];
    
    NSDictionary *theUserReceipts = [localStoredReceipt objectForKey:userID];
    NSData *transactionReceipt = [theUserReceipts objectForKey:productIdentifier];

    [self verifyReceipt:transactionReceipt ForUserProduct:productInfo];
}

-(void)verifyReceiptsStoredOnLocal{
    NSDictionary *receiptDic = [self getLocalStoredReceipt];
    if (!receiptDic) {
        return;
    } 

    NSArray *userIDs = [receiptDic allKeys];
    
    if (![userIDs count] <=0) {
        return;
    }
    
    for (NSString *userID in userIDs) {
        NSDictionary *oneUserReceiptDic = [receiptDic objectForKey:userID];
        NSArray *userProductIdentities = [oneUserReceiptDic allKeys];
        for (NSString *productIdentity in userProductIdentities) {
            if ([oneUserReceiptDic objectForKey:productIdentity]) {
                [self verifyProductReceiptUserPurchasedBefore:
                    [NSDictionary dictionaryWithObjectsAndKeys: 
                     userID, @"userID", productIdentity, @"identifier", nil]];
            }
        }
    }
}

-(void)dealloc
{
	RELEASE_SAFELY(_networkQueue);
	RELEASE_SAFELY(_storeObserver);
	[super dealloc];
}

@end