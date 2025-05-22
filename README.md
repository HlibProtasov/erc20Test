# 🪙 Upgradeable ERC20 Token with External Access Control

This project contains two upgradeable smart contracts:

- **AccessControl**: A minimal standalone admin role management contract.
- **ERC20**: A custom ERC20 token contract that uses the external `AccessControl` contract to manage permissions for minting, burning, and upgrading.

---

## 📄 Contracts Overview

### `AccessControl.sol`

A lightweight access control contract responsible for managing admin roles. This contract is intended to be reused by multiple contracts requiring admin-based permissioning.

**Features:**
- Upgradeable via UUPS.
- Allows assigning and revoking admin roles.
- Restricts access to admin-only functions.

### `ERC20.sol`

An upgradeable ERC20 token that delegates access control to the `AccessControl` contract.

**Features:**
- Upgradeable via UUPS.
- Only admins (as defined in `AccessControl`) can:
  - Mint tokens
  - Burn tokens
  - Upgrade the contract
- Initialization requires providing a name, symbol, and the address of a deployed `AccessControl` contract.

> 🔐 **Note**: All access control logic is separated and delegated to the external `AccessControl` contract for modularity and reusability.

---

## 🧪 Tests

Tests are written using Hardhat, Ethers.js, and Chai.

### Run Tests

```bash
npm install
npx hardhat test