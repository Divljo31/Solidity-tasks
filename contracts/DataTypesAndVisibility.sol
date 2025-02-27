// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataTypesAndVisibility {
    // State Variables with different visibility
    uint256 public number;
    bool private isActive;
    string internal message;
    address public owner;
    
    // Constants and immutable variables
    uint256 public constant MAX_VALUE = 1000;
    address public immutable deployer;
    
    // Events
    event NumberUpdated(uint256 indexed newValue);
    event MessageUpdated(string newMessage);
    
    constructor(string memory _initialMessage) {
        owner = msg.sender;
        deployer = msg.sender;
        message = _initialMessage;
        isActive = true;
    }
    
    // Public functions - can be called from outside and inside the contract
    function updateNumber(uint256 _newNumber) public {
        require(_newNumber <= MAX_VALUE, "Number exceeds maximum value");
        number = _newNumber;
        emit NumberUpdated(_newNumber);
    }
    
    // Private function - can only be called from inside this contract
    function _validateMessage(string memory _msg) private pure returns (bool) {
        bytes memory msgBytes = bytes(_msg);
        return msgBytes.length > 0;
    }
    
    // Internal function - can be called from this contract and derived contracts
    function _updateMessage(string memory _newMessage) internal {
        require(_validateMessage(_newMessage), "Message cannot be empty");
        message = _newMessage;
        emit MessageUpdated(_newMessage);
    }
    
    // Public view function - reads state but doesn't modify it
    function getMessage() public view returns (string memory) {
        return message;
    }
    
    // Public view function combining multiple state variables
    function getStatus() public view returns (bool, uint256) {
        return (isActive, number);
    }
    
    // Pure function - doesn't read or modify state
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }
    
    // Pure function with multiple return values
    function divide(uint256 numerator, uint256 denominator) 
        public 
        pure 
        returns (uint256 quotient, uint256 remainder) 
    {
        require(denominator > 0, "Cannot divide by zero");
        quotient = numerator / denominator;
        remainder = numerator % denominator;
    }
    
    // Function demonstrating use of address type
    function isOwner(address _address) public view returns (bool) {
        return _address == owner;
    }
} 