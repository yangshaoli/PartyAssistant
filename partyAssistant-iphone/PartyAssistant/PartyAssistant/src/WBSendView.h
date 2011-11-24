//
//  WBSendView.h
//  DemoApp
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
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WBRequest.h"

@protocol WBSendViewDelegate;

@class WeiBo;

@interface WBSendView : UIView <UITextViewDelegate,WBRequestDelegate>{

	id<WBSendViewDelegate> _delegate;

	UIDeviceOrientation _orientation;
	BOOL _showingKeyboard;
	
	WeiBo * _weibo;				// the instance of Weibo posts new weibo and handles all requests
	
	UITextView * _weiboContentTextView;
	UIButton * _sendWeiboButton; 
	UIButton * _clearTextButton;
	UILabel * _titleLabel;
	UILabel * _wordCountLabel;
	
	UIView * _panelView;
	
	UIImageView * _weiboImageView;
	UIButton * _clearImageButton;
	
	UIImage * _weiboImageData;
	UIImageView* _panelImageView;
	
}

@property(nonatomic,assign) id<WBSendViewDelegate> delegate;
@property(nonatomic,assign) WeiBo * weibo;

/*
  You should not initialze the sendview in your viewController with this function, 
  using [_weibo showSendViewWithWeiboText:andImage:andDelegate:] instead,
  or draw the UI youself and implement [_weibo postWeiboRequestWithText:andImage:andDelegate:] to send new weibo. 
 
*/
- (id)initWithWeiboText:(NSString*) weiboText withImage:(UIImage*)image andDelegate:(id)del;   

//show and dismiss the sendview 
- (void)show;
- (void)dismiss:(BOOL)animated;

@end



@protocol WBSendViewDelegate <NSObject>

@optional

/**
 * Called when the sendView shows and dismisses.
 */

- (void)sendViewWillAppear:(WBSendView*)sendView;		//Called when the sendview will appear.

- (void)sendViewDidLoad:(WBSendView*)sendView;			//Called when the sendview is loaded.

- (void)sendViewWillDisappear:(WBSendView*)sendView;	//Called when the sendview is about to dissmiss.

- (void)sendViewDidDismiss:(WBSendView*)sendView;		//Called when the sendview is dismissed.

//network request callbacks

//Called when an error prevents the request from completing successfully.
- (void)request:(WBRequest *)request didFailWithError:(NSError *)error; 

//Called when the request is successed, you may dismiss the sendview via this callback
- (void)request:(WBRequest *)request didLoad:(id)result;

@end