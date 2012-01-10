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
        
    NSString *createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (Id INTEGER PRIMARY KEY AUTOINCREMENT, ABRecordID INTEGER,firstName TEXT, lastName TEXT,usageCount INTEGER)", MyFavoriteTableName];
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
    
    NSString *query = [NSString stringWithFormat:@"SELECT ABRecordID ,firstName , lastName ,usageCount FROM %@ ORDER BY usageCount DESC limit ?", MyFavoriteTableName]; 
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK){
        
        sqlite3_bind_int(statement, 1, MyFavoriteMaxLength);
        while (sqlite3_step(statement) == SQLITE_ROW) {
            contact = nil;
            contact = [[ABContact alloc] init];
            
            int aABRecordID = sqlite3_column_int(statement, 0);
            char *firstName = (char *)sqlite3_column_text(statement, 1);
            char *lastName = (char *)sqlite3_column_text(statement, 2);
            int usageCount=sqlite3_column_int(statement, 3);
            
            NSString *aFirstName = nil;
			if (firstName) {
				aFirstName = [[NSString alloc] initWithUTF8String:firstName];
			}
			else {
				aFirstName = @"";
			}
            
            NSString *aLastName = nil;
            if (lastName) {
                aLastName = [[NSString alloc] initWithUTF8String:lastName];
            } else {
                aLastName = @"";
            }
            
            contact = [ABContact contactWithRecordID:aABRecordID];
            
            [self.myFavorites addObject:contact];
        }
        sqlite3_finalize (statement);
    }
    else {
        NSLog( @"Error:loadNewProductByDB error happened  %s", sqlite3_errmsg(database));
    }
}

- (int)getFavoriteRecordCount:(ABContact *)contact {
    if (!contact) {
        return 0;
    }
    sqlite3 *database = [self getOrCreateTableIfNotExist];
    int usageCount = 0;
    NSString *query = [NSString stringWithFormat:@"SELECT ABRecordID ,firstName , lastName ,usageCount FROM %@ where ABRecordID=?", MyFavoriteTableName]; 
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK){
        
        sqlite3_bind_int(statement, 1, contact.recordID);
        if (sqlite3_step(statement) == SQLITE_ROW) {
//            int aABRecordID = sqlite3_column_int(statement, 0);
            char *firstName = (char *)sqlite3_column_text(statement, 1);
            char *lastName = (char *)sqlite3_column_text(statement, 2);
            usageCount=sqlite3_column_int(statement, 3);
            
            NSString *aFirstName = nil;
			if (firstName) {
				aFirstName = [[NSString alloc] initWithUTF8String:firstName];
			}
			else {
				aFirstName = @"";
			}
            
            NSString *aLastName = nil;
            if (lastName) {
                aLastName = [[NSString alloc] initWithUTF8String:lastName];
            } else {
                aLastName = @"";
            }
            
            
        }
        sqlite3_finalize (statement);
    }
    else {
        NSLog( @"Error:getNewProductByDB error happened  %s", sqlite3_errmsg(database));
    }
    return usageCount;
}

- (void)addFavoriteRecord:(ABContact *)contact {
    
    sqlite3 *database = [self getOrCreateTableIfNotExist];
    
    NSString *insertRow = [NSString stringWithFormat:@"INSERT  INTO  %@ (ABRecordID ,firstName, lastName , usageCount) VALUES (?, ?, ?, ?)", MyFavoriteTableName];
    sqlite3_stmt *statementInsert;
    if(sqlite3_prepare_v2(database, [insertRow UTF8String], -1, &statementInsert, NULL) == SQLITE_OK) {
        
        sqlite3_bind_int(statementInsert, 1, contact.recordID);
        sqlite3_bind_text(statementInsert, 2, [contact.firstname UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statementInsert, 3, [contact.lastname UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statementInsert, 4, 1);
    }
    
    if(sqlite3_step(statementInsert) == SQLITE_DONE){
        
        sqlite3_finalize(statementInsert);
        
    } else {
        NSLog(@" Error: addFavoriteRecord %s", sqlite3_errmsg(database));
        sqlite3_finalize(statementInsert);
        
    }
    sqlite3_close(database);
}

- (void)updateFavoriteRecord:(ABContact *)contact withCount:(int)count{
    
    sqlite3 *database = [self getOrCreateTableIfNotExist];
    
    NSString *updateRow = [NSString stringWithFormat:@"UPDATE %@ SET usageCount=? WHERE ABRecordID=?", MyFavoriteTableName];
    sqlite3_stmt *statementUpdate;
    if(sqlite3_prepare_v2(database, [updateRow UTF8String], -1, &statementUpdate, NULL) == SQLITE_OK) {
        
        sqlite3_bind_int(statementUpdate, 1, count);
        sqlite3_bind_int(statementUpdate, 2, contact.recordID);
    }
    
    if(sqlite3_step(statementUpdate) == SQLITE_DONE){
        
        sqlite3_finalize(statementUpdate);
        
    } else {
        NSLog(@" Error: updateFavoriteRecord %s", sqlite3_errmsg(database));
        sqlite3_finalize(statementUpdate);
        
    }
    sqlite3_close(database);
}

- (void)useContact:(ABContact *)contact {
    int count = [self getFavoriteRecordCount:contact];
    if (count == 0) {
        [self addFavoriteRecord:contact];
    } else {
        [self updateFavoriteRecord:contact withCount:(count+1)];
    }
}

@end
