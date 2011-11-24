//
//  WBSendView.m
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

#import "WBSendView.h"
#import "WBRequest.h"
#import "WeiBo.h"
#import "WBUtil.h"
 

//check whether the device is and iPad or not
BOOL WBIsDeviceIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	}
#endif
	return NO;
}

//private functions
@interface WBSendView (Private)
- (void)textLengthCount;
- (void)sizeToFitOrientation:(BOOL)transform;
- (void)sendViewWillAppear;
- (void)sendViewWillDisappear;
- (void)addObservers;
- (void)removeObservers;
- (BOOL)shouldRotateToOrientation:(UIDeviceOrientation)orientation;
- (int)calculateTextNumber:(NSString *) textA;
- (void)postDismissCleanup;

@end


@implementation WBSendView

@synthesize delegate = _delegate, weibo = _weibo; 

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (id)initWithWeiboText:(NSString*) weiboText withImage:(UIImage*)image andDelegate:(id)del
{
	self = [super initWithFrame:CGRectMake(0,0,320,480)];
    if (self) {
        // Initialization code.
		
		//make the background semi-transparent
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 		
		
		//add the panel view
		_panelView = [[UIView alloc] initWithFrame:CGRectMake(16, 73, 288, 335)];
		_panelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 288, 335)];
		_panelImageView.image = [[UIImage imageNamed:@"bg.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:18];
 
		[_panelView addSubview:_panelImageView];
  		[self addSubview:_panelView];
 		
		//add buttons and title
		UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.showsTouchWhenHighlighted = YES;
		closeButton.frame = CGRectMake(15, 13, 48, 30);
		[closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"btn.png"] forState:UIControlStateNormal];
		[closeButton setTitle:NSLocalizedStringFromTable(@"关闭",@"SendViewLocalize",nil) forState:UIControlStateNormal];
		closeButton.titleLabel.font = [UIFont boldSystemFontOfSize: 13.0f];
		[closeButton addTarget:self action:@selector(closeBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
		[_panelView addSubview:closeButton];
 		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 12, 140, 30)];
		_titleLabel.text = NSLocalizedStringFromTable(@"新浪微博",@"SendViewLocalize",nil);
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textAlignment = UITextAlignmentCenter;
		_titleLabel.center = CGPointMake(144, 27);
		[_titleLabel setShadowOffset:CGSizeMake(0, 1)];
		[_titleLabel setShadowColor:[UIColor whiteColor]];
		_titleLabel.font = [UIFont systemFontOfSize:19];
		[_panelView addSubview:_titleLabel];
		
		_sendWeiboButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_sendWeiboButton.showsTouchWhenHighlighted = YES;
		_sendWeiboButton.frame = CGRectMake(288-15-48, 13, 48, 30);
		[_sendWeiboButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_sendWeiboButton setBackgroundImage:[UIImage imageNamed:@"btn.png"] forState:UIControlStateNormal];
		[_sendWeiboButton setTitle: NSLocalizedStringFromTable(@"发送",@"SendViewLocalize",nil)  forState:UIControlStateNormal];
		_sendWeiboButton.titleLabel.font = [UIFont boldSystemFontOfSize: 13.0f];
		[_sendWeiboButton addTarget:self action:@selector(sendBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
		[_panelView addSubview:_sendWeiboButton];
		
		_weiboContentTextView = [[UITextView alloc] initWithFrame:CGRectMake(13,60,288-26,150)];
		_weiboContentTextView.editable = YES;
		_weiboContentTextView.delegate = self;
		_weiboContentTextView.text = weiboText;
		_weiboContentTextView.backgroundColor = [UIColor clearColor];
		_weiboContentTextView.font = [UIFont systemFontOfSize:16];// [UIFont systemFontOfSize:[UIFont labelFontSize]];
 		[_panelView addSubview:_weiboContentTextView];
		
		_wordCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(210,190,30,30)];
		_wordCountLabel.backgroundColor = [UIColor clearColor];
		_wordCountLabel.textColor = [UIColor darkGrayColor];
		_wordCountLabel.font = [UIFont systemFontOfSize:16];
		_wordCountLabel.textAlignment = UITextAlignmentCenter;
		[_panelView addSubview:_wordCountLabel];
		
		_clearTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_clearTextButton.showsTouchWhenHighlighted = YES;
		_clearTextButton.frame = CGRectMake(240,191,30,30);
		[_clearTextButton setContentMode:UIViewContentModeCenter];
 		[_clearTextButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
		[_clearTextButton addTarget:self action:@selector(clearBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
		[_panelView addSubview:_clearTextButton];
		
		[self textLengthCount];
		
		//if an image is attached, display the image under the text.
		if(image)
		{
			_weiboImageData = image;
			
			CGSize imageSize = image.size;	
			CGFloat height = imageSize.height;
			CGFloat width = imageSize.width;
			CGRect tframe = CGRectMake(0, 0, 0, 0);
			if (width > height) {
				tframe.size.width = 120;
				tframe.size.height = height * (120 / width);
			}
			else {
				tframe.size.height = 80;
				tframe.size.width = width * (80 / height);
			}
			
			
			_weiboImageView = [[UIImageView alloc] initWithFrame:tframe];
			_weiboImageView.image = image;
			_weiboImageView.center = CGPointMake(144,260);
			
			CALayer *layer = [_weiboImageView layer];
			layer.borderColor = [[UIColor whiteColor] CGColor];
			layer.borderWidth = 5.0f;
			
			_weiboImageView.layer.shadowColor = [UIColor blackColor].CGColor;
			_weiboImageView.layer.shadowOffset = CGSizeMake(0, 0);
			_weiboImageView.layer.shadowOpacity = 0.5; 
			_weiboImageView.layer.shadowRadius = 3.0;
			
			
			[_panelView addSubview:_weiboImageView];
 			
			_clearImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_clearImageButton.showsTouchWhenHighlighted = YES;
			_clearImageButton.frame = CGRectMake(0,0,30,30);
			[_clearImageButton setContentMode:UIViewContentModeCenter];
			[_clearImageButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
			[_clearImageButton addTarget:self action:@selector(clearImageBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
			[_panelView addSubview:_clearImageButton];
			
			_clearImageButton.center = CGPointMake(_weiboImageView.center.x+_weiboImageView.frame.size.width/2, _weiboImageView.center.y-_weiboImageView.frame.size.height/2);
		}
		
		//set delegate for callbacks
		_delegate = del;
		
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/
-(void)show
{
	[self sizeToFitOrientation:NO];
	
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
  	[window addSubview:self];
	
 
	[self sendViewWillAppear];

	CGAffineTransform tramsform;
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
		tramsform =  CGAffineTransformMakeRotation(M_PI*1.5);
	} else if (orientation == UIInterfaceOrientationLandscapeRight) {
		tramsform =  CGAffineTransformMakeRotation(M_PI/2);
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		tramsform =  CGAffineTransformMakeRotation(-M_PI);
	} else {
		tramsform =  CGAffineTransformIdentity;
		
	}
	
	self.transform = CGAffineTransformScale(tramsform, 0.001, 0.001);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3/1.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
	self.transform = CGAffineTransformScale(tramsform, 1.1, 1.1);
	[UIView commitAnimations];
	
	[self addObservers];
}

-(void)closeBtnTouched:(id)sender
{
	[self dismiss:YES];
}

-(void)sendBtnTouched:(id)sender
{

	if ([_weiboContentTextView.text isEqual: @""]) {
		UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"新浪微博",@"SendViewLocalize",nil)  message:NSLocalizedStringFromTable(@"请输入微博内容",@"SendViewLocalize",nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"确定",@"SendViewLocalize",nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}
	[_weibo postWeiboRequestWithText:_weiboContentTextView.text andImage:_weiboImageData andDelegate:self];
}

-(void)clearBtnTouched:(id)sender
{
	_weiboContentTextView.text = @"";
	[self textLengthCount];
}

-(void)clearImageBtnTouched:(id)sender
{
	_weiboImageView.hidden = YES;
	_clearImageButton.hidden = YES;  
	_weiboImageData = nil;
}

- (void)dismiss:(BOOL)animated {

	[self sendViewWillDisappear];
	
	 
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(postDismissCleanup)];
		self.alpha = 0;
		[UIView commitAnimations];
	} else {
		
		[self postDismissCleanup];
	}
}

- (void)postDismissCleanup
{
	[self removeObservers];
	[self removeFromSuperview];	
	
	if ([_delegate respondsToSelector:@selector(sendViewDidDismiss:)]) 
	{
		[_delegate sendViewDidDismiss:self];
	}
}
 

- (void)dealloc {


	[_weiboContentTextView release];
	[_titleLabel release];
	[_wordCountLabel release];
 	
 	[_weiboImageView release];
 	[_panelImageView release];
 	[_panelView release];
     
	[super dealloc];
}

- (CGAffineTransform)transformForOrientation {
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
		return CGAffineTransformMakeRotation(M_PI*1.5);
	} else if (orientation == UIInterfaceOrientationLandscapeRight) {
		return CGAffineTransformMakeRotation(M_PI/2);
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return CGAffineTransformMakeRotation(-M_PI);
	} else {
		return CGAffineTransformIdentity;
		
	}
}

- (void)bounce1AnimationStopped {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3/2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
	self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
	[UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3/2];
	self.transform = CGAffineTransformScale([self transformForOrientation], 1, 1);
	[UIView commitAnimations];
	
	if ([_delegate respondsToSelector:@selector(sendViewDidLoad:)]) 
	{
		[_delegate sendViewDidLoad:self];
	}
}

- (void)addObservers {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIKeyboardWillShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIKeyboardWillHideNotification" object:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIDeviceOrientationDidChangeNotification

- (void)deviceOrientationDidChange:(void*)object {
	
	
	UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if ( [self shouldRotateToOrientation:orientation]) {
 		
		CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
		[self sizeToFitOrientation:YES];
		[UIView commitAnimations];
	}
}

- (BOOL)shouldRotateToOrientation:(UIDeviceOrientation)orientation {
	if (orientation == _orientation) {
		return NO;
	} else {
		return orientation == UIDeviceOrientationLandscapeLeft
		|| orientation == UIDeviceOrientationLandscapeRight
		|| orientation == UIDeviceOrientationPortrait
		|| orientation == UIDeviceOrientationPortraitUpsideDown;
	}
}

- (void)sizeToFitOrientation:(BOOL)transform {
 
	if (transform) {
		self.transform = CGAffineTransformIdentity;
	}
	
	CGRect screenFrame = [UIScreen mainScreen].applicationFrame;
	CGPoint screenCenter = CGPointMake(
								 screenFrame.origin.x + ceil(screenFrame.size.width/2),
								 screenFrame.origin.y + ceil(screenFrame.size.height/2));
	 
	_orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(_orientation)) {
		
		self.frame = CGRectMake(0, 0, 480, 320);
		_panelView.frame = CGRectMake(16, 10, 480-32, 280);

		_weiboContentTextView.frame = CGRectMake(13,50,480-32-26,60+50);
		
		_weiboImageView.center = CGPointMake( 448/2,155+60);
		_clearImageButton.center = CGPointMake(_weiboImageView.center.x+_weiboImageView.frame.size.width/2, _weiboImageView.center.y-_weiboImageView.frame.size.height/2);

		_wordCountLabel.frame = CGRectMake(224+90,100+60,30,30);
		_clearTextButton.frame = CGRectMake(224+120,101+60,30,30);
		_panelImageView.frame = CGRectMake(0, 0, 480-32, 280);
		_panelImageView.image = [UIImage imageNamed:@"bg_land.png"];
		_sendWeiboButton.frame = CGRectMake(480-32-15-48, 13, 48, 30);
		_titleLabel.center = CGPointMake(448/2, 27);
		
		if(_showingKeyboard)
		{
			_weiboContentTextView.frame = CGRectMake(13,50,480-32-26,60);
			
			_weiboImageView.center = CGPointMake( 448/2,155);
			_clearImageButton.center = CGPointMake(_weiboImageView.center.x+_weiboImageView.frame.size.width/2, _weiboImageView.center.y-_weiboImageView.frame.size.height/2);
			
			_wordCountLabel.frame = CGRectMake(224+90,100,30,30);
			_clearTextButton.frame = CGRectMake(224+120,101,30,30);
		}

		
	} else {
		self.frame = CGRectMake(0, 0, 320, 480);
		
		_panelView.frame = CGRectMake(16, 73-10, 288, 335);
		
		if(_showingKeyboard)
			_panelView.frame = CGRectMake(16, 73-10-51, 288, 335);
		
		_weiboContentTextView.frame = CGRectMake(13,60,288-26,150);
		_weiboImageView.center = CGPointMake(144,260);
		_clearImageButton.center = CGPointMake(_weiboImageView.center.x+_weiboImageView.frame.size.width/2, _weiboImageView.center.y-_weiboImageView.frame.size.height/2);
		
		_wordCountLabel.frame = CGRectMake(210,190,30,30);
		_clearTextButton.frame = CGRectMake(240,191,30,30);
		_panelImageView.frame = CGRectMake(0, 0, 288, 335);
		_panelImageView.image = [UIImage imageNamed:@"bg.png"];

		_sendWeiboButton.frame = CGRectMake(288-15-48, 13, 48, 30);
		_titleLabel.center = CGPointMake(144, 27);

	}
	self.center = screenCenter;
	
	if (transform) {
		self.transform = [self transformForOrientation];
	}
}

 
///////////////////////////////////////////////////////////////////////////////////////////////////
// UIKeyboardNotifications

- (void)keyboardWillShow:(NSNotification*)notification {
	
	_showingKeyboard = YES;
	
	if (WBIsDeviceIPad()) {
		//does not support iPad screen in this version
		return;
	}
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
	 
 		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
 		
		_weiboContentTextView.frame = CGRectMake(13,50,480-32-26,60);
		_weiboImageView.center = CGPointMake( 448/2,155);
		_clearImageButton.center = CGPointMake(_weiboImageView.center.x+_weiboImageView.frame.size.width/2, _weiboImageView.center.y-_weiboImageView.frame.size.height/2);
		_wordCountLabel.frame = CGRectMake(224+90,100,30,30);
		_clearTextButton.frame = CGRectMake(224+120,101,30,30);
		 
 		[UIView commitAnimations];
	}
	else {
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		
		_panelView.frame = CGRectInset(_panelView.frame, 0,-51);
		
 		[UIView commitAnimations];
	}
}

- (void)keyboardWillHide:(NSNotification*)notification {
	_showingKeyboard = NO;
	
	if (WBIsDeviceIPad()) {
		return;
	}
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
 		
		_weiboContentTextView.frame = CGRectMake(13,50,480-32-26,60+50);
		_weiboImageView.center = CGPointMake( 448/2,155+60);
		_clearImageButton.center = CGPointMake(_weiboImageView.center.x+_weiboImageView.frame.size.width/2, _weiboImageView.center.y-_weiboImageView.frame.size.height/2);
		_wordCountLabel.frame = CGRectMake(224+90,100+60,30,30);
		_clearTextButton.frame = CGRectMake(224+120,101+60,30,30);
		
 		[UIView commitAnimations];
	}
	else {
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		
		_panelView.frame = CGRectInset(_panelView.frame, 0,51);
		
		[UIView commitAnimations];
	}

}

 
- (void)sendViewWillAppear {
	
	if ([_delegate respondsToSelector:@selector(sendViewWillAppear:)]) 
	{
		[_delegate sendViewWillAppear:self];
	}
}

- (void)sendViewWillDisappear {
	
	if ([_delegate respondsToSelector:@selector(sendViewWillDisappear:)]) 
	{
		[_delegate sendViewWillDisappear:self];
	}
}


#pragma mark -
#pragma mark UITextViewDelegate method

- (void)textViewDidChange:(UITextView *)textView
{
	[self textLengthCount];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	
    return YES;
}

- (void)textLengthCount
{
	if (_weiboContentTextView.text.length > 0) 
	{ 
		_sendWeiboButton.enabled = YES;
		[_sendWeiboButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	else 
	{
		 
		_sendWeiboButton.enabled = NO;
		[_sendWeiboButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	}
	
	int wordcount = [self calculateTextNumber:_weiboContentTextView.text];
	NSInteger count  = 140 - wordcount;
	if (count < 0) {
		_wordCountLabel.textColor = [UIColor redColor];
		_sendWeiboButton.enabled = NO;
		[_sendWeiboButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	}
	else {
		_wordCountLabel.textColor = [UIColor darkGrayColor];
		_sendWeiboButton.enabled = YES;
		[_sendWeiboButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	
	_wordCountLabel.text = [NSString stringWithFormat:@"%i",count];
}

-(int)calculateTextNumber:(NSString *) textA
{
	float number = 0.0;
	int index = 0;
	for (index; index < [textA length]; index++) {
		
		NSString *character = [textA substringWithRange:NSMakeRange(index, 1)];
		
		if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3) {
			number++;
		} else {
			number = number+0.5;
		}
	}
	return ceil(number);
}

#pragma mark WBRequest CALLBACK_API
- (void)request:(WBRequest *)request didFailWithError:(NSError *)error
{
	if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) 
	{
		[_delegate request:request didFailWithError:error];
	}
}

 
- (void)request:(WBRequest *)request didLoad:(id)result
{
	if ([_delegate respondsToSelector:@selector(request:didLoad:)]) 
	{
		[_delegate request:request didLoad:result];
	}
}

@end
