//
//  WeiBo.m
//  SinaWeiBoSDK
//

//  Copyright 2011 Sina. All rights reserved.
//

#import "WeiBo.h"
#import "WBUtil.h"
#import "SFHFKeychainUtils.h"

#define WeiBoSchemePre				@"wb"

#define kKeyChainServiceNameForWeiBo		@"_WeiBoUserInfo"

#define kKeyChainUserIDForWeiBo				@"userID"
#define kKeyChainAccessTokenForWeiBo		@"accessToken"
#define kKeyChainAccessSecretForWeiBo		@"accessSecret"

NSString* domainWeiboError = @"domainWeiboError";
NSString* keyCodeWeiboSDKError = @"weibo_error_code";

static NSString* weiboHttpRequestDomain		= @"http://api.t.sina.com.cn/";



@implementation WeiBo
@synthesize userID = _userID,accessToken = _accessToken,accessTokenSecret = _accessTokenSecret,delegate=_delegate;

- (NSString*)urlSchemeString
{
	return [NSString stringWithFormat:@"%@%@",WeiBoSchemePre,_appKey];
}

- (id)initWithAppKey:(NSString*)app_key 
	  withAppSecret:(NSString*)app_secret
{
	if (self = [super init]) {
		_appKey		= [[NSString alloc]initWithString:app_key];
		_appSecret	= [[NSString alloc]initWithString:app_secret];
		
		
		//When object is created, the user info stored in the KeyChain will be readed out firstly.
		NSString* serviceName = [[self urlSchemeString] stringByAppendingString:kKeyChainServiceNameForWeiBo];
		_userID = [[SFHFKeychainUtils getPasswordForUsername:kKeyChainUserIDForWeiBo andServiceName:serviceName error:nil]retain];
		_accessToken = [[SFHFKeychainUtils getPasswordForUsername:kKeyChainAccessTokenForWeiBo andServiceName:serviceName error:nil]retain];
		_accessTokenSecret = [[SFHFKeychainUtils getPasswordForUsername:kKeyChainAccessSecretForWeiBo andServiceName:serviceName error:nil]retain];
	}
	return self;
}

- (void)dealloc
{
	[_appKey release];_appKey=nil;
	[_appSecret release];_appSecret=nil;
	
	if( _userID ){[_userID release];_userID=nil;}
	if( _accessToken ){[_accessToken release];_accessToken=nil;}
	if( _accessTokenSecret ){[_accessTokenSecret release];_accessTokenSecret=nil;}
	
	if (_authorize){[_authorize release];_authorize = nil;}
	
	[super dealloc];
}

#pragma mark -
#pragma mark For User Authorize
- (void)startAuthorize
{
	//First we check out whether the user has been logged in.
	if( [self isUserLoggedin] )
	{
		if( [_delegate respondsToSelector:@selector(weiboDidLogin)] )
			[_delegate weiboDidLogin];
		return;
	}
	
	if( _authorize )
	{
		[_authorize release];
		_authorize = nil;
	}
	
	//Then we should listen whether the user authorizes correctly when the app is reactive.
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(applicationLauched:)
												name:UIApplicationDidBecomeActiveNotification
											  object:nil];

	//Finally, an object of WBAuthorize is created and started.
	_authorize = [[WBAuthorize alloc]initWithAppKey:_appKey withAppSecret:_appSecret withWeiBoInstance:self];
	[_authorize startAuthorize];
	_authorize.delegate = self;
}

- (void)applicationLauched:(NSNotification *)notification
{
	if( _authorize && _authorize.waitingUserAuthorize )
	{
		//If the user does not authorize correctly, we tell the delegate that it failed.
		_authorize.waitingUserAuthorize = FALSE;
		if( [_delegate respondsToSelector:@selector(weiboLoginFailed:withError:)] )
			[_delegate weiboLoginFailed:YES withError:nil];
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
	if (![[url absoluteString] hasPrefix:[self urlSchemeString]]) {
		return NO;
	}
	
	//Just start the third step of OAuth when the application is reactive correctly.
	NSString *query = [url query];
	[_authorize finishAuthorizeWithString:query];
	return TRUE;
}

- (void)authorizeSuccess:(WBAuthorize*)auth userID:(NSString*)userID oauthToken:(NSString*)token oauthSecret:(NSString*)secret
{
	if( _userID ){[_userID release];_userID=nil;}
	if( _accessToken ){[_accessToken release];_accessToken=nil;}
	if( _accessTokenSecret ){[_accessTokenSecret release];_accessTokenSecret=nil;}
	
	_userID = [userID retain];
	_accessToken = [token retain];
	_accessTokenSecret = [secret retain];
	
	//If authorize succeed, the user info will be stored in the keychain.
	NSString* serviceName = [[self urlSchemeString] stringByAppendingString:kKeyChainServiceNameForWeiBo];
	[SFHFKeychainUtils storeUsername:kKeyChainUserIDForWeiBo andPassword:_userID forServiceName:serviceName updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:kKeyChainAccessTokenForWeiBo andPassword:_accessToken forServiceName:serviceName updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:kKeyChainAccessSecretForWeiBo andPassword:_accessTokenSecret forServiceName:serviceName updateExisting:YES error:nil];
	
	//and then tell the delegate.
	if( [_delegate respondsToSelector:@selector(weiboDidLogin)] )
		[_delegate weiboDidLogin];
}

- (void)authorizeFailed:(WBAuthorize*)auth withError:(NSError*)error
{
	//If the authorize failed, just tell the delegate.
	if( [_delegate respondsToSelector:@selector(weiboLoginFailed:withError:)] )
		[_delegate weiboLoginFailed:NO withError:error];
}

- (void)removeInfo
{
	//remove the info stored in the keychain.
	NSString* serviceName = [[self urlSchemeString] stringByAppendingString:kKeyChainServiceNameForWeiBo];
	[SFHFKeychainUtils deleteItemForUsername:kKeyChainUserIDForWeiBo andServiceName:serviceName error:nil];
	[SFHFKeychainUtils deleteItemForUsername:kKeyChainAccessTokenForWeiBo andServiceName:serviceName error:nil];
	[SFHFKeychainUtils deleteItemForUsername:kKeyChainAccessSecretForWeiBo andServiceName:serviceName error:nil];
	
	//remove the info in the memory.
	if( _userID ){[_userID release];_userID=nil;}
	if( _accessToken ){[_accessToken release];_accessToken=nil;}
	if( _accessTokenSecret ){[_accessTokenSecret release];_accessTokenSecret=nil;}
}

- (BOOL)isUserLoggedin
{
	//If all the three params are exist, we count that the user has been logged in.
	return _userID && _accessToken && _accessTokenSecret;
}

- (void)LogOut
{
	//Log out just means removing all the user info.
	[self removeInfo];
	
	if( [_delegate respondsToSelector:@selector(weiboDidLogout)] )
		[_delegate weiboDidLogout];
}

#pragma mark -
#pragma mark For Http Request
//this funcion is used for posting multipart datas.
- (WBRequest*)postRequestWithMethodName:(NSString *)methodName
							  andParams:(NSMutableDictionary *)params
						andPostDataType:(WBRequestPostDataType)postDataType
							andDelegate:(id <WBRequestDelegate>)delegate
{
	//Before this function is used, user authorizing must be finished firstly.
	//Otherwise, an error will be throwed out.
	if( [self isUserLoggedin] == FALSE )
	{
		if( [delegate respondsToSelector:@selector(request:didFailWithError:)] )
			[delegate request:nil didFailWithError:[NSError errorWithDomain:domainWeiboError 
																	   code:CodeWeiboError_SDK 
																   userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",CodeWeiboSDKError_NotAuthorized] forKey:keyCodeWeiboSDKError]]];
		return nil;
	}
	
	if( _request )
	{
		[_request release];
		_request = nil;
	}
	
	_request = [WBRequest getAuthorizeRequestWithParams:params
											 httpMethod:@"POST"
										   postDataType:postDataType 
											   delegate:delegate 
											 requestURL:[NSString stringWithFormat:@"%@%@",weiboHttpRequestDomain,methodName]
									   headerFieldsInfo: nil 
												 appKey:_appKey	
											  appSecret:_appSecret
											accessToken:_accessToken
										   accessSecret:_accessTokenSecret];
	
	[_request connect];
	[_request retain];
	
	return _request;
}

- (WBRequest*)requestWithMethodName:(NSString *)methodName
                          andParams:(NSMutableDictionary *)params
                      andHttpMethod:(NSString *)httpMethod
                        andDelegate:(id <WBRequestDelegate>)delegate
{
	if( [self isUserLoggedin] == FALSE )
	{
		if( [delegate respondsToSelector:@selector(request:didFailWithError:)] )
			[delegate request:nil didFailWithError:[NSError errorWithDomain:domainWeiboError 
																	   code:CodeWeiboError_SDK 
																   userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",CodeWeiboSDKError_NotAuthorized] forKey:keyCodeWeiboSDKError]]];
		return nil;
	}
	
	if( _request )
	{
		[_request release];
		_request = nil;
	}
	
	_request = [WBRequest getAuthorizeRequestWithParams:params
											 httpMethod:httpMethod
										   postDataType:WBRequestPostDataType_Normal 
											   delegate:delegate 
											 requestURL:[NSString stringWithFormat:@"%@%@",weiboHttpRequestDomain,methodName]
									   headerFieldsInfo: nil 
												 appKey:_appKey	
											  appSecret:_appSecret
											accessToken:_accessToken
										   accessSecret:_accessTokenSecret];
	
	[_request connect];
	[_request retain];
	
	return _request;
}

#pragma mark For Post Weibo
- (WBRequest*)postWeiboRequestWithText:(NSString*)text
							  andImage:(UIImage*)image 
						   andDelegate:(id <WBRequestDelegate>)delegate
{
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
	[params setObject:text?text:@"" forKey:@"status"];
	if( image )
		[params setObject:image forKey:@"pic"];
	
	
	if( image )
		return [self postRequestWithMethodName:@"statuses/upload.json" 
									 andParams:params 
							   andPostDataType:WBRequestPostDataType_Multipart 
								   andDelegate:delegate];
	else
		return [self requestWithMethodName:@"statuses/update.json" 
								 andParams:params 
							 andHttpMethod:@"POST" 
							   andDelegate:delegate];
}

- (void)showSendViewWithWeiboText:(NSString*) weiboText andImage:(UIImage*)image andDelegate:(id<WBSendViewDelegate>)WBSendDelegate
{
	[_sendView release];
    _sendView = [[WBSendView alloc] initWithWeiboText:weiboText withImage:image andDelegate:WBSendDelegate];
	_sendView.weibo = self;
     [_sendView show];
}

- (void)dismissSendView
{
	[_sendView dismiss:YES];
}

 




@end
