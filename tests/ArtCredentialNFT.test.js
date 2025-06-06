// test/ArtCredentialNFT.test.js
// Load dependencies
const { expect } = require('chai');
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")

// Start test block
describe('ArtCredentialNFT', function () {
    async function deployNFTFixture() {
        const [owner] = await ethers.getSigners();
        const ArtCredentialNFT = await ethers.getContractFactory("ArtCredentialNFT");
        const artCredentialNFT = await ArtCredentialNFT.deploy(owner.address);
        await artCredentialNFT.waitForDeployment();

        return { artCredentialNFT, owner };
    }

    describe('Deployment', function () {
        it('should deploy the contract', async function () {
            const { artCredentialNFT, owner } = await loadFixture(deployNFTFixture);
            expect(await artCredentialNFT.owner()).to.equal(owner.address);
        });
    });

    describe('Minting', function () {
        it('should mint a new token', async function () {
            const { artCredentialNFT, owner } = await loadFixture(deployNFTFixture);
            await artCredentialNFT.mint(owner.address);
            expect(Number(await artCredentialNFT.balanceOf(owner.address))).to.equal(1);
        });
    });
});