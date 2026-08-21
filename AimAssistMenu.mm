#import "AimAssistMenu.h"
#import "AimAssistOverlay.h"
#import "AimAssistSettings.h"
#import "MCMenuItemNodeRGBAStatic.h"
#import "MCAdjustableLabelTTF.h"
#import "CCDirector.h"
#import "CCLayerColor.h"

static AimAssistOverlay *_sharedOverlay = nil;

@implementation AimAssistMenu {
    CCMenuItem *_toggleItem;
    CCMenuItem *_widthItem;
    CCMenuItem *_colorItem;
    CCMenuItem *_opacityItem;
    CCMenuItem *_closeItem;
    CCLayerColor *_bgLayer;
}

+ (void)setOverlay:(AimAssistOverlay *)overlay {
    _sharedOverlay = overlay;
}

+ (instancetype)showMenu {
    return [[[self alloc] init] autorelease];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        _bgLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200) width:300 height:280];
        _bgLayer.position = ccp(winSize.width/2 - 150, winSize.height/2 - 140);
        [self addChild:_bgLayer];
        
        MCAdjustableLabelTTF *title = [MCAdjustableLabelTTF labelWithString:@"AIM ASSIST" 
                                                                  dimensions:CGSizeMake(280, 40) 
                                                                   alignment:CCTextAlignmentCenter 
                                                                   fontName:@"Helvetica-Bold" 
                                                                   fontSize:22];
        title.position = ccp(winSize.width/2, winSize.height/2 + 110);
        title.color = ccc3(255, 215, 0);
        [self addChild:title];
        
        _toggleItem = [CCMenuItemFont itemWithString:[self toggleStatus] target:self selector:@selector(toggleESP:)];
        _widthItem = [CCMenuItemFont itemWithString:[self widthStatus] target:self selector:@selector(changeWidth:)];
        _colorItem = [CCMenuItemFont itemWithString:[self colorStatus] target:self selector:@selector(toggleColor:)];
        _opacityItem = [CCMenuItemFont itemWithString:[self opacityStatus] target:self selector:@selector(changeOpacity:)];
        _closeItem = [CCMenuItemFont itemWithString:@"Close" target:self selector:@selector(close:)];
        
        CCMenu *menu = [CCMenu menuWithItems:_toggleItem, _widthItem, _colorItem, _opacityItem, _closeItem, nil];
        [menu alignItemsVerticallyWithPadding:12];
        menu.position = ccp(winSize.width/2, winSize.height/2 - 30);
        [self addChild:menu];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:@"AimAssistSettingsChanged" object:nil];
    }
    return self;
}

- (NSString *)toggleStatus {
    return [AimAssistSettings sharedSettings].enabled ? @"ESP: ON" : @"ESP: OFF";
}

- (NSString *)widthStatus {
    return [NSString stringWithFormat:@"Width: %.0f", [AimAssistSettings sharedSettings].lineWidth];
}

- (NSString *)colorStatus {
    return [AimAssistSettings sharedSettings].useBallColors ? @"Color: Auto" : @"Color: Fixed";
}

- (NSString *)opacityStatus {
    return [NSString stringWithFormat:@"Opacity: %.0f%%", [AimAssistSettings sharedSettings].opacity * 100];
}

- (void)toggleESP:(id)sender {
    AimAssistSettings *settings = [AimAssistSettings sharedSettings];
    settings.enabled = !settings.enabled;
    [settings synchronize];
    [_toggleItem setString:[self toggleStatus]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AimAssistSettingsChanged" object:nil];
}

- (void)changeWidth:(id)sender {
    AimAssistSettings *settings = [AimAssistSettings sharedSettings];
    float widths[] = {1.0, 2.0, 3.0, 5.0};
    int idx = 0;
    for (int i = 0; i < 4; i++) {
        if (settings.lineWidth == widths[i]) idx = (i + 1) % 4;
    }
    settings.lineWidth = widths[idx];
    [settings synchronize];
    [_widthItem setString:[self widthStatus]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AimAssistSettingsChanged" object:nil];
}

- (void)toggleColor:(id)sender {
    AimAssistSettings *settings = [AimAssistSettings sharedSettings];
    settings.useBallColors = !settings.useBallColors;
    [settings synchronize];
    [_colorItem setString:[self colorStatus]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AimAssistSettingsChanged" object:nil];
}

- (void)changeOpacity:(id)sender {
    AimAssistSettings *settings = [AimAssistSettings sharedSettings];
    float opacities[] = {0.3, 0.6, 1.0};
    int idx = 0;
    for (int i = 0; i < 3; i++) {
        if (settings.opacity == opacities[i]) idx = (i + 1) % 3;
    }
    settings.opacity = opacities[idx];
    [settings synchronize];
    [_opacityItem setString:[self opacityStatus]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AimAssistSettingsChanged" object:nil];
}

- (void)close:(id)sender {
    [self removeFromParentAndCleanup:YES];
}

- (void)settingsChanged:(NSNotification *)note {
    [_toggleItem setString:[self toggleStatus]];
    [_widthItem setString:[self widthStatus]];
    [_colorItem setString:[self colorStatus]];
    [_opacityItem setString:[self opacityStatus]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
