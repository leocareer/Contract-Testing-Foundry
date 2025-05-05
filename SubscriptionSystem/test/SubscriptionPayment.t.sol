// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import "../src/SubscriptionPayment.sol";

// A test contract to replace the real SubscriptionRegistry
// Saves the address of the last user who called renewSubscription for verification in tests
contract MockSubscriptionRegistry {
    address public lastClient;

    function renewSubscription(address client) external {
        lastClient = client;
    }
}

contract SubscriptionPaymentTest is Test {
    SubscriptionPayment payment;
    MockSubscriptionRegistry registry;
    address owner;

    address public client = address(1);
    uint256 public price = 1 ether;

    event SubscriptionPurchased(address indexed client, uint256 value);
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);
    event RegistryUpdated(address oldRegistry, address newRegistry);

    function setUp() public {
        owner = address(0xABCD);
        registry = new MockSubscriptionRegistry();

        vm.prank(owner);
        payment = new SubscriptionPayment(address(registry), 1 ether);

        vm.deal(owner, 5 ether);
    }

    function testBuySubscription_Success() public {
        vm.prank(client);
        vm.deal(client, 2 ether);  // Sending a payment greater than or equal to the price
        vm.expectEmit(true, false, false, true);
        emit SubscriptionPurchased(client, price);
        payment.buySubscription{value: price}();
        assertEq(registry.lastClient(), client);  // Checking that the subscription is activated
    }

    function testBuySubscription_FailsOnInsufficientPayment() public {
        vm.prank(client);
        vm.deal(client, 0.5 ether);  // Sending a payment less than the price
        vm.expectRevert("Insufficient payment");  // Checking the revert with this message
        payment.buySubscription{value: 0.5 ether}();
    }

    function testSetPrice_Success() public {
        uint256 newPrice = 2 ether;
        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit PriceUpdated(1 ether, newPrice);
        payment.setPrice(newPrice);
        assertEq(payment.price(), newPrice); // Checking that the price has been updated
    }

    function testSetPrice_FailsOnZero() public {
        vm.prank(owner);
        vm.expectRevert("Price must be > 0");
        payment.setPrice(0);
    }

    function testSetRegistry_Success() public {
        address newRegistry = address(0x123);
        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit RegistryUpdated(address(registry), newRegistry);
        payment.setRegistry(newRegistry);
        assertEq(address(payment.registry()), newRegistry);  // Checking that the address has been updated
    }

    function testSetRegistry_FailsOnZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert("Registry cannot be zero");
        payment.setRegistry(address(0));  // Expecting an error, since the address cannot be null
    }

    function testOnlyOwnerFunctions_RevertForNonOwner() public {
        vm.prank(client);
        vm.expectRevert("Not owner");
        payment.setPrice(2 ether);

        vm.prank(client);
        vm.expectRevert("Not owner");
        payment.setRegistry(address(registry));

        vm.prank(client);
        vm.expectRevert("Not owner");
        payment.withdraw();
    }

    function testWithdraw_Success() public {
        address otherClient = address(0xBEEF);
        vm.deal(otherClient, 1 ether);

        vm.prank(otherClient);
        payment.buySubscription{value: 1 ether}();

        assertEq(address(payment).balance, 1 ether);  // Checking that the contract has actually received 1 ether

        uint256 balanceBefore = owner.balance;

        vm.prank(owner); // вот тут owner из переменной контракта
        payment.withdraw();

        uint256 balanceAfter = owner.balance;

        assertGt(balanceAfter, balanceBefore);  // Checking that the balance has increased
        assertEq(address(payment).balance, 0);  // Checking that there are no more funds on the contract balance
    }
}
