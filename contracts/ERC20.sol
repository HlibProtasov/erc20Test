// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {AccessControl} from './AccessControl.sol';
import {UUPSUpgradeable} from '@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol';
import {ERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';


/// @title Upgradeable ERC20 Token with Admin-Controlled Minting and Burning
/// @notice This ERC20 token allows only administrators to mint, burn, and upgrade the contract
contract ERC20 is ERC20Upgradeable, UUPSUpgradeable {
    AccessControl private _accessControl;


    /// @notice Mints new tokens to a specified address
    /// @dev Only callable by an admin as defined in the AccessControl contract
    /// @param to The address that will receive the newly minted tokens
    /// @param amount The number of tokens to mint
    function mint(address to, uint256 amount) public {
        require(_accessControl.isAdmin(msg.sender), 'ERC20: Only admin can mint');
        _mint(to, amount);
    }


    /// @notice Burns tokens from a specified address
    /// @dev Only callable by an admin as defined in the AccessControl contract
    /// @param from The address from which tokens will be burned
    /// @param amount The number of tokens to burn
    function burn(address from, uint256 amount) public {
        require(_accessControl.isAdmin(msg.sender), 'ERC20: Only admin can burn');
        _burn(from, amount);
    }

    /// @notice Authorizes contract upgrades
    /// @dev Only callable by an admin
    function _authorizeUpgrade(address /*newImplementation*/) internal override view {
        require(_accessControl.isAdmin(msg.sender), 'ERC20: Only admin can upgrade');
    }


    /// @notice Initializes the token with a name, symbol, and access control contract address
    /// @dev This function replaces the constructor for upgradeable contracts
    /// @param name The name of the token
    /// @param symbol The symbol of the token
    /// @param accessControl The address of the deployed AccessControl contract
    function initialize(string memory name, string memory symbol, address accessControl) public initializer {
        __ERC20_init(name, symbol);
        _accessControl = AccessControl(accessControl);
    }

}