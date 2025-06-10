// test/Blacklistable.test.js
// Load dependencies
const { expect } = require('chai');
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")

// Start test block
describe('Blacklistable', function () {
    async function deployFixture() {
        const [owner] = await ethers.getSigners();
        const Blacklistable = await ethers.getContractFactory("Blacklistable");
        const blacklistable = await Blacklistable.deploy(owner.address);
        await blacklistable.waitForDeployment();

        return { blacklistable, owner };
    }

    describe('Deployment', function () {
        it('should deploy the contract', async function () {
            const { blacklistable, owner } = await loadFixture(deployFixture);
            expect(await blacklistable.owner()).to.equal(owner.address);
        });
    });

    describe('Blacklist', function () {
        it('should blacklist address', async function () {
            const { blacklistable } = await loadFixture(deployFixture);
            const [_, addr1, addr2] = await ethers.getSigners();
            
            await blacklistable.blacklist(addr1);
            expect(await blacklistable.isBlacklisted(addr1)).to.equal(true);
        });
    });

    describe('Un-Blacklist', function () {
        it('should remove address from blacklist', async function () {
            const { blacklistable } = await loadFixture(deployFixture);
            const [_, addr1, addr2] = await ethers.getSigners();
            
            await blacklistable.blacklist(addr1);
            await blacklistable.removeFromBlacklist(addr1);
            
            expect(await blacklistable.isBlacklisted(addr1)).to.equal(false);
        });
    });
});