// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    /*token ids allow us to keep up with an incrementing value for an unique identifier for each token when first token is minted it give value like one and
    second token minted it give like two*/
    Counters.Counter private _tokenIds;
    /*this is an address of marketplace that we want to allow the nft to be able to give the nft market the ability to transact these tokens or change 
    the ownership of the tokens from a seprate contract*/
    address ContractAddress;

    constructor(address marketplaceAddress) ERC721("Metaverse Tokens","METT"){
        ContractAddress = marketplaceAddress;
    }
    //for minting the new tokens 
    function createToken(string memory tokenURI) public returns (uint) {
        //increment tokenids
        _tokenIds.increment();
        //next variable give you the current token id
        uint256 newItemId = _tokenIds.current();
        //next we are going for mint token
        _mint(msg.sender, newItemId);
        //set an actual token uri
        _setTokenURI(newItemId, tokenURI);
        /*set an approval for all passing in the contract address and this is giving approval to marketplace trasact this token between users form within
        another contract*/
        setApprovalForAll(ContractAddress, true);
        return newItemId;
    }
}



