// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentHandler {
    // Events
    event PaymentReceived(address indexed from, uint256 amount, string method);
    event PaymentSent(address indexed to, uint256 amount);
    event MinimumDepositUpdated(uint256 newAmount);

    // Constants and immutable variables
    address public immutable owner;
    uint256 public constant MINIMUM_DEPOSIT_DENOMINATOR = 100; // For 0.01 ETH minimum
    
    // State variables - using uint96 to pack with address (160 bits) in same slot
    uint96 public totalReceived;
    uint96 public minimumDeposit;
    
    // Mapping for deposits - optimized for gas by using uint96
    mapping(address => uint96) public deposits;

    constructor() {
        owner = msg.sender;
        minimumDeposit = 0.01 ether > type(uint96).max ? type(uint96).max : uint96(0.01 ether);
    }

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier meetsMinimumDeposit() {
        require(msg.value >= minimumDeposit, "Amount below minimum deposit");
        _;
    }

    // Receive function - Called when plain ETH is sent to the contract
    receive() external payable meetsMinimumDeposit {
        _handleDeposit("receive");
    }

    // Fallback function - Called when msg.data is not empty or receive() doesn't exist
    fallback() external payable {
        _handleDeposit("fallback");
    }

    // Explicit payable function with additional logic
    function deposit() external payable meetsMinimumDeposit {
        _handleDeposit("deposit");
    }

    // Internal function to handle deposits - reduces code duplication and gas
    function _handleDeposit(string memory method) internal {
        // Check that the deposit won't overflow uint96
        require(msg.value <= type(uint96).max, "Deposit too large");
        
        unchecked {
            // Safe to use unchecked as we've verified the value is within uint96 range
            deposits[msg.sender] += uint96(msg.value);
            totalReceived += uint96(msg.value);
        }
        
        emit PaymentReceived(msg.sender, msg.value, method);
    }

    // Function to withdraw funds (only owner)
    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient contract balance");
        
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Transfer failed");
        
        emit PaymentSent(owner, amount);
    }

    // Function to check contract's balance - view functions don't cost gas when called externally
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Function to check specific address's deposits
    function getDeposits(address depositor) external view returns (uint96) {
        return deposits[depositor];
    }

    // Function to update minimum deposit
    function updateMinimumDeposit(uint96 newAmount) external onlyOwner {
        minimumDeposit = newAmount;
        emit MinimumDepositUpdated(newAmount);
    }
} 