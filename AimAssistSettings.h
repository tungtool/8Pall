#import <Foundation/Foundation.h>

@interface AimAssistSettings : NSObject

+ (instancetype)sharedSettings;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) float lineWidth;
@property (nonatomic, assign) BOOL useBallColors;
@property (nonatomic, assign) float opacity;

- (void)synchronize;

@end
