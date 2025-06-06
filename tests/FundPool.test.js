// test/FundPool.test.js
// Load dependencies
const { expect } = require('chai');
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")

// Start test block
describe('FundPool', function () {
    async function deployFundPoolFixture() {
        const [owner, user] = await ethers.getSigners();
        
        // Deploy MockUSDC
        const MockUSDC = await ethers.getContractFactory("MockUSDC");
        const mockUSDC = await MockUSDC.deploy();
        await mockUSDC.waitForDeployment();

        // Deploy mock price feed with initial price of 1,000,000 (8 decimals)
        const MockArtPriceFeed = await ethers.getContractFactory("MockArtPriceFeed");
        const mockPriceFeed = await MockArtPriceFeed.deploy(1000000 * 10**8);
        await mockPriceFeed.waitForDeployment();

        // Deploy ArtUSD with mock price feed
        const ArtUSD = await ethers.getContractFactory("ArtUSD");
        const artUSD = await ArtUSD.deploy(owner.address, mockPriceFeed.target);
        await artUSD.waitForDeployment();

        // Deploy FundPool with the mock USDC and ArtUSD addresses
        const FundPool = await ethers.getContractFactory("FundPool");
        const fundPool = await FundPool.deploy(mockUSDC.target, artUSD.target);
        await fundPool.waitForDeployment();

        // Set FundPool as ArtUSD's fundPool
        await artUSD.setFundPool(fundPool.target);

        return { fundPool, mockUSDC, artUSD, mockPriceFeed, owner, user };
    }

    describe('Deployment', function () {
        it('should deploy the contract', async function () {
            const { fundPool, owner } = await loadFixture(deployFundPoolFixture);
            expect(await fundPool.owner()).to.equal(owner.address);
        });
    });

    describe('Deposit', function () {
        it('should deposit usdc into contract', async function () {
            const { fundPool, mockUSDC, owner } = await loadFixture(deployFundPoolFixture);
            
            // MockUSDC already has 1,000,000 tokens minted to owner
            // Approve and deposit 1000 USDC (with 6 decimals)
            const depositAmount = 1000 * 10**6;
            await mockUSDC.approve(fundPool.target, depositAmount);
            await fundPool.depositUSD(depositAmount);
            
            expect(Number(await fundPool.getReserveBalance())).to.equal(depositAmount);
        });
    });
});