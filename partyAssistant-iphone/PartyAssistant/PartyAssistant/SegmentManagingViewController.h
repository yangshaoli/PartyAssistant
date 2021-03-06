
#import <UIKit/UIKit.h>
#import "MultiContactsPickerListViewController.h"

@protocol ContactDataDelegate 

- (NSArray *)getCurrentContactData;
- (void)setNewContactData : (NSArray *)newData;
- (void)selectedFinishedInController:(UIViewController *)vc;
- (void)selectedCancelInController:(UIViewController *)vc;

@end

@interface SegmentManagingViewController : UIViewController <UINavigationControllerDelegate,MultiContactsPickerListViewControllerDelegate> {
    UISegmentedControl    * segmentedControl;
    UIViewController      * activeViewController;
    NSArray               * segmentedViewControllers;
    NSMutableArray        * currentContactData;
}

@property (nonatomic, strong, readonly) IBOutlet UISegmentedControl * segmentedControl;
@property (nonatomic, strong, readonly) UIViewController            * activeViewController;
@property (nonatomic, strong, readonly) NSArray                     * segmentedViewControllers;
@property (nonatomic, strong) id <ContactDataDelegate> contactDataDelegate;
@property (nonatomic, strong) NSMutableArray        *currentContactData;

@end
