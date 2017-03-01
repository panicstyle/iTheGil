//
//  NewData.m
//  iGongdong
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "NewData.h"
#import "env.h"
#import "LoginToService.h"
#import "Utils.h"

@interface NewData () {
	NSMutableData *m_receiveData;
	NSURLConnection *m_connection;
	BOOL m_isConn;
	BOOL m_isLogin;
	int m_nPage;
	LoginToService *m_login;
}
@end

@implementation NewData

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
	url = [NSString stringWithFormat:@"%@/2014/bbs/new.php?gr_id=&view=&mb_id=&page=%d", WWW_SERVER, m_nPage];
	
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
	
	[self getNormalItems:str];
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
		
		// subject
		NSString *strSubject = [Utils findStringRegex:str2 regex:@"(<td><a href).*?(</td>)"];
		strSubject = [Utils removeSpan:strSubject];
		strSubject = [Utils replaceStringHtmlTag:strSubject];
		[currItem setValue:strSubject forKey:@"subject"];
		
		// find boardId
		NSString *boardId = [Utils findStringRegex:str2 regex:@"(?<=bo_table=).*?(?=\\\")"];
		[currItem setValue:boardId forKey:@"boardId"];
		
		// find boardNo
		NSString *boardNo = [Utils findStringRegex:str2 regex:@"(?<=wr_id=).*?(?=\\\")"];
		[currItem setValue:boardNo forKey:@"boardNo"];
		
		[currItem setValue:@"0" forKey:@"isNew"];
		
		// name
		NSString *strName = [Utils findStringRegex:str2 regex:@"(<a href=\\\"http://thegil.org/2014/bbs/profile.php).*?(</a>)"];
		strName = [Utils replaceStringHtmlTag:strName];
		[currItem setValue:strName forKey:@"name"];
		
		// date
		NSString *strDate = [Utils findStringRegex:str2 regex:@"(?<=<td class=\\\"td_date\\\">).*?(?=</td>)"];
		[currItem setValue:strDate forKey:@"date"];
		
		// group
		NSString *strGroup = [Utils findStringRegex:str2 regex:@"(<td class=\\\"td_group).*?(</td>)"];
		strGroup = [Utils replaceStringHtmlTag:strGroup];
		[currItem setValue:strGroup forKey:@"group"];
		
		// board
		NSString *strBoard = [Utils findStringRegex:str2 regex:@"(<td class=\\\"td_board).*?(</td>)"];
		strBoard = [Utils replaceStringHtmlTag:strBoard];
		[currItem setValue:strBoard forKey:@"board"];
		
		[m_arrayItems addObject:currItem];
	}

	[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_OK] afterDelay:0];
}

@end
