//
//  CoolButton.h
//
#import <UIKit/UIKit.h>

@interface GlossyButton : UIButton {
    CGFloat _hue;
    CGFloat _saturation;
    CGFloat _brightness;
}

@property  CGFloat hue;
@property  CGFloat saturation;
@property  CGFloat brightness;

@end

