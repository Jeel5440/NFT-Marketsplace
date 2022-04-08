const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarket", function () {
  it("Should create and execute the sales", async function () {
    //next we get a reference to the contract
    const Market = await ethers.getContractFactory("NFTMarket")
    //now we ahve to wait for contract deployment
    const market = await Market.deploy()
    await market.deployed()
    //get a reference of contract address
    const marketAddress = market.address

    //now we get a reference to the nft contract
    const NFT = await ethers.getContractFactory("NFT")
    const nft  = await NFT.deploy(marketAddress)
    await nft.deployed()
    //referencee of nft contract address
    const nftContractAddress = nft.address

    //now we are going to intrect with the contract
    let listingPrice = await market.getListingPrice()
    listingPrice = listingPrice.toString()

    const auctionPrice = ethers.utils.parseUnits('100', 'ether')

    /* create two tokens */
    await nft.createToken("https://www.mytokenlocation.com")
    await nft.createToken("https://www.mytokenlocation2.com")

    await market.createMarketItem(nftContractAddress, 1,auctionPrice, {value: listingPrice})
    await market.createMarketItem(nftContractAddress, 2,auctionPrice, {value: listingPrice})


    const [_, buyerAddress] = await ethers.getSigners()

    /* execute sale of token to another user */
    await market.connect(buyerAddress).createMarketSale(nftContractAddress,1, { value: auctionPrice })

    /* query for and return the unsold items */
    items = await market.fetchMarketItems()

    //Promise.all this is giving asynchronisation mapping
    items = await Promise.all(items.map(async i => {
      const tokenUri = await nft.tokenURI(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      }
      return item
    }))
    console.log('items: ', items)
  });
});
