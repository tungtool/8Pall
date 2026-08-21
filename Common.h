#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class CCNode, CCDirector, CCScene, CCLayer, CCHybridMenu, CCRenderTexture;
@class MCMenuItemNodeRGBAStatic, MCAdjustableLabelTTF, CCMenuItem;
@class Table, Ball, BallManager, TableProperties;

typedef struct {
    CGPoint position;
    float radius;
    uint32_t number;
    uint8_t classification;
    BOOL isPocketed;
} BallInfo;

typedef struct {
    CGPoint position;
    float radius;
} PocketInfo;

static inline ccColor4F colorForBallNumber(uint32_t number) {
    ccColor4F colors[16] = {
        {1.0, 1.0, 1.0, 1.0},
        {1.0, 0.8, 0.0, 1.0},
        {0.0, 0.0, 1.0, 1.0},
        {1.0, 0.0, 0.0, 1.0},
        {0.5, 0.0, 0.5, 1.0},
        {1.0, 0.5, 0.0, 1.0},
        {0.0, 0.5, 0.0, 1.0},
        {0.5, 0.0, 0.0, 1.0},
        {0.0, 0.0, 0.0, 1.0},
        {1.0, 0.8, 0.0, 1.0},
        {0.0, 0.0, 1.0, 1.0},
        {1.0, 0.0, 0.0, 1.0},
        {0.5, 0.0, 0.5, 1.0},
        {1.0, 0.5, 0.0, 1.0},
        {0.0, 0.5, 0.0, 1.0},
        {0.5, 0.0, 0.0, 1.0}
    };
    return (number < 16) ? colors[number] : (ccColor4F){1,1,1,1};
}
