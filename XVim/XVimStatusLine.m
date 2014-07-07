//
//  XVimStatusLine.m
//  XVim
//
//  Created by Shuichiro Suzuki on 4/26/12.
//  Copyright (c) 2012 JugglerShu.Net. All rights reserved.
//

#import "XVimStatusLine.h"
#import "DVTKit.h"
#import "IDEKit.h"
#import "Logger.h"
#import "NSInsetTextView.h"
#import <objc/runtime.h>
#import "XVim.h"
#import "XVimOptions.h"

#define STATUS_LINE_HEIGHT 18 

@interface XVimStatusLine ()

- (void)_documentChangedNotification:(NSNotification *)notification;

@end

@implementation XVimStatusLine{
    NSInsetTextView* _status;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _status = [[NSInsetTextView alloc] initWithFrame:NSMakeRect(0, 0, 0, STATUS_LINE_HEIGHT)];
        _status.backgroundColor = [NSColor colorWithWhite:0.5 alpha:1.0];
        [_status setEditable:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_documentChangedNotification:) name:XVimDocumentChangedNotification object:nil];
        
        [self addSubview:_status];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_status release];
    [super dealloc];
}

- (void)layoutStatus:(NSView*)container
{
    DVTFontAndColorTheme* theme = [NSClassFromString(@"DVTFontAndColorTheme") performSelector:@selector(currentTheme)];
	NSFont *sourceFont = [theme sourcePlainTextFont];
	
	// Calculate inset
	CGFloat horizontalInset = 0;
	CGFloat verticalInset = MAX((STATUS_LINE_HEIGHT - [sourceFont pointSize]) / 2 - 1.0, 0);
	CGSize inset = CGSizeMake(horizontalInset, verticalInset);
	
    XVimOptions* options = [[XVim instance] options];
    CGFloat height;
    if( options.laststatus == 2 ){
        height = STATUS_LINE_HEIGHT;
    } else {
        height = 0;
    }
    NSRect parentRect = [container frame];
    [self setFrame:NSMakeRect(0, 0, parentRect.size.width, height)];
    [_status setFrame:NSMakeRect(0, 0, parentRect.size.width, STATUS_LINE_HEIGHT)];
	[_status setFont:sourceFont];
	[_status setInset:inset];
    // This is heuristic way...
    if( [NSStringFromClass([container class]) isEqualToString:@"IDEComparisonEditorAutoLayoutView"] ){
        // Nothing ( Maybe AutoLayout view does the job "automatically")
    }else{
        if( [container subviews].count > 0 ){
            [[[container subviews] objectAtIndex:0] setFrame:NSMakeRect(0, height, parentRect.size.width, parentRect.size.height-height)];
        }
    }
}
    
- (void)didContainerFrameChanged:(NSNotification*)notification{
    // TODO: Find the way to get scrollView from IDESourceCodeEditor class.
    // Now it is assumed that container view has the scrollView at index 0 of subviews.
    NSView* container = [notification object];
    [self layoutStatus:container];
     
}

- (void)_documentChangedNotification:(NSNotification *)notification
{
    NSString *documentPath = [[notification userInfo] objectForKey:XVimDocumentPathKey];
    if (documentPath != nil) {
        DVTFontAndColorTheme* theme = [NSClassFromString(@"DVTFontAndColorTheme") performSelector:@selector(currentTheme)];
        [_status.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:documentPath
                                                           attributes:@{
            NSForegroundColorAttributeName: [NSColor colorWithWhite:0.9 alpha:1],
            NSFontAttributeName: [theme sourcePlainTextFont]
        }]];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    
}

static char s_associate_key = 0;

+ (XVimStatusLine*)associateOf:(id)object
{
	return (XVimStatusLine*)objc_getAssociatedObject(object, &s_associate_key);
}

- (void)associateWith:(id)object
{
	objc_setAssociatedObject(object, &s_associate_key, self, OBJC_ASSOCIATION_RETAIN);
}

@end
