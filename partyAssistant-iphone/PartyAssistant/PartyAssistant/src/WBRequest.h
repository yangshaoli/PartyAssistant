//
//  WBRequest.h
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

@protocol WBRequestDelegate;

typedef enum
{
	WBRequestPostDataType_Normal,				//for normal data post,such as "user=name&password=psd"
	WBRequestPostDataType_Multipart,			//for uploading the images and files.
}WBRequestPostDataType;


//Instead of using this interface directly, you should use the methods in weibo.h.
//But still you shoud use the protocol WBRequestDelegate in this header file.

@interface WBRequest : NSObject {
	id<WBRequestDelegate> _delegate;
	
	NSString*             _url;
	NSString*             _httpMethod;
	NSMutableDictionary*  _params;
	WBRequestPostDataType _postDataType;
	NSDictionary*		  _headerFieldsInfo;
	
	NSURLConnection*      _connection;
	NSMutableData*        _responseText;
}

@property(nonatomic,assign) id<WBRequestDelegate> delegate;

@property(nonatomic,copy) NSString* url;						//the URL which will be contacted to excute the request

@property(nonatomic,copy) NSString* httpMethod;					//such as:"GET","POST" and so on.

@property(nonatomic) WBRequestPostDataType postDataType;		//only valid when the method is "POST"

@property(nonatomic,copy) NSDictionary* headerFieldsInfo;		//the header info of the request which you want to create.

@property(nonatomic,retain) NSMutableDictionary* params;		//The dictionary of parameters to pass to the method.
																//for "GET", these will be converted to string and add at last of the URL.
																//for "POST",these will be used for post data.

@property(nonatomic,assign) NSURLConnection*  connection;		//Normally, you should not use these two properties.
@property(nonatomic,assign) NSMutableData* responseText;


+ (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod;


+ (WBRequest*)getRequestWithParams:(NSMutableDictionary *) params
                        httpMethod:(NSString *) httpMethod 
					  postDataType:(WBRequestPostDataType) postDataType	
                          delegate:(id<WBRequestDelegate>)delegate
                        requestURL:(NSString *) url 
				  headerFieldsInfo:(NSDictionary*)headerFieldsInfo;

//Check whether the current request is connected.
- (BOOL) loading;			

- (void) connect;

@end


@protocol WBRequestDelegate <NSObject>

@optional
- (void)requestLoading:(WBRequest *)request;											//Called just before the request is sent to the server.

- (void)request:(WBRequest *)request didReceiveResponse:(NSURLResponse *)response;		//Called when the server responds and begins to send back data.

- (void)request:(WBRequest *)request didFailWithError:(NSError *)error;					//Called when an error prevents the request from completing successfully.

- (void)request:(WBRequest *)request didLoadRawResponse:(NSData *)data;					//Called when a request returns and its response has been parsed into an object.
																						//The resulting object may be a dictionary, an array, a string, or a number,
																						//depending on thee format of the API response.

- (void)request:(WBRequest *)request didLoad:(id)result;								//Called when a request returns a response.The result object is the raw response from the server of type NSData

@end