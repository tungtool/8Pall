#import "AimAssistOverlay.h"
#import "CCDirector.h"
#import "CCRenderTexture.h"
#import "CCSprite.h"
#import "ccTypes.h"
#import "AimAssistSettings.h"

@implementation AimAssistOverlay {
    CCRenderTexture *_renderTexture;
    CCSprite *_sprite;
    NSArray<PocketInfo *> *_pockets;
    NSArray<BallInfo *> *_balls;
    BOOL _dirty;
    CGSize _winSize;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dirty = YES;
        _winSize = [[CCDirector sharedDirector] winSize];
        _renderTexture = [CCRenderTexture renderTextureWithWidth:_winSize.width height:_winSize.height];
        _renderTexture.anchorPoint = ccp(0, 0);
        _renderTexture.position = ccp(0, 0);
        [self addChild:_renderTexture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:@"AimAssistSettingsChanged" object:nil];
    }
    return self;
}

- (void)settingsChanged:(NSNotification *)note {
    _dirty = YES;
    [self refresh];
}

- (void)markDirty {
    _dirty = YES;
}

- (void)updateWithBalls:(NSArray<BallInfo *> *)balls pockets:(NSArray<PocketInfo *> *)pockets {
    _balls = balls;
    _pockets = pockets;
    _dirty = YES;
}

- (void)refresh {
    if (!_dirty) return;
    [self renderOverlay];
    _dirty = NO;
}

- (void)renderOverlay {
    AimAssistSettings *settings = [AimAssistSettings sharedSettings];
    if (!settings.enabled || !_pockets || !_balls || !self.currentTable) {
        [_renderTexture beginWithClear:0 g:0 b:0 a:0];
        [_renderTexture end];
        return;
    }

    [_renderTexture beginWithClear:0 g:0 b:0 a:0];
    
    CCDirector *director = [CCDirector sharedDirector];
    CCNode *tableNode = (CCNode *)self.currentTable;
    
    BallInfo cueBall = {0};
    NSMutableArray *activeBalls = [NSMutableArray array];
    for (BallInfo ball in _balls) {
        if (!ball.isPocketed) {
            if (ball.number == 0) cueBall = ball;
            else [activeBalls addObject:[NSValue valueWithBytes:&ball objCType:@encode(BallInfo)]];
        }
    }
    
    if (cueBall.number != 0 || activeBalls.count == 0) {
        [_renderTexture end];
        return;
    }

    CGPoint worldCue = [tableNode convertToWorldSpace:cueBall.position];
    CGPoint uiCue = [director convertToUI:worldCue];

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glLineWidth(settings.lineWidth);

    for (NSValue *val in activeBalls) {
        BallInfo ball;
        [val getValue:&ball];
        
        CGPoint worldBall = [tableNode convertToWorldSpace:ball.position];
        CGPoint uiBall = [director convertToUI:worldBall];

        ccColor4F color;
        if (settings.useBallColors) {
            color = colorForBallNumber(ball.number);
        } else {
            color = (ccColor4F){1.0, 1.0, 0.0, 1.0};
        }
        color.a = settings.opacity;

        ccDrawColor4F(color.r, color.g, color.b, color.a);
        ccDrawLine(uiCue, uiBall);
    }

    [_renderTexture end];
}

- (void)visit {
    [super visit];
    if (_dirty) {
        [self renderOverlay];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
