// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {AccessControlUpgradeable} from '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
import {UUPSUpgradeable} from '@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol';
import {ERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';

bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 constant BURNER_ROLE = keccak256("BURNER_ROLE");
bytes32 constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");

bytes32 constant FREEZE_ROLE = keccak256("FREEZE_ROLE");

bytes32 constant StorageAddress = keccak256("FREEZE_ROLE");


/// @title Upgradeable ERC20 Token with Admin-Controlled Minting and Burning
/// @notice This ERC20 token allows only administrators to mint, burn, and upgrade the contract
contract ERC20 is ERC20Upgradeable, UUPSUpgradeable, AccessControlUpgradeable {
  
  /// keccak256('erc20.frozen.storage')
  bytes32 private constant ERC20FrozenStorage = 0x7c4e55af7ca6aff6469db4449710dda4adcf6ad6ebbdeaf3d2080aa1ba020f61;
 
   struct FrozeData {
        mapping(address => uint) frozenBalances;
    }


 function _getERC20FrozenStorage() private pure returns (FrozeData storage s) {
        assembly {
            s.slot := ERC20FrozenStorage
        }
    }


  
    function freezeBalance(address account, uint amount) public onlyRole(FREEZE_ROLE) {
        require(balanceOf(account) >= amount, "Insufficient balance to freeze");
        FrozeData storage frozenData = _getERC20FrozenStorage();
        frozenData.frozenBalances[account] += amount;
    }

   function _update(address from, address to, uint256 value) internal override {
        FrozeData storage frozenData = _getERC20FrozenStorage();
        require(balanceOf(from) - frozenData.frozenBalances[from] >= value, "Insufficient balance after freeze");
        super._update(from, to, value);
    }

    function withdrawFrozenBalance(uint amount, address from, address to) public onlyRole(WITHDRAW_ROLE) {
        FrozeData storage frozenData = _getERC20FrozenStorage();
        require(frozenData.frozenBalances[from] >= amount, "Insufficient frozen balance");
        frozenData.frozenBalances[msg.sender] -= amount;
        _transfer(from, to, amount);
    }


    /// @notice Mints new tokens to a specified address
    /// @dev Only callable by an admin as defined in the AccessControl contract
    /// @param to The address that will receive the newly minted tokens
    /// @param amount The number of tokens to mint
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }


    /// @notice Burns tokens from a specified address
    /// @dev Only callable by an admin as defined in the AccessControl contract
    /// @param from The address from which tokens will be burned
    /// @param amount The number of tokens to burn
    function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }

    /// @notice Authorizes contract upgrades
    /// @dev Only callable by an admin
    function _authorizeUpgrade(address /*newImplementation*/) internal override view  onlyRole(DEFAULT_ADMIN_ROLE) {
    }


    /// @notice Initializes the token with a name, symbol, and access control contract address
    /// @dev This function replaces the constructor for upgradeable contracts
    /// @param name The name of the token
    /// @param symbol The symbol of the token
    function initialize(string memory name, string memory symbol) public initializer {
        __ERC20_init(name, symbol);
        __AccessControl_init();
    }

}