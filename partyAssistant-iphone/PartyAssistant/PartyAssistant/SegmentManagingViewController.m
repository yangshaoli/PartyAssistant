    //
//  SegmentManagingViewController.m
//  SegmentedControlExample
//
//  Created by Marcus Crafter on 24/05/10.
//  Copyright 2010 Red Artisan. All rights reserved.
//

#import "SegmentManagingViewController.h"
#import "NSArray+PerformSelector.h"
#import "MultiContactsPickerListViewController.h"
#import "MultiFavoritesContactsList.h"
//#import "AustraliaViewController.h"

@interface SegmentManagingViewController ()

@property (nonatomic, strong, readwrite) IBOutlet UISegmentedControl * segmentedControl;
@property (nonatomic, strong, readwrite) UIViewController            * activeViewController;
@property (nonatomic, strong, readwrite) NSArray                     * segmentedViewControllers;


- (void)didChangeSegmentControl:(UISegmentedControl *)control;
- (NSArray *)segmentedViewControllerContent;

@end

@implementation SegmentManagingViewController

@synthesize segmentedControl, activeViewController, segmentedViewControllers;
@synthesize contactDataDelegate;
@synthesize currentContactData;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.currentContactData = [NSMutableArray arrayWithArray:[self.contactDataDelegate getCurrentContactData]];
    
    self.segmentedViewControllers = [self segmentedViewControllerContent];

    NSArray * segmentTitles = [self.segmentedViewControllers arrayByPerformingSelector:@selector(title)];
    //NSArray *segmentTitles = [NSArray arrayWithObjects:@"test", @"test", nil];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTitles];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;

    [self.segmentedControl addTarget:self
                              action:@selector(didChangeSegmentControl:)
                    forControlEvents:UIControlEventValueChanged];

    self.navigationItem.titleView = self.segmentedControl;

    [self didChangeSegmentControl:self.segmentedControl]; // kick everything off
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectContactFinished)];
    
    self.navigationItem.rightBarButtonItem = right;
}

- (NSArray *)segmentedViewControllerContent {

    MultiFavoritesContactsList * controller1 = [[MultiFavoritesContactsList alloc] initWithParentViewController:self];
    controller1.contactListDelegate = self;
    MultiContactsPickerListViewController * controller2 = [[MultiContactsPickerListViewController alloc] initWithParentViewController:self];
    controller2.contactListDelegate = self;
    
    
    NSArray * controllers = [NSArray arrayWithObjects:controller1, controller2, nil];

    return controllers;
}

#pragma mark -
#pragma mark Segment control

- (void)didChangeSegmentControl:(UISegmentedControl *)control {
    if (self.activeViewController) {
        [self.activeViewController viewWillDisappear:NO];
        [self.activeViewController.view removeFromSuperview];
        [self.activeViewController viewDidDisappear:NO];
    }

    self.activeViewController = [self.segmentedViewControllers objectAtIndex:control.selectedSegmentIndex];

    [self.activeViewController viewWillAppear:NO];
    [self.view addSubview:self.activeViewController.view];
    [self.activeViewController viewDidAppear:NO];

    NSString * segmentTitle = [control titleForSegmentAtIndex:control.selectedSegmentIndex];
    self.navigationItem.backBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:segmentTitle style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark -
#pragma mark View life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.activeViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.activeViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.activeViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.activeViewController viewDidDisappear:animated];
}

#pragma mark -
#pragma mark UINavigationControllerDelegate control

// Required to ensure we call viewDidAppear/viewWillAppear on ourselves (and the active view controller)
// inside of a navigation stack, since viewDidAppear/willAppear insn't invoked automatically. Without this
// selected table views don't know when to de-highlight the selected row.

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController viewDidAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController viewWillAppear:animated];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    for (UIViewController * viewController in self.segmentedViewControllers) {
        [viewController didReceiveMemoryWarning];
    }
}

- (void)viewDidUnload {
    self.segmentedControl         = nil;
    self.segmentedViewControllers = nil;
    self.activeViewController     = nil;

    [super viewDidUnload];
}
#pragma mark -
#pragma mark Mutil contact list delegate
- (NSMutableArray *)dataSourceForContactList:(MultiContactsPickerListViewController *)contactList {
    return self.currentContactData;
}

- (void)selectContactFinished {
    [self.contactDataDelegate setNewContactData:self.currentContactData];
    [self.contactDataDelegate selectedFinishedInController:self];
}
@end
