// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library MathUtils {
    // Function to check if a number is even
    function isEven(uint256 number) public pure returns (bool) {
        return number % 2 == 0;
    }
    
    // Function to find the maximum between two numbers
    function max(uint256 a, uint256 b) public pure returns (uint256) {
        return a >= b ? a : b;
    }
    
    // Function to calculate power of a number
    function power(uint256 base, uint256 exponent) public pure returns (uint256) {
        if (exponent == 0) return 1;
        if (base == 0) return 0;
        
        uint256 result = 1;
        for(uint256 i = 0; i < exponent; i++) {
            result *= base;
        }
        return result;
    }
} 