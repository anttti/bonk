//
//  MainMenuScene.m
//  BONK
//
//  Created by Antti Mattila on 23.2.2014.
//  Copyright (c) 2014 Alupark. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameScene.h"

@implementation MainMenuScene

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"MainMenu"];
        bg.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:bg];
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"ArialRoundedMTBold"];
        label.fontSize = 32;
        label.color = [SKColor whiteColor];
        label.text = @"pressanykey";
        label.position = CGPointMake(self.size.width / 2, 30);
        SKAction *scaleUp = [SKAction scaleBy:1.1 duration:1];
        SKAction *blink = [SKAction sequence:@[scaleUp, [scaleUp reversedAction]]];
        [label runAction:[SKAction repeatActionForever:blink]];
        [self addChild:label];
    }

    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    SKScene *gameScene = [[GameScene alloc] initWithSize:self.size];
    SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.5];
    [self.view presentScene:gameScene transition:reveal];
}

@end
