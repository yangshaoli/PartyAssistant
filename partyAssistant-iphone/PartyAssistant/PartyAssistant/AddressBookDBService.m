//
//  AddressBookDBService.m
//  PartyAssistant
//
//  Created by Yang Shaoli on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AddressBookDBService.h"
#import "SynthesizeSingleton.h"
#import "DBSettings.h"
#import "ABContact.h"
#import "ClientObject.h"

@implementation AddressBookDBService
@synthesize myFavorites;
SYNTHESIZE_SINGLETON_FOR_CLASS(AddressBookDBService)// 单例类，保证类只有一个实例

- (AddressBookDBService *)init {
    if ((self = [super init])) {
        self.myFavorites = [[NSMutableArray alloc] initWithCapacity:MyFavoriteInitMaxLength];
        [self loadMyFavorites];
    }
    return self;
}

- (sqlite3 *)getOrCreateTableIfNotExist {
    sqlite3 *database = nil;
    char *errorMsg = nil;
    NSString *strPaths = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), DBFileName];
    if (sqlite3_open([strPaths UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open databse");
    }
        
    NSString *createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (Id INTEGER PRIMARY KEY AUTOINCREMENT, ABRecordID INTEGER, contactName TEXT, indentifier INTEGER,phoneLabel TEXT,phoneNumber TEXT,usageCount INTEGER)", MyFavoriteTableName];
    if(sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg ) != SQLITE_OK) {
        NSAssert1(1, @"Error create table :%s", errorMsg);
        sqlite3_free(errorMsg);
        sqlite3_close(database);
        return nil;
    } 
    createSQL = [NSString stringWithFormat:@"CREATE INDEX INDX01 ON %@ (usageCount)", MyFavoriteTableName];
    if(sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg ) != SQLITE_OK) {
        NSAssert1(1, @"Error create table :%s", errorMsg);
        sqlite3_free(errorMsg);
    } 
    
    return database;
}

- (void)loadMyFavorites {
    sqlite3 *database = [self getOrCreateTableIfNotExist];
    if(database){
        [self loadMyFavoritesByDB:database];
        sqlite3_close(database);
    }
}

- (void)loadMyFavoritesByDB:(sqlite3 *)database {
    [self.myFavorites removeAllObjects];
    
    ABContact *contact = nil;
    
    NSString *query = [NSString stringWithFormat:@"SELECT ABRecordID ,contactName, indentifier , phoneLabel , phoneNumber, usageCount FROM %@ ORDER BY usageCount DESC limit ?", MyFavoriteTableName]; 
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK){
        
        sqlite3_bind_int(statement, 1, MyFavoriteMaxLength);
        while (sqlite3_step(statement) == SQLITE_ROW) {
            contact = nil;
            contact = [[ABContact alloc] init];
            
            int aABRecordID = sqlite3_column_int(statement, 0);
            char *contactName = (char *)sqlite3_column_text(statement, 1);
            int indentifier = sqlite3_column_int(statement, 2);
            char *phoneLabel = (char *)sqlite3_column_text(statement, 3);
            char *phoneNumber = (char *)sqlite3_column_text(statement, 4);
            int usageCount = sqlite3_column_int(statement, 5);
            
            NSString *aContactName = nil;
            if (contactName) {
                aContactName = [[NSString alloc] initWithUTF8String:contactName];
            } else {
                aContactName = @"";
            }
            
            NSString *aPhoneLabel = nil;
			if (phoneLabel) {
				aPhoneLabel = [[NSString alloc] initWithUTF8String:phoneLabel];
			}
			else {
				aPhoneLabel = @"";
			}
            
            NSString *aPhoneNumber = nil;
            if (phoneNumber) {
                aPhoneNumber = [[NSString alloc] initWithUTF8String:phoneNumber];
            } else {
                aPhoneNumber = @"";
            }
            
            ClientObject *client = [[ClientObject alloc] init];
            client.cID = aABRecordID;
            client.cName = aContactName;
            client.cVal = aPhoneNumber;
            client.phoneLabel = aPhoneLabel;
            client.phoneIdentifier = indentifier;
            
//            NSLog(@"LoadMyFavoritesByDB firstName=%@, lastName=%@, usageCount=%d", aFirstName, aLastName, usageCount);
            
            [self.myFavorites addObject:client];
        }
        sqlite3_finalize (statement);
    }
    else {
        NSLog( @"Error:loadNewProductByDB error happened  %s", sqlite3_errmsg(database));
    }
}

- (int)getFavoriteRecordCount:(ClientObject *)client {
    if (!client) {
        return 0;
    }
    if (client.cID == -1) {
        return 0;
    }
    sqlite3 *database = [self getOrCreateTableIfNotExist];
    int usageCount = 0;
    NSString *query = [NSString stringWithFormat:@"SELECT ABRecordID , indentifier , usageCount FROM %@ where ABRecordID = ? AND indentifier = ? ORDER BY usageCount DESC", MyFavoriteTableName]; 
    NSLog(@"%@",query);
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK){
        
        sqlite3_bind_int(statement, 1, client.cID);
        sqlite3_bind_int(statement, 2, client.phoneIdentifier);
        if (sqlite3_step(statement) == SQLITE_ROW) {
//            int aABRecordID = sqlite3_column_int(statement, 0);
//            char *firstName = (char *)sqlite3_column_text(statement, 1);
//            char *lastName = (char *)sqlite3_column_text(statement, 2);
            usageCount=sqlite3_column_int(statement, 2);
//            NSString *aFirstName = nil;
//			if (firstName) {
//				aFirstName = [[NSString alloc] initWithUTF8String:firstName];
//			}
//			else {
//				aFirstName = @"";
//			}
//            
//            NSString *aLastName = nil;
//            if (lastName) {
//                aLastName = [[NSString alloc] initWithUTF8String:lastName];
//            } else {
//                aLastName = @"";
//            }
            
        }
        sqlite3_finalize (statement);
    }
    else {
        NSLog( @"Error:getNewProductByDB error happened  %s", sqlite3_errmsg(database));
    }
    return usageCount;
}

- (void)addFavoriteRecord:(ClientObject *)client {
    if (client.cID == -1) {
        return;
    }
    
    sqlite3 *database = [self getOrCreateTableIfNotExist];
    
    NSString *insertRow = [NSString stringWithFormat:@"INSERT  INTO  %@ (ABRecordID ,contactName, indentifier , phoneLabel , phoneNumber, usageCount) VALUES (?, ?, ?, ?, ?, ?)", MyFavoriteTableName];
    sqlite3_stmt *statementInsert;
    if(sqlite3_prepare_v2(database, [insertRow UTF8String], -1, &statementInsert, NULL) == SQLITE_OK) {
        
        sqlite3_bind_int(statementInsert, 1, client.cID);
        sqlite3_bind_text(statementInsert, 2, [client.cName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statementInsert, 3, client.phoneIdentifier);
        sqlite3_bind_text(statementInsert, 4, [client.phoneLabel UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statementInsert, 5, [client.cVal UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statementInsert, 6, 1);
    }
    
    if(sqlite3_step(statementInsert) == SQLITE_DONE){
        
        sqlite3_finalize(statementInsert);
        
    } else {
        NSLog(@" Error: addFavoriteRecord %s", sqlite3_errmsg(database));
        sqlite3_finalize(statementInsert);
        
    }
    sqlite3_close(database);
}

- (void)updateFavoriteRecord:(ClientObject *)client withCount:(int)count{
    if (client.cID == -1) {
        return;
    }
    sqlite3 *database = [self getOrCreateTableIfNotExist];
    
    NSString *updateRow = [NSString stringWithFormat:@"UPDATE %@ SET usageCount=? WHERE ABRecordID=? AND indentifier=?", MyFavoriteTableName];
    sqlite3_stmt *statementUpdate;
    if(sqlite3_prepare_v2(database, [updateRow UTF8String], -1, &statementUpdate, NULL) == SQLITE_OK) {
        
        sqlite3_bind_int(statementUpdate, 1, count);
        sqlite3_bind_int(statementUpdate, 2, client.cID);
        sqlite3_bind_int(statementUpdate, 3, client.phoneIdentifier);
    }
    
    if(sqlite3_step(statementUpdate) == SQLITE_DONE){
        
        sqlite3_finalize(statementUpdate);
        
    } else {
        NSLog(@" Error: updateFavoriteRecord %s", sqlite3_errmsg(database));
        sqlite3_finalize(statementUpdate);
        
    }
    sqlite3_close(database);
}

- (void)useContact:(ClientObject *)client {
    if (client.cID == -1) {
        return;
    }
    int count = [self getFavoriteRecordCount:client];
    if (count == 0) {
        [self addFavoriteRecord:client];
    } else {
        [self updateFavoriteRecord:client withCount:(count + 1)];
    }
}

@end
