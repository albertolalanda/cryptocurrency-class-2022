// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract VictimContract {
    uint256 public toTransfer = 1 ether;

    //Only 1 ether can be sent by this contract
    function withdraw() public payable {
        // Send 1 coin
        msg.sender.call{value: toTransfer}('');
        // Deduct balance by 1
        toTransfer = 0;
    }

    //Withdraw safe from reentrancy attacks - implemented Checks-effects-interaction paradigm
    function withdrawNonVulnerable() public payable {
        //CHECKS
        require(address(this).balance >= toTransfer, "Contract balance is not enough for withdraw");
        require(toTransfer == 1 ether, "This contract is not allowed to tranfer more ether");
        //EFFECTS - Deduct balance by 1
        toTransfer = 0;
        //INTERACTIONS - Send 1 coin
        msg.sender.call{value: toTransfer}('');
    }

    // Use depost() to send 10 ether to contract
    function deposit() public payable {}
}
