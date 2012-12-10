//
//  Solver.h
//  HakoSolver
//
//  Created by Kota Fujiwara on 2012/12/10.
//  Copyright (c) 2012年 Kota Fujiwara. All rights reserved.
//

#ifndef __HakoSolver__File__
#define __HakoSolver__File__

#include <iostream>

#define MAX_POSITIONS 216000
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

typedef struct{
    int rooms[COLS][ROWS];
} Position;

class Solver
{
public:
    Solver();
    ~Solver();
    void startProblem(Position *pos);
    bool solve(Position *pos);
    void pushPositions(Position *pos);
    void getTransitionsWithOneEmptySpace(Position *pos, int x, int y);
    void getTransitionsWithTwoEmptySpaces(Position *pos, int x1, int y1, int x2, int y2);
    Position* copyPosition(Position *source);
    std::string getPositionString(Position *pos);
private:
    Position *searchingPositions[MAX_POSITIONS];
    int searchingPositionIndex;
    Position *searchedPositions[MAX_POSITIONS];
    int searchedPositionIndex;
    Position *answerPositions[MAX_POSITIONS];
    int answerPositionIndex;
    Position* popPosition();
    char getHumanChar(int piece);
    bool isFinished(Position *pos);
    bool isAlreadySearched(Position *pos);
    void pushNewPositionIfPossible(Position *pos);
    void movePieceByOne(Position *pos, int x, int y, int dx, int dy, int pieceLength, int sizeType);
    void movePieceByTwo(Position *pos, int x1, int y1, int x2, int y2, int dx, int dy, int sizeType);
    void moveMusume(Position *pos, int x1, int y1, int x2, int y2, int dx, int dy);
    void assertValidPosition(Position *pos);

};

#endif /* defined(__HakoSolver__File__) */