//
//  SendSMSInCopyPartyTableViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseInfoObject.h"
#import "SMSObject.h"


@interface SendSMSInCopyPartyTableViewController : UITableViewController
{
    BaseInfoObject  *baseinfo;
    SMSObject *smsObject;
}

@property(nonatomic, retain)BaseInfoObject *baseinfo;
@property(nonatomic, retain)SMSObject *smsObject;

@end
