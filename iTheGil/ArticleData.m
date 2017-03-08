//
//  ArticleData.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 13..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "ArticleData.h"
#import "Utils.h"
#import "env.h"
#import "LoginToService.h"

@interface ArticleData () {
	NSMutableData *m_receiveData;
	NSURLConnection *m_connection;
	BOOL m_isConn;
	BOOL m_isLogin;
	LoginToService *m_login;
}
@end

@implementation ArticleData

@synthesize m_strBoardId;
@synthesize m_strBoardNo;
@synthesize m_arrayItems;
@synthesize m_attachItems;
@synthesize target;
@synthesize selector;

@synthesize m_strHtml;
@synthesize m_strTitle;
@synthesize m_strName;
@synthesize m_strDate;
@synthesize m_strHit;
@synthesize m_strContent;
@synthesize m_strEditableContent;

- (void)fetchItems
{
	m_arrayItems = [[NSMutableArray alloc] init];
	
	m_isConn = TRUE;
	m_isLogin = FALSE;
	
	[self fetchItems2];
}

- (void)fetchItems2
{
	NSString *url;
 // http://thegil.org/2014/bbs/board.php?bo_table=B02&wr_id=279
	url = [NSString stringWithFormat:@"%@/2014/bbs/board.php?bo_table=%@&wr_id=%@", WWW_SERVER, m_strBoardId, m_strBoardNo];
	
	m_arrayItems = [[NSMutableArray alloc] init];
	
	m_receiveData = [[NSMutableData alloc] init];
	m_connection = [[NSURLConnection alloc]
					initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[m_receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([m_receiveData length] < 200) {
		if (m_isLogin == FALSE) {
			NSLog(@"retry login");
			// 저장된 로그인 정보를 이용하여 로그인
			m_login = [[LoginToService alloc] init];
			BOOL result = [m_login LoginToService];
			if (result) {
				m_isLogin = TRUE;
				[self fetchItems2];
			}
		} else {
			[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_LOGIN_FAIL] afterDelay:0];
			return;
		}
		[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_AUTH_FAIL] afterDelay:0];
		return;
	}
	
	m_strHtml = [[NSString alloc] initWithData:m_receiveData
									  encoding:NSUTF8StringEncoding];
	
	if ([Utils numberOfMatches:m_strHtml regex:@"글을 읽을 권한이 없습니다.    </p>"] > 0) {
		[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_AUTH_FAIL] afterDelay:0];
		return;
	}
	if ([Utils numberOfMatches:m_strHtml regex:@"글을 읽을 권한이 없습니다.<br><br>회원이시라면 로그인 후 이용해 보십시오.    </p>"] > 0) {
		if (m_isLogin == FALSE) {
			NSLog(@"retry login");
			// 저장된 로그인 정보를 이용하여 로그인
			m_login = [[LoginToService alloc] init];
			BOOL result = [m_login LoginToService];
			if (result) {
				m_isLogin = TRUE;
				[self fetchItems2];
			} else {
				[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_LOGIN_FAIL] afterDelay:0];
				return;
			}
		} else {
			[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_LOGIN_FAIL] afterDelay:0];
			return;
		}
	}

	[self parseNormal];
}
	
- (void)parseNormal
{
	m_strTitle = [Utils findStringRegex:m_strHtml regex:@"(?<=<h1 id=\\\"bo_v_title\\\">).*?(?=</h1>)"];
	m_strTitle = [Utils replaceStringHtmlTag:m_strTitle];

	m_strName = [Utils findStringRegex:m_strHtml regex:@"(?<=<span class=\\\"sv_member\\\">).*?(?=</span>)"];
	
	m_strDate = [Utils findStringRegex:m_strHtml regex:@"(?<=작성일</span><strong>).*?(?=</strong>)"];

	m_strHit = [Utils findStringRegex:m_strHtml regex:@"(?<=조회<strong>).*?(?=회</strong>)"];
	
	m_strContent = [Utils findStringRegex:m_strHtml regex:@"(<!-- 본문 내용 시작).*?(본문 내용 끝 -->)"];
	m_strContent = [m_strContent stringByReplacingOccurrencesOfString:@"<img " withString:@"<img onload=\"resizeImage2(this)\" "];
	
	NSString *strAttach = [Utils findStringRegex:m_strHtml regex:@"(<!-- 첨부파일 시작).*?(첨부파일 끝 -->)"];
	strAttach = [strAttach stringByReplacingOccurrencesOfString:@"<h2>첨부파일</h2>" withString:@""];
	
	NSString *strImage = [Utils findStringRegex:m_strHtml regex:@"(<div id=\\\"bo_v_img\\\">).*?(</div>)"];
	strImage = [strImage stringByReplacingOccurrencesOfString:@"<img " withString:@"<img onload=\"resizeImage2(this)\" "];
	
	m_attachItems = [self parseAttach:strAttach];
	
	NSString *strComment = [Utils findStringRegex:m_strHtml regex:@"(<!-- 댓글 시작).*?(댓글 끝 -->)"];
	
	NSArray *commentItems = [strComment componentsSeparatedByString:@"<article id="];
	
	NSMutableDictionary *currItem;
	
	int isReply = 0;
	for (int i = 1; i < [commentItems count]; i++) {
		NSString *s = [commentItems objectAtIndex:i];
		currItem = [[NSMutableDictionary alloc] init];
		
		if ([Utils numberOfMatches:s regex:@"icon_reply.gif"] > 0) {
			[currItem setValue:[NSNumber numberWithInt:1] forKey:@"isRe"];
			isReply = 1;
		} else {
			[currItem setValue:[NSNumber numberWithInt:0] forKey:@"isRe"];
			isReply = 0;
		}
		
		NSString *strNo = [Utils findStringRegex:s regex:@"(?<=span id=\\\"edit_).*?(?=\\\")"];
		[currItem setValue:strNo forKey:@"no"];
		
		// Name
		NSString *strName = [Utils findStringRegex:s regex:@"(?<=<span class=\\\"member\\\">).*?(?=</span>)"];
		[currItem setValue:strName forKey:@"name"];
		
		// Date
		NSString *strDate = [Utils findStringRegex:s regex:@"(<time datetime=).*?(</time>)"];
		strDate = [Utils replaceStringHtmlTag:strDate];
		[currItem setValue:strDate forKey:@"date"];
		
		// Comment
		NSString *strComm = [Utils findStringRegex:s regex:@"(<!-- 댓글 출력 -->).*?(<!-- 수정 -->)"];
		strComm = [Utils replaceStringHtmlTag:strComm];
		[currItem setValue:strComm forKey:@"comment"];
		
		[currItem setValue:[NSNumber numberWithFloat:80.0f] forKey:@"height"];
		
		[m_arrayItems addObject:currItem];
	}

	m_strEditableContent = [Utils replaceStringHtmlTag:m_strContent];
	
	NSString *resizeStr = @"<script>function resizeImage2(mm){var window_innerWidth = window.innerWidth - 30;var width = eval(mm.width);var height = eval(mm.height);if( width > window_innerWidth ){var p_height = window_innerWidth / width;var new_height = height * p_height;eval(mm.width = window_innerWidth);eval(mm.height = new_height);}}</script>";
	//        NSString *imageopenStr = [NSString stringWithString:@"<script>function image_open(src, mm){var src1 = 'image2.php?imgsrc='+src;window.open(src1,'image','width=1,height=1,scrollbars=yes,resizable=yes');}</script>"];
	
	m_strContent = [NSString stringWithFormat:@"%@%@%@%@", resizeStr, m_strContent, strAttach, strImage];

	[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_OK] afterDelay:0];
	return;
}

- (NSDictionary *)parseAttach:(NSString *)strAttach
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<li).*?(</li>)" options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionCaseInsensitive error:&error];
	NSArray *matches = [regex matchesInString:strAttach options:0 range:NSMakeRange(0, [strAttach length])];
	NSMutableDictionary *currItem = [[NSMutableDictionary alloc] init];
	for (NSTextCheckingResult *match in matches) {
		NSRange matchRange = [match range];
		NSString *str = [strAttach substringWithRange:matchRange];
		
		NSString *strKey = [Utils findStringRegex:str regex:@"(?<=href=\\\").*?(?=\\\")"];
		strKey = [strKey stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];

		NSString *strValue= [Utils findStringRegex:str regex:@"(?<=<strong>).*?(?=</strong>)"];
		strValue = [strValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		[currItem setValue:strValue forKey:strKey];
	}
	return currItem;
}


- (bool)DeleteArticle:(NSString *)strBoardId boardNo:(NSString *)strBoardNo
{
	NSString *url;
	url = [NSString stringWithFormat:@"%@/2014/bbs/delete.php?bo_table=%@&wr_id=%@&page=",
			   WWW_SERVER, strBoardId, strBoardNo];
	NSLog(@"url = [%@]", url);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	
	NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	NSString *str = [[NSString alloc] initWithData:respData
										  encoding:NSUTF8StringEncoding];
	//history.go(-1);
	NSLog(@"returnData = [%@]", str);
	
	if ([Utils numberOfMatches:str regex:@"history.back"] > 0) {
		NSString *errmsg;
		errmsg = [Utils findStringRegex:str regex:@"(<p class=\\\"cbg\\\">).*?(</p>)"];
		errmsg = [Utils replaceStringHtmlTag:errmsg];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"글 삭제 오류"
														message:errmsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
		[alert show];
		return false;
	} else {
		NSLog(@"delete article success");
		return true;
	}
}

- (bool)DeleteComment:(NSString *)strBoardId boardNo:(NSString *)strBoardNo commentNo:(NSString *)strCommentNo
{
	NSLog(@"DeleteArticleConfirm start");
	NSLog(@"boardId=[%@], boardNo=[%@], commentID=[%@]", strBoardId, strBoardNo, strCommentNo);
	
	NSString *url = [NSString stringWithFormat:@"%@/2014/bbs/delete_comment.php?bo_table=%@&comment_id=%@&token=&page= ",
					 WWW_SERVER, strBoardId, strCommentNo];
	NSLog(@"url = [%@]", url);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	
	NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	NSString *str = [[NSString alloc] initWithData:respData
										  encoding:NSUTF8StringEncoding];
	//history.go(-1);
	NSLog(@"returnData = [%@]", str);
	
	if ([Utils numberOfMatches:str regex:@"history.back"] > 0) {
		NSString *errmsg;
		errmsg = [Utils findStringRegex:str regex:@"(<p class=\\\"cbg\\\">).*?(</p>)"];
		errmsg = [Utils replaceStringHtmlTag:errmsg];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"댓글 삭제 오류"
														message:errmsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
		[alert show];
		return false;
	} else {
		NSLog(@"delete article success");
		return true;
	}
}

@end
