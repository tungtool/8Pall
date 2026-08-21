#import <substrate.h>
#import "Common.h"
#import "AimAssistOverlay.h"
#import "AimAssistMenu.h"
#import "AimAssistSettings.h"

static AimAssistOverlay *overlay = nil;
static CCScene *currentScene = nil;
static BOOL isMenuVisible = NO;

%hook Table

- (void)onEnter {
    %orig;
    if (!overlay) {
        overlay = [[AimAssistOverlay alloc] init];
        overlay.currentTable = self;
        currentScene = (CCScene *)[self parent];
        [currentScene addChild:overlay z:999];
        [AimAssistMenu setOverlay:overlay];
    }
    [self updateAimAssistData];
}

- (void)updateAimAssistData {
    if (!overlay) return;
    
    id<TableProperties> props = [self properties];
    if (!props) return;
    
    NSArray *pocketPoints = [props getPockets];
    NSMutableArray *pockets = [NSMutableArray array];
    for (NSValue *val in pocketPoints) {
        CGPoint pos = [val CGPointValue];
        PocketInfo info = {pos, [props getPocketRadius]};
        [pockets addObject:[NSValue valueWithBytes:&info objCType:@encode(PocketInfo)]];
    }
    
    NSArray *balls = [[BallManager sharedManager] getBalls];
    NSMutableArray *ballInfos = [NSMutableArray array];
    for (Ball *b in balls) {
        BOOL isPocketed = [b state] == 2 || ![b onTable];
        BallInfo info = {[b position], [b radius], [b number], [b classification], isPocketed};
        [ballInfos addObject:[NSValue valueWithBytes:&info objCType:@encode(BallInfo)]];
    }
    
    [overlay updateWithBalls:ballInfos pockets:pockets];
    [overlay markDirty];
    [overlay refresh];
}

%end

%hook Ball

- (void)setPosition:(CGPoint)pos {
    %orig;
    if (overlay) [overlay markDirty];
}

- (void)setState:(int)state {
    %orig;
    if (overlay) [overlay markDirty];
}

%end

%hook CCTouchDispatcher

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    %orig;
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2) {
        if (!currentScene) return;
        CCNode *existingMenu = [currentScene getChildByTag:888];
        if (existingMenu) {
            [existingMenu removeFromParentAndCleanup:YES];
            isMenuVisible = NO;
        } else {
            AimAssistMenu *menu = [AimAssistMenu showMenu];
            menu.tag = 888;
            [currentScene addChild:menu z:1000];
            isMenuVisible = YES;
        }
    }
}

%end

%hook CCDirector

- (void)setRunningScene:(CCScene *)scene {
    %orig;
    currentScene = scene;
    if (overlay && scene) {
        [scene addChild:overlay z:999];
    }
}

%end

%ctor {
    NSLog(@"AimAssist: Tweak loaded.");
}
