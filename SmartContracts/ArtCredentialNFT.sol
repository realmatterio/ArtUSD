
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtCredentialNFT is ERC721, Ownable {
    uint256 public tokenIdCounter;
    mapping(uint256 => string) public artDetails;

    event CredentialIssued(address indexed to, uint256 tokenId, string artDetails);

    constructor(address initialOwner) ERC721("ArtCredentialNFT", "ACN")  Ownable(initialOwner) {
        tokenIdCounter = 0;
    }

    function mint(address to) external onlyOwner {
        _safeMint(to, tokenIdCounter);
        tokenIdCounter++;
    }

    function issueCredential(address to, string memory details) external onlyOwner {
        _safeMint(to, tokenIdCounter);
        artDetails[tokenIdCounter] = details;
        emit CredentialIssued(to, tokenIdCounter, details);
        tokenIdCounter++;
    }
}