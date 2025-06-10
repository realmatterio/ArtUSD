/**
 * License: MIT
 *
 * Copyright (c) 2025 REALMATTER
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Blacklistable
 * @dev Contract that allows addresses to be blacklisted and prevents them from interacting with the contract
 */
contract Blacklistable is Ownable {
    mapping(address => bool) private _blacklisted;

    event Blacklisted(address indexed account);
    event RemovedFromBlacklist(address indexed account);

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @dev Throws if the account is blacklisted
     */
    modifier notBlacklisted(address account) {
        require(!_blacklisted[account], "Blacklistable: account is blacklisted");
        _;
    }

    /**
     * @dev Checks if an account is blacklisted
     * @param account The address to check
     * @return bool True if the account is blacklisted, false otherwise
     */
    function isBlacklisted(address account) public view returns (bool) {
        return _blacklisted[account];
    }

    /**
     * @dev Adds an account to the blacklist
     * @param account The address to blacklist
     */
    function blacklist(address account) external onlyOwner {
        require(!_blacklisted[account], "Blacklistable: account already blacklisted");
        _blacklisted[account] = true;
        emit Blacklisted(account);
    }

    /**
     * @dev Removes an account from the blacklist
     * @param account The address to remove from the blacklist
     */
    function removeFromBlacklist(address account) external onlyOwner {
        require(_blacklisted[account], "Blacklistable: account not blacklisted");
        _blacklisted[account] = false;
        emit RemovedFromBlacklist(account);
    }
}