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

int Position::zobristHashSeeds[COLS][ROWS][5];

void Position::initializeZobristHashSeeds()
{
    for (int i=0; i<COLS; i++) {
        for (int j=0; j<ROWS; j++) {
            for (int k=0; k<5; k++) {
                zobristHashSeeds[i][j][k] = rand();
            }
        }
    }
}

void Position::generateHash()
{
    int newHash = 0;
    for (int i=0; i<COLS; i++) {
        for (int j=0; j<ROWS; j++) {
            newHash ^= zobristHashSeeds[i][j][this->rooms[i][j] & 7];
        }
    }
    this->hash = newHash;
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
            int destX = x+(dx*pieceLength);
            int destY = y+(dy*pieceLength);
            newPos->hash ^= zobristHashSeeds[x][y][newPos->rooms[x][y]&7];
            newPos->hash ^= zobristHashSeeds[x][y][newPos->rooms[destX][destY]&7];
            newPos->hash ^= zobristHashSeeds[destX][destY][newPos->rooms[destX][destY]&7];
            newPos->hash ^= zobristHashSeeds[destX][destY][newPos->rooms[x][y]&7];
            newPos->rooms[x][y] = rooms[destX][destY];
            newPos->rooms[destX][destY] = EMPTY;
            assertValid();
            return newPos;
        }
    }
    return NULL;
}

Position* Position::movePieceByTwo(int x1, int y1, int x2, int y2, int dx, int dy, int sizeType)
{
    int destX1 = x1+dx;
    int destY1 = y1+dy;
    int destX2 = x2+dx;
    int destY2 = y2+dy;
    if(destX1 >= 0 && destX2 < COLS && destY1 >= 0 && destY2 < ROWS){ //destY1<ROWSって書いてあったけどバグ?
        if ((rooms[destX1][destY1] & 7) == sizeType && (rooms[destX1][destY1] == rooms[destX2][destY2])) {
            Position *newPos = copy();
            newPos->parent = this;
            newPos->hash ^= zobristHashSeeds[x1][y1][newPos->rooms[x1][y1]&7];
            newPos->hash ^= zobristHashSeeds[x1][y1][newPos->rooms[destX1][destY1]&7];
            newPos->hash ^= zobristHashSeeds[destX1][destY1][newPos->rooms[destX1][destY1]&7];
            newPos->hash ^= zobristHashSeeds[destX1][destY1][newPos->rooms[x1][y1]&7];
            newPos->hash ^= zobristHashSeeds[x2][y2][newPos->rooms[x2][y2]&7];
            newPos->hash ^= zobristHashSeeds[x2][y2][newPos->rooms[destX2][destY2]&7];
            newPos->hash ^= zobristHashSeeds[destX2][destY2][newPos->rooms[destX2][destY2]&7];
            newPos->hash ^= zobristHashSeeds[destX2][destY2][newPos->rooms[x2][y2]&7];
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
    int destX1 = x1+(dx*2);
    int destY1 = y1+(dy*2);
    int destX2 = x2+(dx*2);
    int destY2 = y2+(dy*2);
    if(destX1 < COLS && destX1 >= 0 && destY1 < ROWS && destY1 >=0){
        if (rooms[x1+dx][y1+dy] == MUSUME && rooms[x2+dx][y2+dy] == MUSUME) {
            Position *newPos = copy();
            newPos->parent = this;
            
            newPos->hash ^= zobristHashSeeds[x1][y1][EMPTY];
            newPos->hash ^= zobristHashSeeds[x1][y1][SIZE_4x4];
            newPos->hash ^= zobristHashSeeds[x2][y2][EMPTY];
            newPos->hash ^= zobristHashSeeds[x2][y2][SIZE_4x4];
            newPos->hash ^= zobristHashSeeds[destX1][destY1][SIZE_4x4];
            newPos->hash ^= zobristHashSeeds[destX1][destY1][EMPTY];
            newPos->hash ^= zobristHashSeeds[destX2][destY2][SIZE_4x4];
            newPos->hash ^= zobristHashSeeds[destX2][destY2][EMPTY];
            
            newPos->rooms[x1][y1] = MUSUME;
            newPos->rooms[x2][y2] = MUSUME;
            newPos->rooms[destX1][destY1] = EMPTY;
            newPos->rooms[destX2][destY2] = EMPTY;
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

bool Position::isIdenticalTo(const Position &pos) const
{
//    for (int x=0; x<COLS; x++) {
//        for (int y=0; y<ROWS; y++) {
//            if ((pos.rooms[x][y] & 7) != (rooms[x][y] & 7)) {
//                return false;
//            }
//        }
//    }
//    return true;
    return this->hash == pos.hash;
}

Position* Position::copy()
{
    Position *newPos = new Position();
    newPos->parent = parent;
    newPos->hash = hash;
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