//
//  WeiBo.h
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
#import "WBSendView.h"
#import "WBAuthorize.h"

extern NSString* domainWeiboError;						//The domain of the error which we defined and will be returned in all the protocols.

typedef enum
{
	CodeWeiboError_Platform	= 100,
	CodeWeiboError_SDK		= 101,
}CodeWeiboError;										//The code of the error which we defined and will be returned in all the protocols.

extern NSString* keyCodeWeiboSDKError;					//The key of the SDK error info which is A key-value pair of the userinfo of the error that we defined and will be returned in all the protocols.
typedef enum
{
	CodeWeiboSDKError_ParserError		= 200,
	CodeWeiboSDKError_GetRequestError	= 201,
	CodeWeiboSDKError_GetAccessError	= 202,
	CodeWeiboSDKError_NotAuthorized		= 203,
}CodeWeiboSDKError;										//The value of the SDK error info which is A key-value pair of the userinfo of the error that we defined and will be returned in all the protocols.



@class WBAuthorize;
@protocol WBSessionDelegate;
@protocol WBAuthorizeDelegate;


@interface WeiBo : NSObject <WBRequestDelegate,WBAuthorizeDelegate>{
	NSString* _appKey;
	NSString* _appSecret;
	
	WBAuthorize* _authorize;
	
	NSString* _userID;
	NSString* _accessToken;
	NSString* _accessTokenSecret;
	
	WBSendView * _sendView;
	WBRequest* _request;
	
	id<WBSessionDelegate> _delegate;
}

@property (nonatomic,retain,readonly) NSString* userID;
@property (nonatomic,retain,readonly) NSString* accessToken;
@property (nonatomic,retain,readonly) NSString* accessTokenSecret;

@property (nonatomic,assign) id<WBSessionDelegate> delegate;

- (NSString*)urlSchemeString;				//You should set the url scheme of your app with the string this function returned.

- (id)initWithAppKey:(NSString*)app_key		//Normally, you must use this function to init your object of WeiBo.
	  withAppSecret:(NSString*)app_secret;

- (void)startAuthorize;						//Use this method to start authorizing user info,and safari will be opend automaticly.
- (BOOL)handleOpenURL:(NSURL *)url;			//You should perform this method in the function named "handURL" in your app delegate.  


- (WBRequest*)postWeiboRequestWithText:(NSString*)text							//Just create an URL request to post one weibo with text and image.
							  andImage:(UIImage*)image
						   andDelegate:(id <WBRequestDelegate>)delegate;

- (WBRequest*)requestWithMethodName:(NSString *)methodName						//Create a request with all these infos.
                          andParams:(NSMutableDictionary *)params
                      andHttpMethod:(NSString *)httpMethod
                        andDelegate:(id <WBRequestDelegate>)delegate;

- (BOOL)isUserLoggedin;					//Check whether the user has logged in.
- (void)LogOut;							//Remove the info about current user.

- (void)showSendViewWithWeiboText:(NSString*) weiboText 
						 andImage:(UIImage*)image 
					  andDelegate:(id)delegate;

- (void)dismissSendView;
@end

@protocol WBSessionDelegate <NSObject>

@optional
- (void)weiboDidLogin;
- (void)weiboLoginFailed:(BOOL)userCancelled withError:(NSError*)error;
- (void)weiboDidLogout;
@end
