// SPDX-License-Identifier: MIT
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