// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/PaymentHandler.sol";

contract PaymentHandlerTest is Test {
    PaymentHandler public paymentHandler;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        
        paymentHandler = new PaymentHandler();
    }

    function testReceiveFunction() public {
        vm.prank(user1);
        (bool success,) = address(paymentHandler).call{value: 0.05 ether}("");
        assertTrue(success);
        
        assertEq(paymentHandler.getDeposits(user1), 0.05 ether);
        assertEq(paymentHandler.getContractBalance(), 0.05 ether);
    }

    function testDepositFunction() public {
        vm.prank(user1);
        paymentHandler.deposit{value: 0.02 ether}();
        
        assertEq(paymentHandler.getDeposits(user1), 0.02 ether);
    }

    function testFailBelowMinimumDeposit() public {
        vm.prank(user1);
        (bool success,) = address(paymentHandler).call{value: 0.005 ether}("");
        assertTrue(!success);
    }

    function testWithdrawalByOwner() public {
        // First make a deposit
        vm.prank(user1);
        paymentHandler.deposit{value: 0.05 ether}();
        
        uint256 initialBalance = address(this).balance;
        paymentHandler.withdraw(0.05 ether);
        
        assertEq(address(this).balance - initialBalance, 0.05 ether);
    }

    function testFailWithdrawalByNonOwner() public {
        vm.prank(user1);
        paymentHandler.withdraw(0.01 ether);
    }

    receive() external payable {}
} 