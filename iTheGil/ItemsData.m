//
//  ItemsData.m
//  iGongdong
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "ItemsData.h"
#import "env.h"
#import "LoginToService.h"
#import "Utils.h"

@interface ItemsData () {
	NSMutableData *m_receiveData;
	NSURLConnection *m_connection;
	BOOL m_isConn;
	BOOL m_isLogin;
	int m_nPage;
	LoginToService *m_login;
}
@end

@implementation ItemsData

@synthesize m_strBoardId;
@synthesize m_arrayItems;
@synthesize m_nMode;
@synthesize m_nItemMode;
@synthesize target;
@synthesize selector;

- (void)fetchItems:(int) nPage
{
	m_arrayItems = [[NSMutableArray alloc] init];
	m_isLogin = FALSE;
	m_nPage = nPage;

	[self fetchItems2];
}

- (void)fetchItems2
{
	NSString *url;
	url = [NSString stringWithFormat:@"%@/2014/bbs/board.php?bo_table=%@&page=%d", WWW_SERVER, m_strBoardId, m_nPage];
	
	m_receiveData = [[NSMutableData alloc] init];
	m_connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[m_receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *str = [[NSString alloc] initWithData:m_receiveData
										  encoding:NSUTF8StringEncoding];
	
	NSLog(@"html = %@", str);
	if ([Utils numberOfMatches:str regex:@"<ul id=\\\"gall_ul\\\">"] > 0) {
		// 갤러리 모드
		m_nItemMode = [NSNumber numberWithInt:PictureItems];
		[self getPictureItems:str];
	} else {
		// 일반 모드
		m_nItemMode = [NSNumber numberWithInt:NormalItems];
		[self getNormalItems:str];
	}

}

- (void)getNormalItems:(NSString *)str
{
	NSString *tbody = [Utils findStringWith:str from:@"<tbody>" to:@"</tbody>"];
	
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<tr).*?(</tr>)" options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionCaseInsensitive error:&error];
	NSArray *matches = [regex matchesInString:tbody options:0 range:NSMakeRange(0, [tbody length])];
	NSMutableDictionary *currItem;
	for (NSTextCheckingResult *match in matches) {
		NSRange matchRange = [match range];
		NSString *str2 = [tbody substringWithRange:matchRange];
		currItem = [[NSMutableDictionary alloc] init];
		
		// isNew
		if ([Utils numberOfMatches:str2 regex:@"icon_reply.gif"]) {
			[currItem setValue:@"1" forKey:@"isRe"];
		} else {
			[currItem setValue:@"0" forKey:@"isRe"];
		}
		
		// find [공지]
		if ([Utils numberOfMatches:str2 regex:@"class=\\\"bo_notice\\\""] > 0) {
			[currItem setValue:[NSNumber numberWithInt:1] forKey:@"isNotice"];
		} else {
			[currItem setValue:[NSNumber numberWithInt:0] forKey:@"isNotice"];
		}
		
		// subject
		NSString *strSubject = [Utils findStringRegex:str2 regex:@"(<a href=).*?(</a>)"];
		strSubject = [Utils removeSpan:strSubject];
		strSubject = [Utils replaceStringHtmlTag:strSubject];
		[currItem setValue:strSubject forKey:@"subject"];
		
		// find boardNo
		NSString *boardNo = [Utils findStringRegex:str2 regex:@"(?<=wr_id=).*?(?=&amp)"];
		[currItem setValue:boardNo forKey:@"boardNo"];
		
		NSString *strComment = [Utils findStringRegex:str2 regex:@"(?<=<span class=\\\"cnt_cmt\\\">).*?(?=</span>)"];
		[currItem setValue:strComment forKey:@"comment"];
		
		// isNew
		if ([Utils numberOfMatches:str2 regex:@"icon_new.gif"]) {
			[currItem setValue:@"1" forKey:@"isNew"];
		} else {
			[currItem setValue:@"0" forKey:@"isNew"];
		}
		
		// name
		NSString *strName = [Utils findStringRegex:str2 regex:@"(<td class=\\\"td_name sv_use\\\">).*?(</td>)"];
		strName = [Utils replaceStringHtmlTag:strName];
		[currItem setValue:strName forKey:@"name"];
		
		// date
		NSString *strDate = [Utils findStringRegex:str2 regex:@"(?<=<td class=\\\"td_date\\\">).*?(?=</td>)"];
		[currItem setValue:strDate forKey:@"date"];
		
		// Hit
		NSString *strHit = [Utils findStringRegex:str2 regex:@"(?<=<td class=\\\"td_num\\\">).*?(?=</td>)" index:1];
		[currItem setValue:strHit forKey:@"hit"];
		
		[m_arrayItems addObject:currItem];
	}

	[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_OK] afterDelay:0];
}

- (void)getPictureItems:(NSString *)str
{
	NSString *tbody = [Utils findStringWith:str from:@"<form name=\"fboardlist" to:@"</form>"];

	NSArray *arrayItems = [tbody componentsSeparatedByString:@"<li class=\"gall_li"];
	
	NSMutableDictionary *currItem;
	
	for (int i = 1; i < [arrayItems count]; i++) {
		NSString *str2 = [arrayItems objectAtIndex:i];
		currItem = [[NSMutableDictionary alloc] init];
		
		[currItem setValue:[NSNumber numberWithInt:0] forKey:@"isNotice"];
		[currItem setValue:[NSNumber numberWithInt:0] forKey:@"isRe"];
		
		// subject
		NSString *strSubject = [Utils findStringRegex:str2 regex:@"(<li class=\\\"gall_text_href).*?(</li>)"];
		strSubject = [Utils removeSpan:strSubject];
		strSubject = [Utils replaceStringHtmlTag:strSubject];
		[currItem setValue:strSubject forKey:@"subject"];
		
		// boardNo
		NSString *boardNo = [Utils findStringRegex:str2 regex:@"(?<=wr_id=).*?(?=&amp)"];
		[currItem setValue:boardNo forKey:@"boardNo"];
		
		// 댓글 갯수
		NSString *strComment = [Utils findStringRegex:str2 regex:@"(?<=<span class=\\\"cnt_cmt\\\">).*?(?=</span>)"];
		[currItem setValue:strComment forKey:@"comment"];
		
		// name
		NSString *strName = [Utils findStringRegex:str2 regex:@"(<span class=\\\"sv_member).*?(<li>)"];
		strName = [Utils replaceStringHtmlTag:strName];
		[currItem setValue:strName forKey:@"name"];
		
		// date
		NSString *strDate = [Utils findStringRegex:str2 regex:@"(?<=작성일 </span>).*?(?=</li>)"];
		[currItem setValue:strDate forKey:@"date"];
		
		// Hit
		NSString *strHit = [Utils findStringRegex:str2 regex:@"(?<=조회 </span>).*?(?=</li>)"];
		[currItem setValue:strHit forKey:@"hit"];
		
		// piclink
		NSString *strPicLink = [Utils findStringRegex:str2 regex:@"(?<=<img src=\\\").*?(?=\\\")"];
		[currItem setValue:strPicLink forKey:@"piclink"];
		
		// isNew
		[currItem setValue:[NSNumber numberWithInt:0] forKey:@"isNew"];
		
		[m_arrayItems addObject:currItem];
	}
	
	[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_OK] afterDelay:0];
}

@end
