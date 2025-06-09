// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtCredentialNFT is ERC721, Ownable {
    uint256 public tokenIdCounter;
    mapping(uint256 => string) public artDetails;

    event CredentialIssued(address indexed to, uint256 tokenId, string metadataURI);

    constructor(address initialOwner) ERC721("ArtCredentialNFT", "ACN") Ownable(initialOwner) {
        tokenIdCounter = 0;
        _setBaseURI("ipfs://");
    }

    function mint(address to, string memory uri) external onlyOwner {
        _safeMint(to, tokenIdCounter);
        artDetails[tokenIdCounter] = uri;
        tokenIdCounter++;
    }

    function issueCredential(address to, string memory uri) external onlyOwner {
        _safeMint(to, tokenIdCounter);
        artDetails[tokenIdCounter] = uri;
        emit CredentialIssued(to, tokenIdCounter, uri);
        tokenIdCounter++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        return string(abi.encodePacked(super.tokenURI(tokenId), artDetails[tokenId]));
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        _setBaseURI(baseURI);
    }
}