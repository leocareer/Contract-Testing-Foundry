### Smart Contracts Testing for Subscription System

This project implements and tests a subscription-based system using smart contracts written in Solidity. It includes ownership, access control, subscription payment management, and administrative controls. The tests are also written in Solidity in the Foundry framework.

### Structure

- `/src:`
  - `SubscriptionAdmin.sol:` Provides administrative control over the system. Supports pausing/unpausing the system, managing admins, and updating connected contract addresses;
  - `SubscriptionPayment.sol:` Handles subscription purchases by accepting Ether and calling the registry to renew the subscription;
  - `SubscriptionRegistry.sol:` Tracks and manages subscription states for users, handles renewal logic and subscription durations;

- `/test:`
  - `SubscriptionAdmin.t.sol:` Tests for SubscriptionAdmin.sol contract;
  - `SubscriptionPayment.t.sol:` Tests for SubscriptionPayment.sol contract;
  - `SubscriptionRegistry.t.sol:` Tests for SubscriptionRegistry.sol contract;

- `/foundry.toml:` Config

### Stack

- Solidity 0.8.29
- Foundry 1.1.0

### Test coverage

- Ownership and admin restrictions
- Event emissions
- Edge cases (zero address, unauthorized access)
- Payment and withdrawal flow

![Coverage](https://github.com/leocareer/Contract-Testing-Foundry/blob/main/coverage.png)