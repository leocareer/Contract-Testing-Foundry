// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import "src/SubscriptionAdmin.sol";

contract SubscriptionAdminTest is Test {
    SubscriptionAdmin public admin;
    address public owner = address(0xABCD);
    address public registry = address(0x123);
    address public payment = address(0x456);
    address public newRegistry = address(0x789);
    address public newPayment = address(0x101);
    address public adminUser = address(0x111);
    address public attacker = address(0xBAD);

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event Paused();
    event Unpaused();
    event AddressesUpdated(address newRegistry, address newPayment);

    function setUp() public {
        vm.prank(owner);
        admin = new SubscriptionAdmin(registry, payment);
    }

    function testAddAdmin_Success() public {
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit AdminAdded(adminUser);
        admin.addAdmin(adminUser);
        assertTrue(admin.isAdmin(adminUser));
    }

    function testAddAdmin_FailsIfNotOwner() public {
        vm.prank(attacker);
        vm.expectRevert("Not owner");
        admin.addAdmin(attacker);
    }

    function testRemoveAdmin_Success() public {
        vm.prank(owner);
        admin.addAdmin(adminUser);
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit AdminRemoved(adminUser);
        admin.removeAdmin(adminUser);
        assertFalse(admin.isAdmin(adminUser));
    }

    function testRemoveAdmin_FailsIfNotOwner() public {
        vm.prank(owner);
        admin.addAdmin(adminUser);
        vm.prank(attacker);
        vm.expectRevert("Not owner");
        admin.removeAdmin(adminUser);
    }

    function testSetPause_SuccessByOwner() public {
        vm.prank(owner);
        vm.expectEmit();
        emit Paused();
        admin.setPause();
        assertTrue(admin.paused());
    }

    function testSetPause_SuccessByAdmin() public {
        vm.prank(owner);
        admin.addAdmin(adminUser);
        vm.prank(adminUser);
        vm.expectEmit();
        emit Paused();
        admin.setPause();
        assertTrue(admin.paused());
    }

    function testSetPause_FailsIfNotAdmin() public {
        vm.prank(attacker);
        vm.expectRevert("Not admin");
        admin.setPause();
    }

    function testSetUnpause_SuccessByAdmin() public {
        vm.prank(owner);
        admin.addAdmin(adminUser);
        vm.prank(adminUser);
        admin.setPause();
        assertTrue(admin.paused());
        vm.prank(adminUser);
        vm.expectEmit();
        emit Unpaused();
        admin.setUnpause();
        assertFalse(admin.paused());
    }

    function testUpdateAddresses_Success() public {
        vm.prank(owner);
        vm.expectEmit(true, true, false, false);
        emit AddressesUpdated(newRegistry, newPayment);
        admin.updateAddresses(newRegistry, newPayment);
        assertEq(admin.registry(), newRegistry);
        assertEq(admin.payment(), newPayment);
    }

    function testUpdateAddresses_FailsIfNotOwner() public {
        vm.prank(attacker);
        vm.expectRevert("Not owner");
        admin.updateAddresses(newRegistry, newPayment);
    }

    function testUpdateAddresses_FailsOnZeroRegistry() public {
        vm.prank(owner);
        vm.expectRevert("Invalid registry");
        admin.updateAddresses(address(0), newPayment);
    }

    function testUpdateAddresses_FailsOnZeroPayment() public {
        vm.prank(owner);
        vm.expectRevert("Invalid payment");
        admin.updateAddresses(newRegistry, address(0));
    }

    function testConstructor_FailsOnZeroRegistry() public {
        vm.expectRevert("Invalid registry");
        new SubscriptionAdmin(address(0), payment);
    }

    function testConstructor_FailsOnZeroPayment() public {
        vm.expectRevert("Invalid payment");
        new SubscriptionAdmin(registry, address(0));
    }
}