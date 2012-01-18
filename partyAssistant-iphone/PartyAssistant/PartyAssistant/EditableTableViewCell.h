#import <UIKit/UIKit.h>
#import "EditableTableViewCellDelegate.h"

@class CustomTextView;
@interface EditableTableViewCell : UITableViewCell<UITextViewDelegate> {
}

@property(nonatomic, assign) id<NSObject, EditableTableViewCellDelegate> delegate;
@property(nonatomic, readonly, retain) CustomTextView *textView;
@property(nonatomic, retain) NSMutableString *text;

+ (UITextView *)dummyTextView;
+ (CGFloat)heightForText:(NSString *)text;

- (CGFloat)suggestedHeight;

@end
