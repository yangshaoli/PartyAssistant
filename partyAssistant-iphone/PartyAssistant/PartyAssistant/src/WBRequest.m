//
//  WBRequest.m
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

#import "WBRequest.h"
#import <UIKit/UIKit.h>
#import "WBUtil.h"
#import "JSON.h"
#import "WeiBo.h"

static const NSTimeInterval kTimeoutInterval = 180.0;
static NSString* kStringBoundary = @"293iosfksdfkiowjksdf31jsiuwq003s02dsaffafass3qw";

@implementation WBRequest
@synthesize delegate = _delegate,
url = _url,
httpMethod = _httpMethod,
params = _params,
connection = _connection,
responseText = _responseText,
postDataType = _postDataType,
headerFieldsInfo = _headerFieldsInfo;


+ (WBRequest*)getRequestWithParams:(NSMutableDictionary *) params
                        httpMethod:(NSString *) httpMethod 
					  postDataType:(WBRequestPostDataType) postDataType
                          delegate:(id<WBRequestDelegate>)delegate
                        requestURL:(NSString *) url 
				  headerFieldsInfo:(NSDictionary*)headerFieldsInfo
{
	WBRequest* request = [[WBRequest alloc] init];
	request.delegate = delegate;
	request.url = url;
	request.httpMethod = httpMethod;
	request.postDataType = postDataType;
	request.params = params;
	request.headerFieldsInfo = headerFieldsInfo;
	request.connection = nil;
	request.responseText = nil;
	
	return [request autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private
+ (NSString*)stringFromDictionary:(NSDictionary*)dicInfo
{
	NSMutableArray* pairs = [NSMutableArray array];
	for (NSString* key in [dicInfo keyEnumerator]) 
	{
		if( ([[dicInfo valueForKey:key] isKindOfClass:[NSString class]]) == FALSE)
		{
			NSLog(@"Please Use NSString for this kind of params");
			continue;
		}
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[dicInfo objectForKey:key]URLEncodedString]]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

/**
 * Generate get URL
 */

+ (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod 
{	
	if ( [httpMethod isEqualToString:@"GET"] == FALSE )
		return baseUrl;
		
	NSURL* parsedURL = [NSURL URLWithString:baseUrl];
	NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString* query = [WBRequest stringFromDictionary:params];
	
	return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}


- (void)utfAppendBody:(NSMutableData *)body data:(NSString *)data {
	[body appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}


- (NSMutableData *)generatePostBody {
	NSMutableData *body = [NSMutableData data];
	
	if( _postDataType != WBRequestPostDataType_Multipart )
	{
		[self utfAppendBody:body data:[WBRequest stringFromDictionary:_params]];
	}
	else
	{
		NSString *bodyPrefixString   = [NSString stringWithFormat:@"--%@\r\n", kStringBoundary];
		NSString *bodySuffixString   = [NSString stringWithFormat:@"\r\n--%@--\r\n", kStringBoundary];
		
		NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
		
		[self utfAppendBody:body data:bodyPrefixString];
		
		for (id key in [_params keyEnumerator]) 
		{
			if ( ([[_params valueForKey:key] isKindOfClass:[UIImage class]]) || ([[_params valueForKey:key] isKindOfClass:[NSData class]]) )
			{
				[dataDictionary setObject:[_params valueForKey:key] forKey:key];
				continue;
			}
			
			[self utfAppendBody:body data:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",key,[_params valueForKey:key]]];
			[self utfAppendBody:body data:bodyPrefixString];
		}
		
		if ([dataDictionary count] > 0) 
		{
			for (id key in dataDictionary) 
			{
				NSObject *dataParam = [dataDictionary valueForKey:key];
				
				if ([dataParam isKindOfClass:[UIImage class]]) 
				{
					NSData* imageData = UIImagePNGRepresentation((UIImage*)dataParam);
					[self utfAppendBody:body data:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file.png\"\r\n", key]];
					[self utfAppendBody:body data:[NSString stringWithString:@"Content-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n"]];
					[body appendData:imageData];
				} 
				else if ([dataParam isKindOfClass:[NSData class]]) 
				{
					[self utfAppendBody:body data:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key]];
					[self utfAppendBody:body data:[NSString stringWithString:@"Content-Type: content/unknown\r\nContent-Transfer-Encoding: binary\r\n\r\n"]];
					[body appendData:(NSData*)dataParam];
				}
				[self utfAppendBody:body data:bodySuffixString];
			}
		}
	}
	return body;
}

- (id)formError:(NSInteger)code userInfo:(NSDictionary *) errorData 
{
	return [NSError errorWithDomain:domainWeiboError code:code userInfo:errorData];
	
}

- (id)parseJsonResponse:(NSData *)data error:(NSError **)error {
	
	NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	SBJSON *jsonParser = [[SBJSON alloc]init];
	
	NSError* parserError = nil;
	id result = [jsonParser objectWithString:responseString error:&parserError];
	
	if( parserError )
		*error = [self formError:CodeWeiboError_SDK 
						userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",CodeWeiboSDKError_ParserError] forKey:keyCodeWeiboSDKError]];
	
	[responseString release];
	[jsonParser release];
	

	if( [result isKindOfClass:[NSDictionary class]] )
	{
		if( [result objectForKey:@"error_code"] != nil && [[result objectForKey:@"error_code"]intValue] != 200 )
		{
			if (error != nil) 
			{
				*error = [self formError:CodeWeiboError_Platform userInfo:result];
			}
		}
	}
	
	return result;
	
}

- (void)failWithError:(NSError *)error 
{
	if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) 
	{
		[_delegate request:self didFailWithError:error];
	}
}

- (void)handleResponseData:(NSData *)data 
{
	if ([_delegate respondsToSelector:@selector(request:didLoadRawResponse:)]) 
	{
		[_delegate request:self didLoadRawResponse:data];
	}
	
	NSError* error = nil;
	id result = [self parseJsonResponse:data error:&error];
	
	if (error) 
	{
		[self failWithError:error];
	} 
	else 
	{
		if([_delegate respondsToSelector:@selector(request:didLoad:)]) 
		{
			[_delegate request:self didLoad:(result == nil ? data : result)];
		}
	}
}
//////////////////////////////////////////////////////////////////////////////////////////////////
// public
- (BOOL)loading {
	return !!_connection;
}

- (void)connect {
	
	if ([_delegate respondsToSelector:@selector(requestLoading:)]) 
	{
		[_delegate requestLoading:self];
	}
	
	NSString* url = [[self class] serializeURL:_url params:_params httpMethod:_httpMethod];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:kTimeoutInterval];
	
	[request setHTTPMethod:self.httpMethod];
	
	if ([self.httpMethod isEqualToString: @"POST"]) 
	{
		if( _postDataType == WBRequestPostDataType_Multipart )
		{
			NSString* contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kStringBoundary];
			[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
		}
		
		[request setHTTPBody:[self generatePostBody]];
	}
	
	for (NSString* key in [_headerFieldsInfo keyEnumerator])
		[request setValue:[_headerFieldsInfo objectForKey:key] forHTTPHeaderField:key];

	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
}

- (void)dealloc {
	[_connection cancel];
	[_connection release];
	[_responseText release];
	[_url release];
	[_httpMethod release];
	[_params release];
	[_headerFieldsInfo release];
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	_responseText = [[NSMutableData alloc] init];
	
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	if ([_delegate respondsToSelector:
		 @selector(request:didReceiveResponse:)]) {
		[_delegate request:self didReceiveResponse:httpResponse];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_responseText appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
				  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self handleResponseData:_responseText];
	
	[_responseText release];
	_responseText = nil;
	[_connection release];
	_connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self failWithError:error];
	
	[_responseText release];
	_responseText = nil;
	[_connection release];
	_connection = nil;
}

@end
