//
//  WBAuthorize.h
//  SinaWeiBoSDK
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  Copyright 2011 Sina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBRequest.h"


//Same as "WBRequest", this interface should also not be used directly.
//Meanwhile, the protocol "WBAuthorizeDelegate" should not be used directly either.
//Instead, you should use the functions in "weibo.h" and the protocol named "WBSessionDelegate" for user authorizing.


#define WeiBoAuthorizeCallBack		@"callback"
@class WBAuthorize;

@protocol WBAuthorizeDelegate <NSObject>


- (void)authorizeSuccess:(WBAuthorize*)auth userID:(NSString*)userID oauthToken:(NSString*)token oauthSecret:(NSString*)secret;	//Called when authorization succeed and all useful info will be returned.
- (void)authorizeFailed:(WBAuthorize*)auth withError:(NSError*)error;															//Called when authorization failed.

@end

@class WeiBo;
@interface WBAuthorize : NSObject <WBRequestDelegate>{
	NSString*				_appKey;
	NSString*				_appSecret;
	
	WBRequest*				_request;
	WeiBo*					_weibo;
	
	NSString*				_requestToken;
	NSString*				_requestSecret;
	
	id<WBAuthorizeDelegate> _delegate;
	
	BOOL					_waitingUserAuthorize;
}

@property (nonatomic,assign) id<WBAuthorizeDelegate> delegate;
@property (nonatomic) BOOL waitingUserAuthorize;					//Mark whether check the user has been authorized when the app is rerunned.

- (id)initWithAppKey:(NSString*)app_key 
	   withAppSecret:(NSString*)app_secret 
   withWeiBoInstance:(WeiBo*)weibo;

- (void)startAuthorize;
- (void)finishAuthorizeWithString:(NSString*)pageReturnString;
@end


//The gategory of the interface "WBRequest"
//Only one function used for creating a request using the authorized info with OAuth. 
@interface WBRequest (WBAuthorize)
+ (WBRequest*)getAuthorizeRequestWithParams:(NSMutableDictionary *) params
								 httpMethod:(NSString *) httpMethod 
							   postDataType:(WBRequestPostDataType) postDataType					//only valid when http method is "POST"
								   delegate:(id<WBRequestDelegate>)delegate
								 requestURL:(NSString *) url 
						   headerFieldsInfo:(NSDictionary*)headerFieldsInfo 
									 appKey:(NSString*)appkey 
								  appSecret:(NSString*)secret
								accessToken:(NSString*)token 
							   accessSecret:(NSString*)secret;
@end

