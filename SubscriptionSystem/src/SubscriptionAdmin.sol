// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

// Subscription system management: roles, pause, contract addresses
contract SubscriptionAdmin {

    address public owner;
    address public registry;
    address public payment;
    bool public paused;
    mapping(address => bool) public isAdmin; // List of admins

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event Paused();
    event Unpaused();
    event AddressesUpdated(address newRegistry, address newPayment);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender] || msg.sender == owner, "Not admin");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "System paused");
        _;
    }

    constructor(address _registry, address _payment) {
        require(_registry != address(0), "Invalid registry");
        require(_payment != address(0), "Invalid payment");
        owner = msg.sender;
        registry = _registry;
        payment = _payment;
    }

    function addAdmin(address _newAdmin) external onlyOwner {
        require(_newAdmin != address(0), "Zero address");
        isAdmin[_newAdmin] = true;
        emit AdminAdded(_newAdmin);
    }

    function removeAdmin(address _adminToRemove) external onlyOwner {
        isAdmin[_adminToRemove] = false;
        emit AdminRemoved(_adminToRemove);
    }

    function setPause() external onlyAdmin {
        paused = true;
        emit Paused();
    }

    function setUnpause() external onlyAdmin {
        paused = false;
        emit Unpaused();
    }

    function updateAddresses(address _newRegistry, address _newPayment) external onlyOwner {
        require(_newRegistry != address(0), "Invalid registry");
        require(_newPayment != address(0), "Invalid payment");
        registry = _newRegistry;
        payment = _newPayment;
        emit AddressesUpdated(_newRegistry, _newPayment);
    }
}
