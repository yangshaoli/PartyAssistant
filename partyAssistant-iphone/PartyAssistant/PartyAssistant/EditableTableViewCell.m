#import "EditableTableViewCell.h"
#import "JFTextViewNoInset.h"

static const CGFloat kTextViewWidth = 320;

#define kFontSize ([UIFont systemFontSize])

static const CGFloat kTextViewInset = 31;
static const CGFloat kTextViewVerticalPadding = 15;
static const CGFloat kTopPadding = 6;
static const CGFloat kBottomPadding = 6;

static UIFont *textViewFont;
static UITextView *dummyTextView;

@implementation EditableTableViewCell

@synthesize delegate;
@synthesize textView;
@synthesize text;

+ (UITextView *)createTextView {
    UITextView *newTextView = [[JFTextViewNoInset alloc] initWithFrame:CGRectZero];
    newTextView.font = textViewFont;
    newTextView.backgroundColor = [UIColor clearColor];
    newTextView.opaque = YES;
    newTextView.scrollEnabled = YES;
    newTextView.showsVerticalScrollIndicator = NO;
    newTextView.showsHorizontalScrollIndicator = NO;
    newTextView.contentInset = UIEdgeInsetsZero;
    
    return newTextView;
}

+ (UITextView *)dummyTextView {
    return dummyTextView;
}


+ (CGFloat)heightForText:(NSString *)text {
    if (text == nil || text.length == 0) {
        text = @"Xy";
    }
    
    dummyTextView.text = text;
    
    CGSize textSize = dummyTextView.contentSize;
    
    return textSize.height + kBottomPadding + kTopPadding - 1;
}


+ (void)initialize {
    textViewFont = [UIFont systemFontOfSize:kFontSize];
    dummyTextView = [EditableTableViewCell createTextView];
    dummyTextView.alpha = 0.0;
    dummyTextView.frame = CGRectMake(0, 0, kTextViewWidth, 500);
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        textView = [EditableTableViewCell createTextView];
        textView.delegate = self;
        [self.contentView addSubview:textView];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"收起" style:UIBarButtonItemStyleBordered target:self action:@selector(resignActive)];
        
        CGRect bounds = [[UIScreen mainScreen] bounds];
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, bounds.size.height, 44.0f)];
        toolBar.items = [NSArray arrayWithObjects:item, item1, nil];
        textView.inputAccessoryView = toolBar;
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect contentRect = self.contentView.bounds;

    contentRect.origin.y += kTopPadding;
    contentRect.size.height -= kTopPadding + kBottomPadding;

    textView.frame = contentRect;
    textView.contentOffset = CGPointZero;

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setText:(NSMutableString *)newText {
    if (newText != text) {
        textView.text = newText;
        NSLog(@"New height: %f", textView.contentSize.height);
    }
}


#pragma mark -
#pragma mark UITextView delegate


- (void) textViewDidBeginEditing:(UITextView *)theTextView {
    if ([delegate respondsToSelector:@selector(editableTableViewCellDidBeginEditing:)]) {
        [delegate editableTableViewCellDidBeginEditing:self];
    }
}


- (void)textViewDidEndEditing:(UITextView *)theTextView {
    [text setString:theTextView.text];

    if ([delegate respondsToSelector:@selector(editableTableViewCellDidEndEditing:)]) {
        [delegate editableTableViewCellDidEndEditing:self];
    }
}


- (void)textViewDidChange:(UITextView *)theTextView {
    CGFloat suggested = [self suggestedHeight];
    
    if (fabs(suggested - self.frame.size.height) > 0.01) {
        NSLog(@"Difference requires change");
        if ([delegate respondsToSelector:@selector(editableTableViewCell:heightChangedTo:)]) {
            [delegate editableTableViewCell:self heightChangedTo:suggested];
        }
    }
}

- (CGFloat)suggestedHeight {
    return textView.contentSize.height + kTopPadding + kBottomPadding - 1;
}

- (void)resignActive {
    [textView resignFirstResponder];
}
@end
