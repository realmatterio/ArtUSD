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

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtCredentialNFT is ERC721URIStorage, Ownable {
    uint256 public tokenIdCounter;

    event CredentialIssued(address indexed to, uint256 tokenId, string metadataURI);

    constructor(address initialOwner) ERC721("ArtCredentialNFT", "ACN") Ownable(initialOwner) {
        tokenIdCounter = 0;
    }

    function mint(address to, string memory uri) external onlyOwner {
        _safeMint(to, tokenIdCounter);
        _setTokenURI(tokenIdCounter, uri);
        tokenIdCounter++;
    }

    function issueCredential(address to, string memory uri) external onlyOwner {
        _safeMint(to, tokenIdCounter);
        _setTokenURI(tokenIdCounter, uri);
        emit CredentialIssued(to, tokenIdCounter, uri);
        tokenIdCounter++;
    }
}