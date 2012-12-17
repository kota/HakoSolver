//
//  Position.mm
//  HakoiriMusmePosition
//
//  Created by Fujiwara Kota on 12/12/16.
//
//

#include "Position.h"

Position::Position(void){
}

Position::~Position(void){
}

std::vector<Position*> Position::getNextPositions()
{
    std::vector<Position*> positions;
    
    int emptyPositions[2][2];
    int emptyPostionIndex = 0;
    for (int i=0; i<COLS; i++) {
        for (int j=0; j<ROWS; j++) {
            if (rooms[i][j] == EMPTY) {
                emptyPositions[emptyPostionIndex][0] = i;
                emptyPositions[emptyPostionIndex][1] = j;
                emptyPostionIndex++;
            }
        }
    }
    assert(emptyPostionIndex == 2);
    int x1 = emptyPositions[0][0];
    int y1 = emptyPositions[0][1];
    getTransitionsWithOneEmptySpace(positions, x1, y1);
    
    int x2 = emptyPositions[1][0];
    int y2 = emptyPositions[1][1];
    getTransitionsWithOneEmptySpace(positions, x2, y2);
    
    getTransitionsWithTwoEmptySpaces(positions, x1, y1, x2, y2);

    return positions;
}

std::vector<Position*> Position::getTransitionsWithOneEmptySpace(std::vector<Position*> &positions, int x, int y)
{
    //1x2 above
    pushPositionIfNotNull(movePieceByOne(x, y, 0, -1, 2, SIZE_1x2), positions) ;
    //1x2 below
    pushPositionIfNotNull(movePieceByOne(x, y, 0, 1, 2, SIZE_1x2), positions);
    //2x1 left
    pushPositionIfNotNull(movePieceByOne(x, y, -1, 0, 2, SIZE_2x1), positions);
    //2x1 right
    pushPositionIfNotNull(movePieceByOne(x, y, 1, 0, 2, SIZE_2x1), positions);

    pushPositionIfNotNull(movePieceByOne(x, y, 1, 0, 1, SIZE_1x1), positions);
    pushPositionIfNotNull(movePieceByOne(x, y, -1, 0, 1, SIZE_1x1), positions);
    pushPositionIfNotNull(movePieceByOne(x, y, 0, 1, 1, SIZE_1x1), positions);
    pushPositionIfNotNull(movePieceByOne(x, y, 0, -1, 1, SIZE_1x1), positions);
    
    return positions;
}

Position* Position::movePieceByOne(int x, int y, int dx, int dy, int pieceLength, int sizeType)
{
    if(x+dx < COLS && x+dx >= 0 && y+dy < ROWS && y+dy >=0){
        if((rooms[x+dx][y+dy] & 7) == sizeType){
            Position *newPos = copy();
            newPos->parent = this;
            newPos->rooms[x][y] = rooms[x+(dx*pieceLength)][y+(dy*pieceLength)];
            newPos->rooms[x+(dx*pieceLength)][y+(dy*pieceLength)] = EMPTY;
            assertValid();
            return newPos;
        }
    }
    return NULL;
}

Position* Position::movePieceByTwo(int x1, int y1, int x2, int y2, int dx, int dy, int sizeType)
{
    if(x1+dx >= 0 && x2+dx < COLS && y1+dy >= 0 && y1+dy < ROWS){
        if ((rooms[x1+dx][y1+dy] & 7) == sizeType && (rooms[x1+dx][y1+dy] == rooms[x2+dx][y2+dy])) {
            Position *newPos = copy();
            newPos->parent = this;
            newPos->rooms[x1][y1] = newPos->rooms[x1+dx][y1+dy];
            newPos->rooms[x2][y2] = newPos->rooms[x2+dx][y2+dy];
            newPos->rooms[x1+dx][y1+dy] = EMPTY;
            newPos->rooms[x2+dx][y2+dy] = EMPTY;
            return newPos;
        }
    }
    return NULL;
}

void Position::assertValid()
{
    int numEmpty = 0;
    for (int i=0; i<COLS; i++) {
        for (int j=0; j<ROWS; j++) {
            if (rooms[i][j] == EMPTY) {
                numEmpty++;
            }
        }
    }
    assert(numEmpty == 2);
}

std::vector<Position*> Position::getTransitionsWithTwoEmptySpaces(std::vector<Position*> &positions, int x1, int y1, int x2, int y2)
{
    //縦横につながってなければ終了
    if (abs(x1-x2)+abs(y1-y2) != 1) {
        return positions;
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
        pushPositionIfNotNull(moveMusume(x1, y1, x2, y2, 0, -1), positions);
        //Musume below
        pushPositionIfNotNull(moveMusume(x1, y1, x2, y2, 0, 1), positions);
        
        //Banto above
        pushPositionIfNotNull(movePieceByTwo(x1, y1, x2, y2, 0, -1, SIZE_2x1), positions);
        //Banto below
        pushPositionIfNotNull(movePieceByTwo(x1, y1, x2, y2, 0, 1, SIZE_2x1), positions);
        //Banto left
        pushPositionIfNotNull(movePieceByTwo(x1, y1, x2, y2, -2, 0, SIZE_2x1), positions);
        //Banto right
        pushPositionIfNotNull(movePieceByTwo(x1, y1, x2, y2, 2, 0, SIZE_2x1), positions);
    }
    if (abs(y1-y2) == 1) {
        //Musume left
        pushPositionIfNotNull(moveMusume(x1, y1, x2, y2, -1, 0), positions);
        //Musume right
        pushPositionIfNotNull(moveMusume(x1, y1, x2, y2, 1, 0), positions);
        
        //Parent,Jochu above
        pushPositionIfNotNull(movePieceByTwo(x1, y1, x2, y2, 0, -2, SIZE_1x2), positions);
        //Parent,Jochu below
        pushPositionIfNotNull(movePieceByTwo(x1, y1, x2, y2, 0, 2, SIZE_1x2), positions);
        //Parent,Jochu left
        pushPositionIfNotNull(movePieceByTwo(x1, y1, x2, y2, -1, 0, SIZE_1x2), positions);
        //Parent,Jochu right
        pushPositionIfNotNull(movePieceByTwo(x1, y1, x2, y2, 1, 0, SIZE_1x2), positions);
    }
    return positions;
}

Position* Position::moveMusume(int x1, int y1, int x2, int y2, int dx, int dy){
    if(x1+(dx*2) < COLS && x1+(dx*2) >= 0 && y1+(dy*2) < ROWS && y1+(dy*2) >=0){
        if (rooms[x1+dx][y1+dy] == MUSUME && rooms[x2+dx][y2+dy] == MUSUME) {
            Position *newPos = copy();
            newPos->parent = this;
            newPos->rooms[x1][y1] = MUSUME;
            newPos->rooms[x2][y2] = MUSUME;
            newPos->rooms[x1+(dx*2)][y1+(dy*2)] = EMPTY;
            newPos->rooms[x2+(dx*2)][y2+(dy*2)] = EMPTY;
            return newPos;
        }
    }
    return NULL;
}

void Position::pushPositionIfNotNull(Position *pos, std::vector<Position*> &positions)
{
    if (pos != NULL) {
        positions.push_back(pos);
    }
}

bool Position::isSolved()
{
    return rooms[1][4] == MUSUME && rooms[2][4] == MUSUME;
}

bool Position::isIdenticalTo(Position *pos) const
{
    for (int x=0; x<COLS; x++) {
        for (int y=0; y<ROWS; y++) {
            if ((pos->rooms[x][y] & 7) != (rooms[x][y] & 7)) {
                return false;
            }
        }
    }
    return true;
}

Position* Position::copy()
{
    Position *newPos = new Position();
    newPos->parent = parent;
     for (int i=0; i<COLS; i++) {
        for (int j=0; j<ROWS; j++) {
            newPos->rooms[i][j] = rooms[i][j];
        }
     }
    return newPos;
}

std::string Position::getPositionString()
{
    std::string str = "";
    for(int i=0;i<ROWS;i++){
        char row[128];
        sprintf(row, "\n %c %c %c %c",getHumanChar(rooms[0][i]),getHumanChar(rooms[1][i]),getHumanChar(rooms[2][i]),getHumanChar(rooms[3][i]));
        str += row;
    }
    return str;
}

char Position::getHumanChar(int piece)
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