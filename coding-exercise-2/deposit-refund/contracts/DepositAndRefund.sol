// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract DepositAndRefund {

    mapping(address => uint) public balances;
    // mapping of addresses with timestamp of latest deposit
    mapping(address => uint) private timersOfDeposit;

    // Time limit needed to withdraw coins, after a deposit
    uint constant TIME_LIMIT = 30 seconds;

    //get message in bytes, solidity >=8.8
    bytes32 hash_expected_message = getMessageHash("to the moon");

    function getBalance(address _party) external view returns (uint) {
        return balances[_party];
    }

    function deposit() external payable {
        require(msg.value > 0);
        // set block timestamp of deposit for the account
        timersOfDeposit[msg.sender] = block.timestamp;
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint _amount) public payable {
        require(balances[msg.sender] >= _amount, "Account balance is not enough");
        require(block.timestamp - timersOfDeposit[msg.sender]  >=  TIME_LIMIT , "Not enough time passed to withdraw" );
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function withdraw_signed(uint _amount, bytes calldata _signature) external payable { 
        address expected_address =  recoverSigner( getEthSignedMessageHash(hash_expected_message), _signature);

        require(expected_address == msg.sender,  "Signature not valid" );

        withdraw(_amount);
    }

    // source for the next helper functions: https://solidity-by-example.org/signature/

    function getMessageHash(string memory _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) private pure returns (bytes32) {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        private
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }


}
