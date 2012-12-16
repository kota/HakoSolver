//
//  Position.h
//  HakoiriMusmeSolver
//
//  Created by Fujiwara Kota on 12/12/16.
//
//

#ifndef __HakoiriMusmeSolver__Position__
#define __HakoiriMusmeSolver__Position__

#include <iostream>
#include <vector>

#define ROWS 5
#define COLS 4

#define EMPTY 0
#define SIZE_4x4 1
#define SIZE_1x2 2
#define SIZE_2x1 3
#define SIZE_1x1 4

#define EMPTY 0
#define MUSUME  (1<<4) + SIZE_4x4
#define CHICHI  (2<<4) + SIZE_1x2
#define HAHA    (3<<4) + SIZE_1x2
#define JOCHU1  (4<<4) + SIZE_1x2
#define JOCHU2  (5<<4) + SIZE_1x2
#define BANTO   (6<<4) + SIZE_2x1
#define TEDAI   (7<<4) + SIZE_1x1
#define DECCHI1 (8<<4) + SIZE_1x1
#define DECCHI2 (9<<4) + SIZE_1x1
#define DECCHI3 (10<<4) + SIZE_1x1

class Position{
public:
    Position();
    ~Position();
    
    int rooms[COLS][ROWS];
    Position *parent;
    
    std::vector<Position> getNextPositions();
    std::string getPositionString();
    bool isSolved();
    bool isIdenticalTo(const Position &pos) const;
    Position* copy();
    
private:
    std::vector<Position> getTransitionsWithOneEmptySpace(std::vector<Position> &positions, int x, int y);
    std::vector<Position> getTransitionsWithTwoEmptySpaces(std::vector<Position> &positions, int x1, int y1, int x2, int y2);
    Position* movePieceByOne(int x, int y, int dx, int dy, int pieceLength, int sizeType);
    Position* movePieceByTwo(int x1, int y1, int x2, int y2, int dx, int dy, int sizeType);
    Position* moveMusume(int x1, int y1, int x2, int y2, int dx, int dy);
    void assertValid();
    char getHumanChar(int piece);
    void pushPositionIfNotNull(Position *pos, std::vector<Position> &positions);
};

#endif /* defined(__HakoiriMusmeSolver__Position__) */