//
//  PatryDetailTableVC.h
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatryDetailTableVC : UIViewController<UITableViewDelegate>{
   
}

@property (nonatomic,strong) IBOutlet UIToolbar *toolBar;

- (IBAction)toolbarItemSelected:(id)sender;

@end
