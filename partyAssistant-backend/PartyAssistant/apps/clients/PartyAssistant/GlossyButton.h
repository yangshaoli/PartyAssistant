//
//  CoolButton.h
//
#import <UIKit/UIKit.h>

@interface GlossyButton : UIButton {
    CGFloat _hue;
    CGFloat _saturation;
    CGFloat _brightness;
}

@property (nonatomic)CGFloat hue;
@property (nonatomic)CGFloat saturation;
@property (nonatomic)CGFloat brightness;

@end

