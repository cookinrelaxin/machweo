//
//  Player.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 10/23/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "Player.h"
@implementation Player

//-(void)initAtPoint:(CGPoint)point{
//    self.physicsBody = [SKPhysicsBody body]
//    self.position = point;
//    self.minYPosition = -9999;
//}

+(instancetype)player{
    Constants* constants = [Constants sharedInstance];
    Player *player = [Player spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(constants.PLAYER_SIZE * constants.SCALE_COEFFICIENT.dy * .8259, constants.PLAYER_SIZE * constants.SCALE_COEFFICIENT.dy)];
    player.zPosition = constants.PLAYER_Z_POSITION;
    player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(player.size.width * 1/6, player.size.height * 1/6)];
    player.physicsBody.categoryBitMask = [Constants sharedInstance].PLAYER_HIT_CATEGORY;
    player.physicsBody.contactTestBitMask = [Constants sharedInstance].OBSTACLE_HIT_CATEGORY;
    player.physicsBody.affectedByGravity = false;
    player.physicsBody.allowsRotation = false;

    
    return player;
}

-(void)updateEdges{
    _yCoordinateOfBottomSide = self.position.y - (self.size.height / 2);
    _yCoordinateOfTopSide = self.position.y + (self.size.height / 2);
    _xCoordinateOfLeftSide = self.position.x - (self.size.width / 2);
    _xCoordinateOfRightSide = self.position.x + (self.size.width / 2);
}

-(void)resetMinsAndMaxs{
    self.minYPosition = -9999;
}

@end
