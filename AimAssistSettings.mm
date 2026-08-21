#import "AimAssistSettings.h"

@implementation AimAssistSettings

+ (instancetype)sharedSettings {
    static AimAssistSettings *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _enabled = [defaults boolForKey:@"AimAssistEnabled"];
        _lineWidth = [defaults floatForKey:@"AimAssistLineWidth"];
        if (_lineWidth == 0) _lineWidth = 2.0f;
        _useBallColors = [defaults boolForKey:@"AimAssistUseBallColors"];
        if (![defaults objectForKey:@"AimAssistUseBallColors"]) _useBallColors = YES;
        _opacity = [defaults floatForKey:@"AimAssistOpacity"];
        if (_opacity == 0) _opacity = 1.0f;
    }
    return self;
}

- (void)synchronize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_enabled forKey:@"AimAssistEnabled"];
    [defaults setFloat:_lineWidth forKey:@"AimAssistLineWidth"];
    [defaults setBool:_useBallColors forKey:@"AimAssistUseBallColors"];
    [defaults setFloat:_opacity forKey:@"AimAssistOpacity"];
    [defaults synchronize];
}

@end
