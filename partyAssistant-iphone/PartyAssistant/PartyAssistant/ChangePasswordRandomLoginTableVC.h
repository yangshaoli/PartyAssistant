//
//  ChangePasswordRandomLoginTableVC.h
//  PartyAssistant
//
//  Created by user on 12-1-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordRandomLoginTableVC : UITableViewController{
  UITextField *nPasswordTextField;
  UITextField *resurePasswordTextField;
}
@property(nonatomic,retain)UITextField *nPasswordTextField;
@property(nonatomic,retain)UITextField *resurePasswordTextField;

@end
