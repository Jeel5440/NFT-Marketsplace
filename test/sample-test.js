
describe("NFTMarket", function() {
  it("Should create and execute market sales", async function() {
    /* deploy the marketplace */
    const NFTMarketplace = await ethers.getContractFactory("NFTMarket")
    const nftMarketplace = await NFTMarketplace.deploy()
    await nftMarketplace.deployed()
	const NFT = await ethers.getContractFactory("NFT");
	  console.log(nftMarketplace.address)
	  const nftContract = await NFT.deploy(nftMarketplace.address);
	  await nftContract.deployed()

    let listingPrice = await nftMarketplace.getListingPrice()
    listingPrice = listingPrice.toString()

    const auctionPrice = ethers.utils.parseUnits('1', 'ether')

    /* create two tokens */
    await nftContract.createToken("https://www.mytokenlocation.com")
    await nftContract.createToken("https://www.mytokenlocation2.com")

    const [_, buyerAddress] = await ethers.getSigners()
    /* execute sale of token to another user */
    console.log(auctionPrice)	  
    await nftMarketplace.connect(buyerAddress).createMarketSale(1, { value: auctionPrice })
	console.log("R")
    /* resell a token */
    await nftMarketplace.connect(buyerAddress).resellToken(1, auctionPrice, { value: listingPrice })

    /* query for and return the unsold items */
    items = await nftMarketplace.fetchMarketItems()
    items = await Promise.all(items.map(async i => {
      const tokenUri = await nftMarketplace.tokenURI(i.tokenId)
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
