// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

// Contains information about user subscriptions
contract SubscriptionRegistry {

    address public manager;  // Сontract that has the right to renew subscriptions (manager)
    uint256 public defaultDuration;  // Subscription duration (seconds) by default
    mapping(address => uint256) public subscriptionEnd;  // Subscription expiration date at the user's address
    event SubscriptionUpdated(address indexed client, uint256 newEndTime);  // Subscription has been updated

    // Allows a call only to the manager
    modifier onlyManager() {
        require(msg.sender == manager, "Not authorized");
        _;
    }

    constructor(address _manager, uint256 _defaultDuration) {
        require(_manager != address(0), "Manager address cannot be zero");
        require(_defaultDuration > 0, "Duration must be > 0");
        manager = _manager;
        defaultDuration = _defaultDuration;
    }

    // Returns "true" if the user's subscription is active
    function isActive(address _client) external view returns (bool) {
        return subscriptionEnd[_client] >= block.timestamp;
    }

    // Sets subscription starting from the current date or extends the current one
    function renewSubscription(address _client) external onlyManager {
        uint256 currentEnd = subscriptionEnd[_client];
        uint256 startTime = currentEnd > block.timestamp ? currentEnd : block.timestamp;
        subscriptionEnd[_client] = startTime + defaultDuration;
        emit SubscriptionUpdated(_client, subscriptionEnd[_client]);
    }

    // Changes the manager
    function setManager(address _newManager) external onlyManager {
        require(_newManager != address(0), "Manager cannot be zero");
        manager = _newManager;
    }

    // Allows the manager to manually set the subscription end date.
    function forceSetSubscription(address _client, uint256 _endTime) external onlyManager {
        subscriptionEnd[_client] = _endTime;
        emit SubscriptionUpdated(_client, _endTime);
    }
}
