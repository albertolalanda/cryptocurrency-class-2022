// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface VictimContractInterface {
    function withdraw() external payable;
}

contract VictimContract {
    uint constant oneEther = 1 ether;
    uint256 toTransfer = oneEther;

    //Only 1 ether can be sent by this contract
    function withdraw() public payable {
        // Send 1 coin
        msg.sender.call{value: toTransfer};
        // Deduct balance by 1
        toTransfer = 0;
    }

    function withdrawNonVulnerable() public payable {
        require(address(this).balance >= oneEther, "Contract balance is not enough for withdraw");
        // Deduct balance by 1
        toTransfer = 0;
        // Send 1 coin
        msg.sender.call{value: oneEther};
    }

    // Use depost() to send 10 ether to contract
    function deposit() public payable {}
}
