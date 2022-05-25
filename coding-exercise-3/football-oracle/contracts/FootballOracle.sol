// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract FootballOracle {

    mapping (uint => bool) resultsAvailable;
    mapping (uint => uint[2]) matchResults;
    mapping (uint => uint) private timeOfResults;
    mapping (address => bool) trustedAddresses;

    // Time limit needed to withdraw coins, after a deposit
    uint constant TIME_LIMIT = 1 minutes;

    address public owner;

    constructor() {
        owner = msg.sender;
        trustedAddresses[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier trustedAddress() {
        require(trustedAddresses[msg.sender] == true, "Not trusted address");
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function addTrustedAddress(address _add) public onlyOwner {
        trustedAddresses[_add] = true;
    }

    function submitScore(uint _matchId, uint _score1, uint _score2) public trustedAddress {
        require(resultsAvailable[_matchId] == false, "This match result is already submitted, cannot resubmit!");
        (matchResults[_matchId][0], matchResults[_matchId][1]) = (_score1, _score2);
        resultsAvailable[_matchId] = true;
        timeOfResults[_matchId] = block.timestamp;
    }

    function removeScore(uint _matchId) public trustedAddress {
        require(block.timestamp - timeOfResults[_matchId]  >=  TIME_LIMIT , "The time has not yet expired, for this score" );
        delete matchResults[_matchId];
        resultsAvailable[_matchId] = false;
    }

    // All matches are indexed. Returns whether query was successful, alongside the scores
    function getScore(uint _matchId) public view returns (bool success, uint score1, uint score2) {
        return (resultsAvailable[_matchId], matchResults[_matchId][0], matchResults[_matchId][1]);
    }
}
