#import <substrate.h>
#import <objc/runtime.h>
#import "Common.h"
#import "AimAssistOverlay.h"
#import "AimAssistMenu.h"
#import "AimAssistSettings.h"

static AimAssistOverlay *overlay = nil;
static CCScene *currentScene = nil;
static BOOL isMenuVisible = NO;

// Helper để lấy BallManager
static id getBallManager() {
    Class cls = NSClassFromString(@"BallManager");
    // Thử sharedInstance
    id instance = [cls performSelector:@selector(sharedManager)];
    if (instance) return instance;
    // Thử shared
    instance = [cls performSelector:@selector(shared)];
    if (instance) return instance;
    // Nếu không, tìm trong scene
    for (CCNode *child in [currentScene children]) {
        if ([child isKindOfClass:cls]) return child;
    }
    return nil;
}

// Helper để lấy TableProperties từ Table
static id<TableProperties> getTableProperties(Table *table) {
    if ([table respondsToSelector:@selector(properties)]) {
        return [table performSelector:@selector(properties)];
    }
    if ([table respondsToSelector:@selector(ballProperties)]) {
        return [table performSelector:@selector(ballProperties)];
    }
    // Thử lấy ivar
    Ivar ivar = class_getInstanceVariable([table class], "_properties");
    if (ivar) {
        return object_getIvar(table, ivar);
    }
    ivar = class_getInstanceVariable([table class], "_ballProperties");
    if (ivar) {
        return object_getIvar(table, ivar);
    }
    return nil;
}

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
    
    id<TableProperties> props = getTableProperties(self);
    if (!props) return;
    
    // Lấy pockets
    NSArray *pocketPoints = [props getPockets];
    NSMutableArray *pockets = [NSMutableArray array];
    for (NSValue *val in pocketPoints) {
        CGPoint pos = [val CGPointValue];
        id radiusObj = [props getPocketRadius];
        float radius = [radiusObj floatValue];
        PocketInfo info = {pos, radius};
        [pockets addObject:[NSValue valueWithBytes:&info objCType:@encode(PocketInfo)]];
    }
    
    id ballManager = getBallManager();
    if (!ballManager) return;
    
    NSArray *balls = [ballManager getBalls];
    NSMutableArray *ballInfos = [NSMutableArray array];
    for (Ball *b in balls) {
        int state = [b state];
        BOOL onTable = [b onTable];
        BOOL isPocketed = (state == 2 || !onTable);
        BallInfo info = {[b position], [b radius], [b number], [b classification], isPocketed};
        [ballInfos addObject:[NSValue valueWithBytes:&info objCType:@encode(BallInfo)]];
    }
    
    [overlay updateWithBalls:ballInfos pockets:pockets];
    [overlay markDirty];
    [overlay refresh];
}

%end

// Các hook khác giữ nguyên...
