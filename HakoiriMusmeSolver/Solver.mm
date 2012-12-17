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

}

Solver::~Solver(void){
}

void Solver::startProblem(Position *pos){
    Position::initializeZobristHashSeeds();
    pos->generateHash();
    
    Position *lastPosition = solve(pos);
    if(lastPosition){
        Position *pos = lastPosition;
        int count = 0;
        while (true) {
            count++;
            NSLog(@"%s",pos->getPositionString().c_str());
            pos = pos->parent;
            if(!pos){
                NSLog(@"Solved with %d moves.",count);
                return;
            }
        }
    } else {
        NSLog(@"Could not solved.");
    }
}

Position* Solver::solve(Position *initialPosition){
    _queue.push(initialPosition);
    while (!_queue.empty()) {
        Position *pos = _queue.front();
        _queue.pop();
        
        std::vector<Position*> nextPositions = pos->getNextPositions();
        int numNextPositions = nextPositions.size();
        for(int i=0;i<numNextPositions;i++) {
            Position *next = nextPositions[i];
            if (!isPositionAlreadySearched(next)) {
                if (next->isSolved()) {
                    Position *nextPointer = next->copy();
                    return nextPointer;
                }
                _searchedPositions.push_back(next);
                _queue.push(next);
            }

        }
    }
    return NULL;
}

bool Solver::isPositionAlreadySearched(Position* pos)
{
    std::vector<Position*>::iterator it;
    for (it = _searchedPositions.begin();it != _searchedPositions.end();it++ ) {
        if (pos->hash == (*it)->hash) {
            return true;
        }
    }
    return false;
}