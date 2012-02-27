//
//  LocationSearchAndHistoryViewController.m
//  LocationSearchAndHistory
//
//  Created by Wang Jun on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationSearchAndHistoryViewController.h"
#import "LocationHistory.h"
#import "LocationSearchResult.h"

@implementation CustomSearchBar 

@synthesize inputAccessoryView;

@end

@interface LocationSearchAndHistoryViewController (SearchResult)

- (void)rebuildResult;
- (void)searchPoiDidEnd;
- (void)fetchStoredLocationHistory;
- (void)storeSelectedResult:(LocationSearchResult *)resultItem;
- (NSArray *)selectSameLocationFromHistory:(LocationSearchResult *)newLocationData;
- (void)touchTheLocationFromHistory:(LocationHistory *)locationData;
- (void)removeLastLocationFromHistory;

@end

@implementation LocationSearchAndHistoryViewController
@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize searchPoi = _searchPoi;
@synthesize tableView = _tableView;
@synthesize lastSearch = _lastSearch;
@synthesize lastCity = _lastCity;
@synthesize poiHistoryItems = _poiHistoryItems;
@synthesize poiSearchResults = _poiSearchResults;
@synthesize searchTypeToolBar = _searchTypeToolBar;
@synthesize searchCityTF = _searchCityTF;
@synthesize searchTypesegment = _searchTypesegment;
@synthesize searchTouchDetectView = _searchTouchDetectView;
@synthesize mapManager = _mapManager;

#pragma mark - dealloc
- (void)dealloc {
    [managedObjectModel release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    
    [_searchPoi release];
    [_tableView release];
    
    [_lastSearch release];
    [_lastCity release];
    
    [_poiSearchResults release];
    
    [_searchTypeToolBar release];
    [_searchCityTF release];
    [_searchTypesegment release];
    
    [_searchTouchDetectView release];
    
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSManagedObjectModel *model = [self managedObjectModel];
    NSFetchRequest * requestTemplate = [[NSFetchRequest alloc]init];
    NSEntityDescription *publicationEntity =
    [[model entitiesByName] objectForKey: @"LocationHistory"];
    [requestTemplate setEntity: publicationEntity];
    
    NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:
                                      @"(locationName == $locationName) AND \
                                      (latitude == $latitude) AND \
                                      (longitude == $longitude)"];
    [requestTemplate setPredicate: predicateTemplate];
    
    [model setFetchRequestTemplate: requestTemplate
                           forName: @"fetchSameLocation"];
    [requestTemplate release];
    
    [self fetchStoredLocationHistory];
    
    [[self tableView] reloadData];
    
    [_searchCityTF addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];//创建位置管理器  
    locationManager.delegate=self;//设置代理  
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;//指定需要的精度级别  
    locationManager.distanceFilter=1000.0f;//设置距离筛选器  
    [locationManager startUpdatingLocation];//启动位置管理器 
    /*
    NSManagedObjectContext *context = [self managedObjectContext];
    LocationHistory *history = [NSEntityDescription 
                                insertNewObjectForEntityForName:@"LocationHistory"
                                inManagedObjectContext:context];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    // Test listing all FailedBankInfos from the store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationHistory" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (LocationHistory *history in fetchedObjects) {
        NSLog(@"Name: %@", history.locationName);
    }        
    [fetchRequest release];
     */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return nil;
    } else {
        if (_searchTypesegment.selectedSegmentIndex == 0) {
            return @"搜索当前位置";
        } else {
            return self.lastCity;
        }
    }
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 20;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableView != tableView) {
        return [[self poiSearchResults] count] < _currentResultCount ? [[self poiSearchResults] count] + 1 : _currentResultCount;
    }
    return [[self poiHistoryItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *locationCellIdentifier = @"LocationCell";
    
    UITableViewCell *cell = nil;
    if (!(cell = [tableView dequeueReusableCellWithIdentifier:locationCellIdentifier])) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                          reuseIdentifier:locationCellIdentifier] autorelease];
    }
    
    if (self.tableView == tableView) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [[[self poiHistoryItems] objectAtIndex:indexPath.row] locationName];
        cell.detailTextLabel.text = [[[self poiHistoryItems] objectAtIndex:indexPath.row] locationAddress];
    } else {
        if (indexPath.row == [self.poiSearchResults count]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"more";
            cell.detailTextLabel.text = @"";
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = [[[self poiSearchResults] objectAtIndex:indexPath.row] locationName];
            cell.detailTextLabel.text = [[[self poiSearchResults] objectAtIndex:indexPath.row] locationAddress];
        }
    }
     
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView != tableView) {
        if (indexPath.row == [self.poiSearchResults count]) {
            if (_searchTypesegment.selectedSegmentIndex == 0) {
              [[self searchPoi] poiSearchNearBy:_lastSearch center:currentSearchLocation radius:5000 pageIndex:([self.poiSearchResults count] / 10) + 1];
            } else {
               [[self searchPoi] poiSearchInCity:_lastCity withKey:_lastSearch pageIndex:([self.poiSearchResults count] / 10) + 1];
            }

        } else {
            //store this data
            try {
                [self storeSelectedResult:[[self poiSearchResults] objectAtIndex:indexPath.row]];
                [self rebuildResult];
                [[self searchDisplayController] setActive:NO];
                
                [self fetchStoredLocationHistory];
                
                if ([self.poiHistoryItems count] >= 25) {
                    [self removeLastLocationFromHistory];
                }
                
                [self.tableView reloadData];
            } catch (NSException *e) {
                NSLog(@"%@",e);
            }
        }
    } else {
        
    }
    
}

#pragma mark - searchPoi
- (NSMutableArray *)poiSearchResults {
    if (_poiSearchResults != nil) {
        return _poiSearchResults;
    }
    
    _poiSearchResults = [[NSMutableArray alloc] init];
    
    return _poiSearchResults;
}

- (BMKSearch *)searchPoi {
    if (![self mapManager]) {
        // not available
        // alert!
        if (showNotAvailableAlert) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
            showNotAvailableAlert = YES;
        }
        return nil;
    }
    
    if (_searchPoi != nil) {
        return _searchPoi;
    }

    _searchPoi = [[BMKSearch alloc]init];
    [BMKSearch setPageCapacity:10];
    _searchPoi.delegate = self;

    return _searchPoi;
}

- (void)searchPoiDidBegin:(NSString *)searchName {
     [[self searchPoi] poiSearchNearBy:searchName center:currentSearchLocation radius:5000 pageIndex:0];
}

- (void)searchPoiWithCity:(NSString *)searchCity {
    [[self searchPoi] poiSearchInCity:_lastCity withKey:_lastSearch pageIndex:0];
}

- (void)searchPoiDidEnd {
     [[self.searchDisplayController searchResultsTableView] reloadData];
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[MyApp applicationDocumentsDirectory] stringByAppendingPathComponent: @"LocationHistory.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}

#pragma mark - searchDisplayController delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (_searchTypesegment.selectedSegmentIndex == 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchPoiDidBegin:) object:self.lastSearch];
        
        self.lastSearch = searchText;
        
        if ([searchText length] > 0) {
            [self performSelector:@selector(searchPoiDidBegin:) withObject:searchText afterDelay:1.0f];
        } else {
            [self rebuildResult];
        }
    } else {
        //city search
        if (_searchCityTF.text == nil || [_searchCityTF.text isEqualToString:@""]) {
            return;
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchPoiWithCity:) object:self.lastCity];
        
        self.lastSearch = searchText;
        self.lastCity = _searchCityTF.text;
        
        if ([self.lastCity length] > 0 && [self.lastSearch length] > 0) {
            [self performSelector:@selector(searchPoiWithCity:) withObject:self.lastCity afterDelay:1.0f];
        } else {
            [self rebuildResult];
        }
    }
}

#pragma mark - search poi delegate
- (void)onGetPoiResult:(NSArray*)poiResultList searchType:(int)type errorCode:(int)error
{
	if (error == BMKErrorOk) {
		BMKPoiResult* result = [poiResultList objectAtIndex:0];
        _currentResultCount = result.totalPoiNum;
		for (int i = 0; i < result.poiInfoList.count; i++) {
			BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
			LocationSearchResult* item = [[LocationSearchResult alloc]init];
			item.coordinate = poi.pt;
			item.locationName = poi.name;
            item.locationCity = poi.city;
            item.locationAddress = poi.address;
            
            [[self poiSearchResults] addObject:item];
            NSLog(@"%@",item);
            
			[item release];
		}
        [self searchPoiDidEnd];
	} else if (error == BMKErrorConnect) {
        
    } else if (error == BMKErrorLocationFailed) {
        
    } else {
        
    }
}

#pragma mark - search result
- (void)rebuildResult {
    [[self poiSearchResults] removeAllObjects];
    [self searchPoiDidEnd];
}

- (void)storeSelectedResult:(LocationSearchResult *)resultItem {
    NSAssert(resultItem, @"not nil!");
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSArray *results = [self selectSameLocationFromHistory:resultItem];
    
    if ([results count] > 0) {
        [self touchTheLocationFromHistory:[results lastObject]];
        return;
    }
    
    //creat new data
    LocationHistory *history = [NSEntityDescription 
                                insertNewObjectForEntityForName:@"LocationHistory"
                                inManagedObjectContext:context];
    history.locationName = resultItem.locationName ? resultItem.locationName : @"";
    history.locationAddress = resultItem.locationName ? resultItem.locationAddress : @"";
    history.locationCity = resultItem.locationName ? resultItem.locationCity : @"";
    history.latitude = [NSNumber numberWithDouble:resultItem.coordinate.latitude ? resultItem.coordinate.latitude : 0.f];
    history.longitude = [NSNumber numberWithDouble:resultItem.coordinate.longitude ? resultItem.coordinate.longitude : 0.f];
    history.touchedDate = [NSDate date];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [_searchTouchDetectView setHidden:NO];
    return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    if ([_searchCityTF isFirstResponder]) {
        [_searchCityTF resignFirstResponder];
    }
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {

}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    if ([_searchCityTF isFirstResponder]) {
        [_searchCityTF resignFirstResponder];
    }
}

#pragma mark - history locations
- (void)fetchStoredLocationHistory {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error;
    
    // Test listing all FailedBankInfos from the store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationHistory" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    if ([[[[fetchRequest entity] propertiesByName] allKeys] containsObject:@"touchedDate"]) {
        NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"touchedDate" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByDate]];
        [sortByDate release];
    }
    
    NSMutableArray *fetchedObjects = [[context executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (fetchedObjects == nil) 
    { //如果结果为空，在这作错误响应 
        //return nil;
    }    
    // 将得到的本地数组赋值到本类的全局数组，然后清理无用的对象  
    [self setPoiHistoryItems:fetchedObjects]; 
    
    [fetchedObjects release];
    [fetchRequest release];
    
    //return fetchedObjects;
}

- (NSArray *)selectSameLocationFromHistory:(LocationSearchResult *)newLocationData {
     NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setObject:(newLocationData.locationName ? newLocationData.locationName : @"") forKey:@"locationName"];
    [dictionary setObject:[NSNumber numberWithDouble:newLocationData.coordinate.latitude ? newLocationData.coordinate.latitude : 0.f] forKey:@"latitude"];
    [dictionary setObject:[NSNumber numberWithDouble:newLocationData.coordinate.longitude ? newLocationData.coordinate.longitude : 0.f] forKey:@"longitude"];
    
    NSError *error = nil;    
     
    NSFetchRequest *fetchRequest = [[self managedObjectModel] fetchRequestFromTemplateWithName:@"fetchSameLocation" substitutionVariables:dictionary];
    NSAssert(fetchRequest, @"Can't find question fetch request");
    NSLog(@"dictionary count : %d",[dictionary retainCount]);
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ordinal" ascending:YES];
//    NSArray *sortDescriptors = [[NSMutableArray alloc] initWithObjects:sortDescriptor, nil];
//    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *result = nil;
    result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    [dictionary release];

    return result;
}

- (void)touchTheLocationFromHistory:(LocationHistory *)locationData {
    if (!locationData) {
        return;
    }
    
    NSDate *date = [NSDate date];
    
    [locationData setValue:date forKey:@"touchedDate"];
    
//    locationData.touchedDate = date;
//    
    NSError *error = nil;
    
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
    {
        NSLog(@"!!!!!");
    }
}

- (void)removeLastLocationFromHistory {
    //delete
    NSManagedObjectContext *context = [self managedObjectContext];
    
    LocationHistory *historyItem = [_poiHistoryItems lastObject];
    
    [context deleteObject:historyItem];
    
    
    [_poiHistoryItems removeObject:historyItem];
    
    NSError *error;
    if (![managedObjectContext save:&error]) 
    {    
        
    } 
}

- (IBAction)SearchBarBecomeFirstResponder:(id)sender {
    //NSLog(@"%d",[self.searchDisplayController.searchBar isFirstResponder]);
    [_searchCityTF resignFirstResponder];
    [self.searchDisplayController.searchBar becomeFirstResponder];
    [_searchTouchDetectView setHidden:YES];
    //NSLog(@"%@",self.searchDisplayController.searchBar);
}


- (IBAction)selecitionTypeChanged:(id)sender {
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    
    [self rebuildResult];
    [[[self searchDisplayController] searchResultsTableView] reloadData];
    
    switch (seg.selectedSegmentIndex) {
        case 0:
            _searchCityTF.text = @"";
            _searchCityTF.placeholder = @"以当前位置搜索";
            _searchCityTF.enabled = NO;
            if([self.searchCityTF isFirstResponder]) {
                [self.searchCityTF resignFirstResponder];
            }
            break;
        case 1:
            _searchCityTF.text = self.lastCity;
            _searchCityTF.placeholder = @"请输入要搜索的城市";
            _searchCityTF.enabled = YES;
            [self.searchCityTF becomeFirstResponder];
            break;
        default:
            break;
    }
}

- (void)textFieldDidChange {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchPoiWithCity:) object:self.lastCity];
    
    self.lastSearch = [self.searchDisplayController.searchBar text];
    self.lastCity = _searchCityTF.text;
    
    if ([self.lastCity length] > 0 && [self.lastSearch length] > 0) {
        [self performSelector:@selector(searchPoiWithCity:) withObject:self.lastCity afterDelay:1.0f];
    } else {
        [self rebuildResult];
    }
}

- (void)locationManager:(CLLocationManager *)manager  
    didUpdateToLocation:(CLLocation *)newLocation  
           fromLocation:(CLLocation *)oldLocation  
{  
    currentSearchLocation = newLocation.coordinate;  
    [manager stopUpdatingLocation];
}  
//位置查询遇到错误时调用这个方法  

- (void)locationManager:(CLLocationManager *)manager  
didFailWithError:(NSError *)error  
{  
    [manager stopUpdatingLocation];
    
    NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";  
    UIAlertView *alert = [[UIAlertView alloc]  
                          initWithTitle:@"Error getting Location"  
                          message:errorType  
                          delegate:nil  
                          cancelButtonTitle:@"Okay"  
                          otherButtonTitles:nil];  
    [alert show];  
    [alert release];  
} 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchCityTF resignFirstResponder];
}

- (BMKMapManager *)mapManager {
    if (_mapManager) {
        return _mapManager;
    } 
    
    BMKMapManager *newMapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
	BOOL ret = [newMapManager start:@"58374B30E40B8505383F2D16FCD28B89DE316998" generalDelegate:nil];
	if (!ret) {
		[newMapManager release];
        return nil;
	}
    
    _mapManager = newMapManager;
    
    return newMapManager;
}
@end
