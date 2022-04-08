// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
/*it is an security mechanism it is going to kind of protect certain transactions that are actually talking to a seprate contract prevent 
multiple transaction*/
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard{
    using Counters for Counters.Counter;

//set counter for tokens and no of items sold
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    //create variable for owner of the contract
    address payable owner;
    //now we are set a lising fees for list an item on marketplace
    uint256 listingPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    //next we have to define struct for all market items
    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;        
    }
    //for fetch individual marketitem using marketid we are providing mapping
    mapping(uint256 => MarketItem) private idToMarketItem;

    //next we are creating event an its match market item itself
    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address payable seller,
        address payable owner,
        uint256 price,
        bool sold
    );
    //next we are making function that returns listing price
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createMarketItem(
        address nftContract,
        uint256  tokenId,
        uint256 price
        //we are using nonReentrant because we want to prevent a re-entry attack
    ) public payable nonReentrant{
        /*first we are require a condition the condition is price must be greater then zero so we don't want anyone to 
        listing something free */
        require(price > 0, "Price must be atleast 1 wei");
        /*we also require usersending transaction is must be passing listingPrice */        
        require(msg.value==listingPrice, "Price must be equal to the listing price");

        //increament in itemids
        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        //next we are creating our mapping
        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );
        //now we have to transfer nft ownership to the contract
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            //i think error in next to line
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );
    }

    function createMarketSale(
        address nftContract,
        uint256  itemId
        //we are using nonReentrant because we want to prevent a re-entry attack
    ) public payable nonReentrant{
        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;
        //create requirment for submit asking price to complete the purchase
        require(msg.value==price, "Please submit the asking price in order to completee the purchase");
        //transfer value to seller's account
        idToMarketItem[itemId].seller.transfer(msg.value);
        //transfer ownership to the msg.sender
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        //using mapping we increament item sold
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();
        //transfer lisiting price to the owner
        payable(owner).transfer(listingPrice);
    }

    //function that return unsold item fetching marketitem
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        //create variable item count and this is giving total created
        uint itemCount = _itemIds.current();
        //create variable for unsold item count
        uint unSoldItemCount = _itemIds.current() - _itemsSold.current();
        // we create an array for unsold item using find empty address
        uint currentIndex = 0;

        //create an empty array
        MarketItem[] memory items = new MarketItem[](unSoldItemCount);

        //create loop
        for (uint i = 0; i<itemCount;i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                //create variable for detect current id
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem =  idToMarketItem[currentId];
                //insert items in the array 
                items[currentIndex] = currentItem;
                //increament current index 
                currentIndex +=1;
            }
        }
        return items;
    }
    //fetch that nft user purchase itself
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
      uint totalItemCount = _itemIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
          itemCount += 1;
        }
      }

        MarketItem[] memory items = new MarketItem[](itemCount);
         for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
            uint currentId = idToMarketItem[i + 1].itemId;
            MarketItem storage currentItem =  idToMarketItem[currentId];
            //insert items in the array 
            items[currentIndex] = currentItem;
            //increament current index 
            currentIndex +=1;
            }
        }
        return items;
    }
    //fetch item created by user itself
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
      uint totalItemCount = _itemIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          itemCount += 1;
        }
      }
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem =  idToMarketItem[currentId];
                //insert items in the array 
                items[currentIndex] = currentItem;
                //increament current index 
                currentIndex +=1;
        }
      }
      return items;
      
    }
}