// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MathUtils.sol";

contract NumberProcessor {
    using MathUtils for uint256;
    
    address public owner;
    uint256 public lastProcessedNumber;
    bool public isProcessingEnabled;
    
    // Events
    event NumberProcessed(uint256 number, bool isEven, uint256 timestamp);
    event ProcessingToggled(bool status);
    
    constructor() {
        owner = msg.sender;
        isProcessingEnabled = true;
    }
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier processingEnabled() {
        require(isProcessingEnabled, "Processing is currently disabled");
        _;
    }
    
    modifier validNumber(uint256 number) {
        require(number > 0, "Number must be greater than zero");
        require(number < 1000, "Number must be less than 1000");
        _;
    }
    
    // Function to toggle processing status
    function toggleProcessing() external onlyOwner {
        isProcessingEnabled = !isProcessingEnabled;
        emit ProcessingToggled(isProcessingEnabled);
    }
    
    // Function that uses the library and is controlled by modifiers
    function processNumber(uint256 number) 
        external 
        processingEnabled 
        validNumber(number) 
        returns (bool, uint256) 
    {
        bool isEven = number.isEven();
        uint256 powerOfTwo = number.power(2);
        
        lastProcessedNumber = number;
        emit NumberProcessed(number, isEven, block.timestamp);
        
        return (isEven, powerOfTwo);
    }
    
    // Function to find maximum of two numbers using library
    function findMaximum(uint256 a, uint256 b) 
        external 
        pure 
        returns (uint256) 
    {
        return MathUtils.max(a, b);
    }
} 