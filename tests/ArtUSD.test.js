// test/ArtUSD.test.js
// Load dependencies
const { expect } = require('chai');
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")

// Start test block
describe('ArtUSD', function () {
    async function deployFixture() {
        const [owner] = await ethers.getSigners();
        const ArtUSD = await ethers.getContractFactory("ArtUSD");
        const artUSD = await ArtUSD.deploy(owner.address, owner.address);
        await artUSD.waitForDeployment();

        return { artUSD, owner };
    }

    describe('Deployment', function () {
        it('should deploy the contract', async function () {
            const { artUSD, owner } = await loadFixture(deployFixture);
            expect(await artUSD.owner()).to.equal(owner.address);
        });
    });

    describe('Pause', function () {
        it('should pause the contract', async function () {
            const { artUSD, owner } = await loadFixture(deployFixture);
            await expect(artUSD.pause()).to.emit(artUSD, "Paused");
        });
    });

    describe('Blacklist', function () {
        it('should blacklist address', async function () {
            const { artUSD, owner } = await loadFixture(deployFixture);
            const [_, addr1, addr2] = await ethers.getSigners();
            
            // Check for blacklisted address
            await artUSD.blacklist(addr1);
            expect(await artUSD.isBlacklisted(addr1)).to.equal(true);
            // Check for un-blacklisted address
            expect(await artUSD.isBlacklisted(addr2)).to.equal(false);
        });
    });

    describe('Un-Blacklist', function () {
        it('should remove address from blacklist', async function () {
            const { artUSD } = await loadFixture(deployFixture);
            const [_, addr1, addr2] = await ethers.getSigners();
            
            await artUSD.blacklist(addr1);
            await artUSD.removeFromBlacklist(addr1);
            
            expect(await artUSD.isBlacklisted(addr1)).to.equal(false);
        });
    });
});