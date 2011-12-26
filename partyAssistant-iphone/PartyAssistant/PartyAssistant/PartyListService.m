//
//  PartyListService.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PartyListService.h"
#import "ContactData.h"
@implementation PartyListService
@synthesize partyList;

SYNTHESIZE_SINGLETON_FOR_CLASS(PartyListService)

- (id)init
{
    self = [super init];
    self.partyList = [self getPartyList];
    return self;
}


- (NSString *)filePathString{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileDirectory=[paths objectAtIndex:0];
    return [fileDirectory stringByAppendingPathComponent:PARTYLISTFILE];
}

//- (NSMutableArray *)getPartyList
//{
////    if (partyList) {
////       
////        return partyList;
////    }
//    
//        
//    NSString* fullPathToFile = [self filePathString];
//    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile];
//    if (fileExists) {
////        NSData *theData = [NSData dataWithContentsOfFile:fullPathToFile];
////        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
//        self.partyList = [[NSMutableArray alloc] initWithContentsOfFile:fullPathToFile];
//    } else {
//        self.partyList = [[NSMutableArray alloc] initWithCapacity:0];
//    }
//    
//    NSLog(@"打印partyList1:%@",partyList);
//    return self.partyList;
//}

- (NSArray *)getPartyList
{
    if (partyList) {
        return partyList;
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:PARTYLISTFILE];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile];
    if (fileExists) {
        NSData *theData = [NSData dataWithContentsOfFile:fullPathToFile];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
        self.partyList = [decoder decodeObjectForKey:PARTYLISTKEY];
    } else {
        self.partyList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    NSLog(@"self.partyList打印》》》%@",self.partyList);
    return self.partyList;
}


//- (void)savePartyList
//{
////    if (!self.partyList) {
////        return;
////    }
//    
////    NSMutableData *theData = [NSMutableData data];
////    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
//    //self.partyList=[[NSMutableArray alloc] initWithObjects:@"自定义活动1",@"自定义活动2",@"自定义活动3", nil];
//    
//    //[self.partyList addObject:@"活动4444"];
////    [encoder encodeObject:self.partyList forKey:PARTYLISTKEY];
////    [encoder finishEncoding];
//    
//    
//    
//    NSString* fullPathToFile = [self filePathString];    
//    
//    PartyModel *partyObj=[[PartyModel alloc] init];
//    partyObj.receiversArray=[[ContactData   contactsArray] mutableCopy];
//    partyObj.contentString=@"踢球,欢迎加入";
//    partyObj.sendBySms=YES;
//    partyObj.sendByServer=NO;
//    partyObj.partyId=1;
//    [self.partyList addObject:partyObj];
//    
//    BOOL isOK = [self.partyList  writeToFile:fullPathToFile atomically:YES];//写入
//    NSLog(@"isOK....%@",isOK);
//    NSLog(@"文件路径：：%@",fullPathToFile);
//     NSLog(@"savePartyList....self.partyList.count在方法中打印%d",self.partyList.count);
//}
- (void)savePartyList
{
    if (!self.partyList) {
        return;
    }
    
    NSMutableData *theData = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
    
    [encoder encodeObject:self.partyList forKey:PARTYLISTKEY];
    [encoder finishEncoding];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:PARTYLISTFILE];
    [theData writeToFile:fullPathToFile atomically:YES];
}


//- (NSMutableArray *)addPartyList:(PartyModel *)partyObj
//{
//    NSString* fullPathToFile = [self filePathString];
//    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile];
//    if (fileExists) {
//        //        NSData *theData = [NSData dataWithContentsOfFile:fullPathToFile];
//        //        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
//        self.partyList = [[NSMutableArray alloc] initWithContentsOfFile:fullPathToFile];
//    } else {
//        self.partyList = [[NSMutableArray alloc] initWithCapacity:0];
//    }
//    [self.partyList addObject:partyObj];
//    return self.partyList;
//}

- (NSArray *)addPartyList:(PartyModel *)partyObj
{
    [self.partyList addObject:partyObj];
    return partyList;
}

- (void)clearPartyList
{
    self.partyList = [[NSMutableArray alloc]initWithCapacity:0];
}

@end
