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
#include "Position.h"
#include <queue>
#include <vector>

#define MAX_POSITIONS 216000

class Solver
{
public:
    Solver();
    ~Solver();
    void startProblem(const Position &pos);
    Position* solve(const Position &pos);

private:
    std::queue<Position> _queue;
    std::vector<Position> _searchedPositions;
    
    bool isPositionAlreadySearched(const Position &pos);
};

#endif /* defined(__HakoSolver__File__) */