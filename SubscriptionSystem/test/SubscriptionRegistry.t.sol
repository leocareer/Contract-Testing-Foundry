// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import "../src/SubscriptionRegistry.sol";

contract SubscriptionRegistryTest is Test {

    SubscriptionRegistry registry;
    address manager = address(1);
    address client = address(2);
    uint256 constant DURATION = 30 days;

    function setUp() public {
        vm.prank(manager);
        registry = new SubscriptionRegistry(manager, DURATION);
    }

    function testConstructorSets() public view {
        assertEq(registry.manager(), manager);
        assertEq(registry.defaultDuration(), DURATION);
    }

    function testRenewSubscription_WhenNoPrevious() public {
        vm.warp(1000);  // timestamp = 1000
        vm.prank(manager);
        registry.renewSubscription(client);
        assertEq(registry.subscriptionEnd(client), 1000 + DURATION);
    }

    function testRenewSubscription_WhenAlreadyActive() public {
        vm.warp(1000);
        vm.prank(manager);
        registry.renewSubscription(client); // 1000 + DURATION
        vm.warp(1500); // The time is shifting, but the subscription is still active
        vm.prank(manager);
        registry.renewSubscription(client);
        assertEq(registry.subscriptionEnd(client), 1000 + DURATION * 2);
    }

    function testRenewSubscription_WhenExpired() public {
        vm.warp(1000);
        vm.prank(manager);
        registry.renewSubscription(client);
        vm.warp(1000 + DURATION + 1);
        vm.prank(manager);
        registry.renewSubscription(client);
        assertEq(registry.subscriptionEnd(client), block.timestamp + DURATION);
    }

    function testIsActive() public {
        vm.warp(5000);
        assertFalse(registry.isActive(client));
        vm.prank(manager);
        registry.renewSubscription(client);
        assertTrue(registry.isActive(client));
    }

    function testForceSetSubscription() public {
        uint256 customTime = 9999;
        vm.prank(manager);
        registry.forceSetSubscription(client, customTime);
        assertEq(registry.subscriptionEnd(client), customTime);
    }

    function testSetManager() public {
        address newManager = address(3);
        vm.prank(manager);
        registry.setManager(newManager);
        assertEq(registry.manager(), newManager);
    }

    function testOnlyManagerFails() public {
        vm.expectRevert("Not authorized");  // Without vm.prank, default msg.sender address(this), not a manager
        registry.renewSubscription(client);
        vm.expectRevert("Not authorized");
        registry.forceSetSubscription(client, 1234);
        vm.expectRevert("Not authorized");
        registry.setManager(address(3));
    }
}
