// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title SimpleWallet
 * @dev A basic wallet contract that allows deposits, withdrawals, and balance checking
 * @author Simple Wallet Team
 * @notice This contract provides basic wallet functionality with owner controls
 */
contract SimpleWallet {
    // State variables
    address public owner;
    uint256 public balance;
    uint256 public withdrawalLimit;
    
    // Events
    event Deposit(address indexed sender, uint256 amount, uint256 timestamp);
    event Withdrawal(address indexed recipient, uint256 amount, uint256 timestamp);
    event WithdrawalLimitUpdated(uint256 oldLimit, uint256 newLimit);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier validAmount(uint256 _amount) {
        require(_amount > 0, "Amount must be greater than zero");
        _;
    }
    
    modifier sufficientBalance(uint256 _amount) {
        require(balance >= _amount, "Insufficient balance");
        _;
    }
    
    modifier withinLimit(uint256 _amount) {
        require(_amount <= withdrawalLimit, "Amount exceeds withdrawal limit");
        _;
    }
    
    /**
     * @dev Constructor sets the contract deployer as the owner with default withdrawal limit
     * @notice Default withdrawal limit is set to 1 ETH (1e18 wei)
     */
    constructor() {
        owner = msg.sender;
        withdrawalLimit = 1 ether; // Default withdrawal limit of 1 ETH
        balance = 0;
    }
    
    /**
     * @dev Core Function 1: Deposit Ether into the wallet
     * @notice Anyone can deposit Ether into this wallet
     */
    function deposit() public payable validAmount(msg.value) {
        balance += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }
    
    /**
     * @dev Core Function 2: Withdraw Ether from the wallet
     * @param _amount Amount to withdraw in wei
     * @param _recipient Address to send the withdrawn Ether to
     * @notice Only owner can withdraw funds, subject to withdrawal limit
     */
    function withdraw(uint256 _amount, address payable _recipient) 
        public 
        onlyOwner 
        validAmount(_amount) 
        sufficientBalance(_amount) 
        withinLimit(_amount) 
    {
        require(_recipient != address(0), "Invalid recipient address");
        
        balance -= _amount;
        _recipient.transfer(_amount);
        
        emit Withdrawal(_recipient, _amount, block.timestamp);
    }
    
    /**
     * @dev Core Function 3: Check wallet balance
     * @return Current balance of the wallet in wei
     * @notice Public function to check the current wallet balance
     */
    function getBalance() public view returns (uint256) {
        return balance;
    }
    
    /**
     * @dev Set withdrawal limit (only owner)
     * @param _newLimit New withdrawal limit in wei
     */
    function setWithdrawalLimit(uint256 _newLimit) public onlyOwner {
        uint256 oldLimit = withdrawalLimit;
        withdrawalLimit = _newLimit;
        emit WithdrawalLimitUpdated(oldLimit, _newLimit);
    }
    
    /**
     * @dev Transfer ownership to a new owner (only current owner)
     * @param _newOwner Address of the new owner
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner cannot be zero address");
        require(_newOwner != owner, "New owner must be different from current owner");
        
        address previousOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }
    
    /**
     * @dev Emergency withdraw all funds (only owner)
     * @notice Bypasses withdrawal limit in emergency situations
     */
    function emergencyWithdraw() public onlyOwner {
        require(balance > 0, "No funds to withdraw");
        
        uint256 amount = balance;
        balance = 0;
        payable(owner).transfer(amount);
        
        emit Withdrawal(owner, amount, block.timestamp);
    }
    
    /**
     * @dev Get contract information
     * @return owner address, current balance, and withdrawal limit
     */
    function getWalletInfo() public view returns (address, uint256, uint256) {
        return (owner, balance, withdrawalLimit);
    }
    
    /**
     * @dev Fallback function to receive Ether
     * @notice Automatically deposits any Ether sent to the contract
     */
    receive() external payable {
        if (msg.value > 0) {
            deposit();
        }
    }
    
    /**
     * @dev Fallback function for non-existent functions
     */
    fallback() external payable {
        revert("Function does not exist");
    }
}
