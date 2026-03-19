// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.6.0
pragma solidity ^0.8.27;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20BurnableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {ERC20PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {ERC20VotesUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import {ERC20BridgeableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20BridgeableUpgradeable.sol";
import {NoncesUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/NoncesUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract ArtID is Initializable, ERC20Upgradeable, ERC20BridgeableUpgradeable, AccessControlUpgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable {
    bytes32 public constant TOKEN_BRIDGE_ROLE = keccak256("TOKEN_BRIDGE_ROLE");
    error Unauthorized();
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin, address tokenBridge, address pauser, address minter)
        public
        initializer
    {
        __ERC20_init("Art ID", "ARTID");
        __ERC20Bridgeable_init();
        __AccessControl_init();
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __ERC20Permit_init("Art ID");
        __ERC20Votes_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(TOKEN_BRIDGE_ROLE, tokenBridge);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);
    }

    function _checkTokenBridge(address caller) internal view override {
        if (!hasRole(TOKEN_BRIDGE_ROLE, caller)) revert Unauthorized();
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable, ERC20VotesUpgradeable)
    {
        super._update(from, to, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC20BridgeableUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function nonces(address owner)
        public
        view
        override(ERC20PermitUpgradeable, NoncesUpgradeable)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}

