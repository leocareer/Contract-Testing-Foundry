// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./SubscriptionRegistry.sol";

// Manages the purchase of a subscription and calls the registry
contract SubscriptionPayment {

    address public owner;
    uint256 public price;  // Subscription price in WEI
    SubscriptionRegistry public registry;

    event SubscriptionPurchased(address indexed user, uint256 value);  // Successful payment
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);  // New price
    event RegistryUpdated(address oldRegistry, address newRegistry);  // New SubscriptionRegistry

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _registry, uint256 _price) {
        require(_registry != address(0), "Registry cannot be zero");
        require(_price > 0, "Price must be > 0");
        owner = msg.sender;
        registry = SubscriptionRegistry(_registry);
        price = _price;
    }

    function buySubscription() external payable {
        require(msg.value >= price, "Insufficient payment");
        registry.renewSubscription(msg.sender);
        emit SubscriptionPurchased(msg.sender, msg.value);
    }

    function setPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice > 0, "Price must be > 0");
        emit PriceUpdated(price, _newPrice);
        price = _newPrice;
    }

    function setRegistry(address _newRegistry) external onlyOwner {
        require(_newRegistry != address(0), "Registry cannot be zero");
        emit RegistryUpdated(address(registry), _newRegistry);
        registry = SubscriptionRegistry(_newRegistry);
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}