//
//  Solver.cpp
//  HakoSolver
//
//  Created by Kota Fujiwara on 2012/12/10.
//  Copyright (c) 2012年 Kota Fujiwara. All rights reserved.
//

#include "Solver.h"
#include "stdio.h"

Solver::Solver(void){
    searchingPositionIndex = 0;
    searchedPositionIndex = 0;
    answerPositionIndex = 0;
}

Solver::~Solver(void){
}

void Solver::startProblem(Position *pos){
    if(solve(pos)){
        NSLog(@"solved with %d moves.",answerPositionIndex);
        for (int i=answerPositionIndex-1; i>=0; i--) {
            NSLog(@"%s",getPositionString(answerPositions[i]).c_str());
        }
    }
}

bool Solver::solve(Position *pos){
    if (isFinished(pos)) {
        answerPositions[answerPositionIndex++] = pos;
        return true;
    }
    pushPositions(pos);
    if (searchingPositionIndex == 0) {
        return false;
    }
    Position *nextPostions[20]; //てきとう
    //pushPositions(pos)でメンバ変数に入れたpositionsをローカルにコピー。ほんとはpushPositionsをgetPositionsにして配列を返したい。
    for (int i=0; i<searchingPositionIndex; i++) {
        Position *newPos = copyPosition(searchingPositions[i]);
        nextPostions[i] = newPos;
    }
    int numPositions = searchingPositionIndex;
    searchingPositionIndex = 0;
    
    int index = 0;
    while (true) {
        if (index >= numPositions) {
            break;
        }
        Position *newPostion = nextPostions[index++];
        if (solve(newPostion)) {
            answerPositions[answerPositionIndex++] = pos;
            return true;
        }
    }
    return false;
}

Position* Solver::popPosition()
{
    if (searchingPositionIndex >= 0) {
        searchingPositionIndex--;
        return searchingPositions[searchingPositionIndex];
    }
    return NULL;
}

void Solver::pushPositions(Position *pos){
    int emptyPositions[2][2];
    int emptyPostionIndex = 0;
    for (int i=0; i<COLS; i++) {
        for (int j=0; j<ROWS; j++) {
            if (pos->rooms[i][j] == EMPTY) {
                emptyPositions[emptyPostionIndex][0] = i;
                emptyPositions[emptyPostionIndex][1] = j;
                emptyPostionIndex++;
            }
        }
    }
    assert(emptyPostionIndex == 2);
    int x1 = emptyPositions[0][0];
    int y1 = emptyPositions[0][1];
    getTransitionsWithOneEmptySpace(pos, x1, y1);
    
    int x2 = emptyPositions[1][0];
    int y2 = emptyPositions[1][1];
    getTransitionsWithOneEmptySpace(pos, x2, y2);

    getTransitionsWithTwoEmptySpaces(pos, x1, y1, x2, y2);
}

void Solver::getTransitionsWithOneEmptySpace(Position *pos, int x, int y)
{
    //1x2 above
    movePieceByOne(pos, x, y, 0, -1, 2, SIZE_1x2);
    //1x2 below
    movePieceByOne(pos, x, y, 0, 1, 2, SIZE_1x2);
    //2x1 left
    movePieceByOne(pos, x, y, -1, 0, 2, SIZE_2x1);
    //2x1 right
    movePieceByOne(pos, x, y, 1, 0, 2, SIZE_2x1);

    movePieceByOne(pos, x, y, 1, 0, 1, SIZE_1x1);
    movePieceByOne(pos, x, y, -1, 0, 1, SIZE_1x1);
    movePieceByOne(pos, x, y, 0, 1, 1, SIZE_1x1);
    movePieceByOne(pos, x, y, 0, -1, 1, SIZE_1x1);
}

void Solver::movePieceByOne(Position *pos, int x, int y, int dx, int dy, int pieceLength, int sizeType)
{
    if(x+dx < COLS && x+dx >= 0 && y+dy < ROWS && y+dy >=0){
        if((pos->rooms[x+dx][y+dy] & 7) == sizeType){
            Position *newPos = copyPosition(pos);
            newPos->rooms[x][y] = pos->rooms[x+(dx*pieceLength)][y+(dy*pieceLength)];
            newPos->rooms[x+(dx*pieceLength)][y+(dy*pieceLength)] = EMPTY;
            assertValidPosition(newPos);
            pushNewPositionIfPossible(newPos);
        }
    }
}

void Solver::movePieceByTwo(Position *pos, int x1, int y1, int x2, int y2, int dx, int dy, int sizeType)
{
    if(x1+dx >= 0 && x2+dx < COLS && y1+dy >= 0 && y1+dy < ROWS){
        if ((pos->rooms[x1+dx][y1+dy] & 7) == sizeType && (pos->rooms[x1+dx][y1+dy] == pos->rooms[x2+dx][y2+dy])) {
            Position *newPos = copyPosition(pos);
            newPos->rooms[x1][y1] = newPos->rooms[x1+dx][y1+dy];
            newPos->rooms[x2][y2] = newPos->rooms[x2+dx][y2+dy];
            newPos->rooms[x1+dx][y1+dy] = EMPTY;
            newPos->rooms[x2+dx][y2+dy] = EMPTY;
            pushNewPositionIfPossible(newPos);
        }
    }
}

void Solver::assertValidPosition(Position *pos)
{
    int numEmpty = 0;
    for (int i=0; i<COLS; i++) {
        for (int j=0; j<ROWS; j++) {
            if (pos->rooms[i][j] == EMPTY) {
                numEmpty++;
            }
        }
    }
    assert(numEmpty == 2);
}

void Solver::pushNewPositionIfPossible(Position *pos)
{
    if (!isAlreadySearched(pos)) {
        searchingPositions[searchingPositionIndex] = pos;
        searchingPositionIndex++;
        searchedPositions[searchedPositionIndex] = pos;
        searchedPositionIndex++;
    }
}

void Solver::getTransitionsWithTwoEmptySpaces(Position *pos, int x1, int y1, int x2, int y2)
{
    //縦横につながってなければ終了
    if (abs(x1-x2)+abs(y1-y2) != 1) {
        return;
    }
    //小さい方を1にする
    if (x1 > x2 || y1 > y2) {
        int tmp = x1;
        x1 = x2;
        x2 = tmp;
        tmp = y1;
        y1 = y2;
        y2 = tmp;
    }
    if (abs(x1-x2) == 1) {
        //Musume above
        moveMusume(pos, x1, y1, x2, y2, 0, -1);
        //Musume below
        moveMusume(pos, x1, y1, x2, y2, 0, 1);
        
        //Banto above
        movePieceByTwo(pos, x1, y1, x2, y2, 0, -1, SIZE_2x1);
        //Banto below
        movePieceByTwo(pos, x1, y1, x2, y2, 0, 1, SIZE_2x1);
        //Banto left
        movePieceByTwo(pos, x1, y1, x2, y2, -2, 0, SIZE_2x1);
        //Banto right
        movePieceByTwo(pos, x1, y1, x2, y2, 2, 0, SIZE_2x1);
    }
    if (abs(y1-y2) == 1) {
        //Musume left
        moveMusume(pos, x1, y1, x2, y2, -1, 0);
        //Musume right
        moveMusume(pos, x1, y1, x2, y2, 1, 0);
        
        //Parent,Jochu above
        movePieceByTwo(pos, x1, y1, x2, y2, 0, -2, SIZE_1x2);
        //Parent,Jochu below
        movePieceByTwo(pos, x1, y1, x2, y2, 0, 2, SIZE_1x2);
        //Parent,Jochu left
        movePieceByTwo(pos, x1, y1, x2, y2, -1, 0, SIZE_1x2);
        //Parent,Jochu right
        movePieceByTwo(pos, x1, y1, x2, y2, 1, 0, SIZE_1x2);
    }
}

void Solver::moveMusume(Position *pos, int x1, int y1, int x2, int y2, int dx, int dy){
    if(x1+(dx*2) < COLS && x1+(dx*2) >= 0 && y1+(dy*2) < ROWS && y1+(dy*2) >=0){
        if (pos->rooms[x1+dx][y1+dy] == MUSUME && pos->rooms[x2+dx][y2+dy] == MUSUME) {
            Position *newPos = copyPosition(pos);
            newPos->rooms[x1][y1] = MUSUME;
            newPos->rooms[x2][y2] = MUSUME;
            newPos->rooms[x1+(dx*2)][y1+(dy*2)] = EMPTY;
            newPos->rooms[x2+(dx*2)][y2+(dy*2)] = EMPTY;
            pushNewPositionIfPossible(newPos);
        }
    }
}

bool Solver::isFinished(Position *pos)
{
    return pos->rooms[1][4] == MUSUME && pos->rooms[2][4] == MUSUME;
}

bool Solver::isAlreadySearched(Position *pos)
{
    for (int i=0; i<searchedPositionIndex; i++) {
        Position *searchedPos = searchedPositions[i];
        bool identical = true;
        for (int x=0; x<COLS; x++) {
            for (int y=0; y<ROWS; y++) {
                if ((searchedPos->rooms[x][y] & 7) != (pos->rooms[x][y] & 7)) {
                    identical = false;
                    break;
                }
            }
        }
        if (identical) {
            return true;
        }
    }
    return false;
}

Position* Solver::copyPosition(Position *source)
{
    Position *newPos = new Position;
     for (int i=0; i<COLS; i++) {
        for (int j=0; j<ROWS; j++) {
            newPos->rooms[i][j] = source->rooms[i][j];
        }
     }
    return newPos;
}

std::string Solver::getPositionString(Position *pos)
{
    std::string str = "";
    for(int i=0;i<ROWS;i++){
        char row[128];
        sprintf(row, "\n %c %c %c %c",getHumanChar(pos->rooms[0][i]),getHumanChar(pos->rooms[1][i]),getHumanChar(pos->rooms[2][i]),getHumanChar(pos->rooms[3][i]));
        str += row;
    }
    return str;
}

char Solver::getHumanChar(int piece)
{
    switch (piece & 7) {
        case SIZE_4x4:
            return 'M';
            break;
        case SIZE_1x2:
            return 'P';
            break;
        case SIZE_2x1:
            return 'B';
            break;
        case SIZE_1x1:
            return 'D';
            break;
        default:
            return ' ';
            break;
    }
}