/*
 *  pinyin.h
 *  Chinese Pinyin First Letter
 *
 *  Created by George on 4/21/10.
 *  Copyright 2010 RED/SAFI. All rights reserved.
 *
 */

#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"

#define ENHANCEALPHA @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ#"

char pinyinFirstLetter(unsigned short hanzi);
int checkIsEnglishLetter(unsigned short hanzi);