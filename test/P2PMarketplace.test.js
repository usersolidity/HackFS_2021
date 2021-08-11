const P2PMarketplace = artifacts.require("./P2PMarketplace.sol")
const NFTStorage = require('nft.storage')
const NFTSTORAGE_API_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweEJFNjAzNjYxMzk2OTg5Rjk5YUU4MURGNzRGY2NFRDQ4YUFGMkYyOGEiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTYyODE5MjE3ODUzMCwibmFtZSI6IkhhY2tGU18yMDIxIn0.8egYuYRc_nmWS-HyEbSYliB2ShACUq2TWEswzcnoOVI'
const nftClient = new NFTStorage.NFTStorage({ token: NFTSTORAGE_API_TOKEN });

require('chai')
  .use(require('chai-as-promised'))
  .should()

contract('P2PMarketplace', (accounts) => {
    let marketplace

    before(async () => {
        marketplace = await P2PMarketplace.deployed()
    })

    describe('deployment', async () => {
        it('deploys successfully', async () => {
            const address = await marketplace.address
            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
        })
    })

    describe('account', async () => {
        it('shows correct balance', async () => {
            const balance = await marketplace.consoleBalance({ from: accounts[0] })
            assert.notEqual(balance, null)
            console.log(balance)
        })
    })

    describe('assets', async () => {
        it('mints an NFT successfully', async () => {
            const metadata = await nftClient.store({
                name: 'Smiley face',
                description: 'Brighten up your day',
                image: new NFTStorage.File([/* data */], 'smiley.jpg', { type: 'image/jpg' })
            })
            assert.notEqual(metadata.url, null)
            console.log(metadata.url)
        })
    })
})