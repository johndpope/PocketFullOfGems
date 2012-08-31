//
//  HelloWorldLayer.m
//  PocketFullOfGems
//
//  Created by Ashik Manandhar on 3/5/12.
//  Copyright Pocket Gems 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

#define kBottomControls 75
#define kStartoffArea 30
#define kHighestNumberOfGems 8

@interface HelloWorldLayer ()

@property (nonatomic, retain) CCSprite *character;
@property int points;
@property (nonatomic, retain) CCArray *gems;
@property (nonatomic, retain) CCLabelTTF *score;

- (void) initCharacter;
- (void) initScore;
- (void) initDirectionPad;
- (void) initGems;

- (void) upSelected;
- (void) downSelected;
- (void) leftSelected;
- (void) rightSelected;

- (void) checkForCollisions;

- (void) updateScore;

@end


// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize character = character_;
@synthesize points = points_;
@synthesize gems = gems_;
@synthesize score = score_;

#pragma mark - Constructor / Destructor

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
    
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		[self initScore];
        [self initDirectionPad];
        [self initGems];
        [self initCharacter];
	}
	return self;
}

- (void) dealloc
{
    self.character = nil;
    
	[super dealloc];
}

#pragma mark - Initializers
- (void) initCharacter {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    //Adding character to screen
    self.character = [CCSprite spriteWithFile:@"Icon-Small@2x.png"];
    self.character.position = CGPointMake(size.width/2, 
                                          kBottomControls + [self.character texture].contentSize.height/2);
    [self addChild:self.character];
}

- (void) initScore {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    //Score label
    self.score = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:48];
    self.score.position = CGPointMake(size.width/2,
                                      size.height - [self.score texture].contentSize.height/2);
    [self addChild:self.score];
}

- (void) initDirectionPad {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    //Adding direction pad to screen
    CCMenu *menu = [CCMenu menuWithItems:nil];
    menu.position = CGPointMake(0, 0);
    menu.anchorPoint = CGPointMake(0, 0);
    [self addChild:menu];
    
    //Left button
    CCSprite *leftSprite = [CCSprite spriteWithFile:@"left.png"];
    CCSprite *leftSelectedSprite = [CCSprite spriteWithTexture:[leftSprite texture]];
    leftSelectedSprite.color = ccGRAY;
    CCMenuItemImage *leftButton = [CCMenuItemImage itemFromNormalSprite:leftSprite 
                                                         selectedSprite:leftSelectedSprite 
                                                                 target:self 
                                                               selector:@selector(leftSelected)];
    leftButton.position = CGPointMake([leftSprite texture].contentSize.width/2, 
                                      [leftSprite texture].contentSize.height/2);
    [menu addChild:leftButton];
    
    //Up button
    CCSprite *upSprite = [CCSprite spriteWithFile:@"up.png"];
    CCSprite *upSelectedSprite = [CCSprite spriteWithTexture:[upSprite texture]];
    upSelectedSprite.color = ccGRAY;
    CCMenuItemImage *upButton = [CCMenuItemImage itemFromNormalSprite:upSprite 
                                                       selectedSprite:upSelectedSprite 
                                                               target:self 
                                                             selector:@selector(upSelected)];
    upButton.position = CGPointMake(size.width/3,// leftButton.position.x + [leftSprite texture].contentSize.width/2 + [upSprite texture].contentSize.width/2, 
                                    [upSprite texture].contentSize.height/2);
    [menu addChild:upButton];
    
    //Down button
    CCSprite *downSprite = [CCSprite spriteWithFile:@"down.png"];
    CCSprite *downSelectedSprite = [CCSprite spriteWithTexture:[downSprite texture]];
    downSelectedSprite.color = ccGRAY;
    CCMenuItemImage *downButton = [CCMenuItemImage itemFromNormalSprite:downSprite 
                                                         selectedSprite:downSelectedSprite 
                                                                 target:self 
                                                               selector:@selector(downSelected)];
    downButton.position = CGPointMake(size.width*2/3, //upButton.position.x + [upSprite texture].contentSize.width/2 + [downSprite texture].contentSize.width/2, 
                                      [downSprite texture].contentSize.height/2);
    [menu addChild:downButton];
    
    //Right button
    CCSprite *rightSprite = [CCSprite spriteWithFile:@"right.png"];
    CCSprite *rightSelectedSprite = [CCSprite spriteWithTexture:[rightSprite texture]];
    rightSelectedSprite.color = ccGRAY;
    CCMenuItemImage *rightButton = [CCMenuItemImage itemFromNormalSprite:rightSprite 
                                                          selectedSprite:rightSelectedSprite 
                                                                  target:self 
                                                                selector:@selector(rightSelected)];
    rightButton.position = CGPointMake(size.width - [rightSprite texture].contentSize.width/2, 
                                       [rightSprite texture].contentSize.height/2);
    [menu addChild:rightButton];
}

- (void) initGems {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    int numberOfGems = CCRANDOM_0_1() * kHighestNumberOfGems;
    
    self.gems = [CCArray arrayWithCapacity:numberOfGems];
    
    for (int i = 0; i < numberOfGems; i++) {
        CCSprite *gem = [CCSprite spriteWithFile:@"gem.png"];
        
        int xPosition = CCRANDOM_0_1() * (size.width - [gem texture].contentSize.width);
        int yPosition = CCRANDOM_0_1() * (size.height - kBottomControls - kStartoffArea - [gem texture].contentSize.height);
        yPosition += kBottomControls;
        yPosition += kStartoffArea;
        
        gem.position = CGPointMake(xPosition, yPosition);
        
        CCRotateBy *rotation = [CCRotateBy actionWithDuration:(CCRANDOM_0_1() * 5) angle:360];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:rotation];
        [gem runAction:repeat];
        
        [self.gems addObject:gem];
        [self addChild:gem];
    }
}


#pragma mark - Directional pad
- (void) upSelected {
    int yPosition = self.character.position.y;
    yPosition += [self.character texture].contentSize.height/2;
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    if (yPosition >= (size.height - [self.character texture].contentSize.height/2)) {
        yPosition = (size.height - [self.character texture].contentSize.height/2);
    }
    
    self.character.position = CGPointMake(self.character.position.x, yPosition);
    
    [self checkForCollisions];
}

- (void) downSelected {
    int yPosition = self.character.position.y;
    yPosition -= [self.character texture].contentSize.height/2;
    
    if (yPosition <= (kBottomControls + [self.character texture].contentSize.height/2)) {
        yPosition = (kBottomControls + [self.character texture].contentSize.height/2);
    }
    
    self.character.position = CGPointMake(self.character.position.x, yPosition);
    
    [self checkForCollisions];
}

- (void) leftSelected {
    int xPosition = self.character.position.x;
    xPosition -= [self.character texture].contentSize.width/2;
    
    if (xPosition <= [self.character texture].contentSize.width/2) {
        xPosition = [self.character texture].contentSize.width/2;
    }
    
    self.character.position = CGPointMake(xPosition, self.character.position.y);
    
    [self checkForCollisions];
}

- (void) rightSelected {
    int xPosition = self.character.position.x;
    xPosition += [self.character texture].contentSize.width/2;
    
    CGSize size = [[CCDirector sharedDirector] winSize];    
    if (xPosition >= (size.width - [self.character texture].contentSize.width/2)) {
        xPosition = size.width - [self.character texture].contentSize.width/2;
    }
    
    self.character.position = CGPointMake(xPosition, self.character.position.y);
    
    [self checkForCollisions];
}

#pragma mark - Collision check
- (void) checkForCollisions {
    if (![self.gems count]) {
        return;
    }
    
    float characterSize = [self.character texture].contentSize.width;
    float gemSize = [[self.gems lastObject] texture].contentSize.width;
    
    float characterCollisionRadius = characterSize * 0.4f;
    float gemCollisionRadius = gemSize * 0.4f;
    
    float maxCollisionDistance = characterCollisionRadius + gemCollisionRadius;
    
    CCArray *gemsToRemove = [CCArray array];
    
    for (int i = 0; i < [self.gems count]; i++) {
        CCSprite *gem = [self.gems objectAtIndex:i];
        
        float distance = ccpDistance(self.character.position, gem.position);
        
        if (distance < maxCollisionDistance) {
            [gemsToRemove addObject:gem];
            self.points = self.points + 1;
        }
    }
    
    for (int i = 0; i < [gemsToRemove count]; i++) {
        [self.gems removeObject:[gemsToRemove objectAtIndex:i]];
        [self removeChild:[gemsToRemove objectAtIndex:i] 
                  cleanup:YES];
    }
    
    [self updateScore];
}

- (void) updateScore {
    [self.score setString:[NSString stringWithFormat:@"%d", self.points]];
}

@end
