// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {AccessControlUpgradeable} from '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
import {UUPSUpgradeable} from '@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol';

/// @title Upgradeable Access Control Contract for Admin Role Management
/// @dev Provides a simple admin-only role management interface with upgradeability support
contract AccessControl is AccessControlUpgradeable, UUPSUpgradeable {

    /// @notice Checks if an address has the admin role
    /// @param user The address to check for the admin role
    /// @return True if the address has the DEFAULT_ADMIN_ROLE, otherwise false
    function isAdmin(address user) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, user);
    }

    /// @notice Grants or revokes the admin role for a user
    /// @dev Only callable by an existing admin
    /// @param user The address to grant or revoke the admin role
    /// @param grant If true, grants the role; if false, revokes it
    function manageRole(address user, bool grant) public {
        require(isAdmin(msg.sender), 'AccessControl: Only admin');
        if (grant)
            _grantAdminRole(user);
        else
            require(
                _revokeRole(DEFAULT_ADMIN_ROLE, user),
                "AccessControl: failed to revoke DEFAULT_ADMIN_ROLE"
            );
    }

    /// @notice Internal helper to grant admin role
    /// @dev Ensures the role is successfully granted
    /// @param user The address to grant the admin role
    function _grantAdminRole(address user) private {
        require(
            _grantRole(DEFAULT_ADMIN_ROLE, user),
            "AccessControl: failed to grant DEFAULT_ADMIN_ROLE"
        );
    }

    /// @notice Authorizes a contract upgrade
    /// @dev Only callable by an admin; required by UUPSUpgradeable
    function _authorizeUpgrade(address /*newImplementation*/) internal view override {
        require(isAdmin(msg.sender), "AccessControl: Only admin can upgrade");
    }

    /// @notice Initializes the contract and grants the deployer the default admin role
    /// @dev Required initializer for upgradeable contracts; replaces constructor
    function initialize() public virtual initializer {
        __AccessControl_init();
        require(
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "AccessControl: failed to grant DEFAULT_ADMIN_ROLE"
        );
    }
}