#import "Common.h"
#import "CCNode.h"

@interface AimAssistOverlay : CCNode

@property (nonatomic, weak) Table *currentTable;

- (void)markDirty;
- (void)updateWithBalls:(NSArray<BallInfo *> *)balls pockets:(NSArray<PocketInfo *> *)pockets;
- (void)refresh;

@end
