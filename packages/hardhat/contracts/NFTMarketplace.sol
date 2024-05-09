// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721Enumerable, Ownable {
    // Mapping from token ID to price
    mapping(uint256 => uint256) private _tokenPrices;

    // Mapping from token ID to seller address
    mapping(uint256 => address) private _tokenSellers;

    // Events
    event TokenListed(address indexed seller, uint256 indexed tokenId, uint256 price);
    event TokenSold(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 price);

    // Constructor
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    // List a token for sale
    function listToken(uint256 tokenId, uint256 price) external {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "Caller is not the token owner");
        
        _tokenPrices[tokenId] = price;
        _tokenSellers[tokenId] = msg.sender;
        
        emit TokenListed(msg.sender, tokenId, price);
    }

    // Buy a token
    function buyToken(uint256 tokenId) external payable {
        require(_exists(tokenId), "Token does not exist");
        address seller = _tokenSellers[tokenId];
        require(seller != address(0), "Token is not listed for sale");
        uint256 price = _tokenPrices[tokenId];
        require(msg.value >= price, "Insufficient funds");

        _transfer(seller, msg.sender, tokenId);
        delete _tokenPrices[tokenId];
        delete _tokenSellers[tokenId];

        (bool success, ) = seller.call{value: price}("");
        require(success, "Transfer failed");

        emit TokenSold(seller, msg.sender, tokenId, price);
    }

    // Get the price of a token
    function getTokenPrice(uint256 tokenId) external view returns (uint256) {
        return _tokenPrices[tokenId];
    }

    // Get the seller of a token
    function getTokenSeller(uint256 tokenId) external view returns (address) {
        return _tokenSellers[tokenId];
    }
}