// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface FootballOracle {
    // All matches are indexed. Returns whether query was successful,
    // alongside the scores
    function getScore(uint256 matchid) external returns (bool success, uint256 score1, uint256 score2);
}


contract EmitMatchEvent {
    event MatchScore(uint256 matchid, uint256 score1, uint256 score2);
    FootballOracle public oracle;

    constructor(address _oracle) {
        oracle = FootballOracle(_oracle);
    }

    function checkScore(uint256 matchid) public {
        bool success;
        uint256 score1;
        uint256 score2;
        // Fetch scores from the oracle
        (success, score1, score2) = oracle.getScore(matchid);
        // If query works, tell world about the score!
        if (success) {
            emit MatchScore(matchid, score1, score2);
        }
    }
}
