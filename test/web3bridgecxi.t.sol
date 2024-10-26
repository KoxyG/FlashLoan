// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import {Utilities} from "../utils/Utilities.sol";

import "forge-std/Test.sol";

import {Web3BridgeCXIPool} from "../src/web3bridgecxipool.sol";

import {Attacker} from "../src/Attacker.sol";


// flash loan test
contract Web3BridgeCXIPoolTest is Test {
    uint256 internal constant ETHER_IN_POOL = 1_000e18;

    Utilities internal utils;
    Web3BridgeCXIPool internal pool;
    address payable internal attacker;
    uint256 public attackerInitialEthBalance;
    Attacker internal attackerContract; // added

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        attacker = users[0];
        vm.label(attacker, "Attacker");

        pool = new Web3BridgeCXIPool();
        vm.label(address(pool), "Web3 Bridge Lender Pool");

        vm.deal(address(pool), ETHER_IN_POOL);

        assertEq(address(pool).balance, ETHER_IN_POOL);

        attackerInitialEthBalance = address(attacker).balance;

        console.log(unicode"🧨 Let's see if you can break it... 🧨");
    }

    function testExploit() public {
        
        vm.startPrank(attacker);

        
        attackerContract = new Attacker(address(pool));

       
        attackerContract.initiateFlashLoan();

        
        attackerContract.withdraw();

        vm.stopPrank();

        
        validation();
        console.log(unicode"\n🎉 Congratulations, you have solved it! 🎉");
    }

    function validation() internal view {
        assertEq(address(pool).balance, 0);
        assertGt(attacker.balance, attackerInitialEthBalance);
    }
}