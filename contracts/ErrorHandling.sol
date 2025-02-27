// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ErrorHandling {
    uint256 public value;
    mapping(address => uint256) public balances;
    
    // Custom errors (most gas efficient)
    error InsufficientBalance(uint256 available, uint256 required);
    error InvalidValue(string reason);
    error Unauthorized(address caller);
    
    event ValueUpdated(uint256 newValue);
    event Withdrawal(address indexed user, uint256 amount);
    
    constructor() {
        value = 100;
        balances[msg.sender] = 1000;
    }
    
    // Using require() - Good for input validation
    // Gas cost: Medium
    function updateValue(uint256 newValue) public {
        // Basic input validation
        require(newValue > 0, "Value must be positive");
        require(newValue != value, "New value must be different");
        
        value = newValue;
        emit ValueUpdated(newValue);
    }
    
    // Using assert() - Good for invariant checking
    // Gas cost: High (uses all remaining gas if fails)
    function divide(uint256 numerator, uint256 denominator) public pure returns (uint256) {
        // Assert should never fail in normal operation
        assert(denominator != 0);
        return numerator / denominator;
    }
    
    // Using revert() with custom error - Most gas efficient
    // Gas cost: Low
    function withdraw(uint256 amount) public {
        uint256 balance = balances[msg.sender];
        
        if (amount > balance) {
            revert InsufficientBalance({
                available: balance,
                required: amount
            });
        }
        
        balances[msg.sender] -= amount;
        emit Withdrawal(msg.sender, amount);
    }
    
    // Combining different error handling approaches
    function complexOperation(uint256 input) public {
        // 1. Input validation with require
        require(input < 1000, "Input too large");
        
        // 2. Custom error for business logic
        if (input % 2 != 0) {
            revert InvalidValue("Input must be even");
        }
        
        // 3. State validation with assert
        assert(input != 500); // Should never be exactly 500
        
        value = input;
        emit ValueUpdated(input);
    }
    
    // Function to demonstrate unauthorized access
    function adminOperation() public view {
        if (msg.sender != address(this)) {
            revert Unauthorized(msg.sender);
        }
        // Admin operation logic would go here
    }
    
    // View function to check invariants
    function checkInvariants() public view {
        // These assertions verify our contract's invariants
        assert(value > 0); // Value should never be zero
        assert(address(this).balance >= 0); // Balance can't be negative
    }
    
    // Helper function to deposit (for testing)
    function deposit() public payable {
        require(msg.value > 0, "Must send some ether");
        balances[msg.sender] += msg.value;
    }
} 