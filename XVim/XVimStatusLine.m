//
//  XVimStatusLine.m
//  XVim
//
//  Created by Shuichiro Suzuki on 4/26/12.
//  Copyright (c) 2012 JugglerShu.Net. All rights reserved.
//

#import "XVimStatusLine.h"
#import "DVTChooserView.h"
#import "IDESourceCodeEditor.h"
#import "Logger.h"
#import <objc/runtime.h>

#define STATUS_LINE_HEIGHT 18 

@implementation XVimStatusLine{
    DVTChooserView* _background;
    NSTextView* _status;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _background = [[NSClassFromString(@"DVTChooserView") performSelector:@selector(alloc)] init];
        _background.gradientStyle = 2;  // Style number 2 looks like IDEGlassBarView   
        [_background setBorderSides:12]; // See DVTBorderedView.h for the meaning of the number
        _status = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 0, STATUS_LINE_HEIGHT)];
        _status.backgroundColor = [NSColor clearColor];
        [_status setEditable:NO];
        
        [self addSubview:_background];
        [self addSubview:_status];
    }
    
    return self;
}

- (void)dealloc
{
    [_background release];
    [_status release];
    [super dealloc];
}

- (void)layoutStatus:(NSView*)container{
    NSRect parent = [container frame];
    [self setFrame:NSMakeRect(0, 0, parent.size.width, STATUS_LINE_HEIGHT)];
    [_background setFrame:NSMakeRect(0, 0, parent.size.width, STATUS_LINE_HEIGHT)];
    [_status setFrame:NSMakeRect(0, -2, parent.size.width, STATUS_LINE_HEIGHT)];
    // This is heuristic way...
    if( [NSStringFromClass([container class]) isEqualToString:@"IDEComparisonEditorAutoLayoutView"] ){
        // Nothing ( Maybe AutoLayout view does the job "automatically")
    }else{
        if( [container subviews].count > 0 ){
            [[[container subviews] objectAtIndex:0] setFrame:NSMakeRect(0, STATUS_LINE_HEIGHT, parent.size.width, parent.size.height-STATUS_LINE_HEIGHT)];
        }
    }
}
    
- (void)didContainerFrameChanged:(NSNotification*)notification{
    // TODO: Find the way to get scrollView from IDESourceCodeEditor class.
    // Now it is assumed that container view has the scrollView at index 0 of subviews.
    NSView* container = [notification object];
    [self layoutStatus:container];
     
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if( [keyPath isEqualToString:@"document"] ){
        [_status setString:[[[object document] fileURL] path]];
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
