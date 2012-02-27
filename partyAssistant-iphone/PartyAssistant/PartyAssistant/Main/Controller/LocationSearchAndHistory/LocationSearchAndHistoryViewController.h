//
//  LocationSearchAndHistoryViewController.h
//  LocationSearchAndHistory
//
//  Created by Wang Jun on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BMapKit.h"
#import "PartyAssistantAppDelegate.h"

#define MyApp (PartyAssistantAppDelegate *)[[UIApplication sharedApplication] delegate]

@interface CustomSearchBar : UISearchBar
@property (readwrite, retain) IBOutlet UIView *inputAccessoryView;
@end

@interface LocationSearchAndHistoryViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,BMKSearchDelegate,UISearchDisplayDelegate,UITextFieldDelegate,CLLocationManagerDelegate>{
   
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    BMKSearch *_searchPoi;
    
    UITableView *_tableView;
    
    NSString *_lastSearch;
    NSString *_lastCity;
    
    NSMutableArray *_poiHistoryItems;
    NSMutableArray *_poiSearchResults;
    
    UIToolbar *_searchTypeToolBar;
    UITextField *_searchCityTF;
    UISegmentedControl *_searchTypesegment;
    
    UIControl *_searchTouchDetectView;
    
    CLLocationCoordinate2D currentSearchLocation;
    
    NSInteger _currentResultCount;
    
    BMKMapManager *_mapManager;
    
    BOOL showNotAvailableAlert;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
@property (retain, readonly) BMKSearch *searchPoi;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSString *lastSearch;
@property (nonatomic, retain) NSString *lastCity;

@property (nonatomic, retain) NSMutableArray *poiHistoryItems;
@property (nonatomic, retain) NSMutableArray *poiSearchResults;

@property (nonatomic, retain) IBOutlet UIToolbar *searchTypeToolBar;
@property (nonatomic, retain) IBOutlet UITextField *searchCityTF;
@property (nonatomic, retain) IBOutlet UISegmentedControl *searchTypesegment;

@property (nonatomic, retain) IBOutlet UIControl *searchTouchDetectView;

@property (nonatomic, readonly) BMKMapManager *mapManager;

- (IBAction)SearchBarBecomeFirstResponder:(id)sender;

- (IBAction)selecitionTypeChanged:(id)sender;

@end