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

    describe('Issue Credential', function () {
        it('should issue a new credential', async function () {
            const { artCredentialNFT, owner } = await loadFixture(deployNFTFixture);
            await artCredentialNFT.issueCredential(owner.address, '{"name": "John"}');

            // Check for emitted event
            await expect(artCredentialNFT.issueCredential(owner.address, '{"name": "John"}'))
                .to.emit(artCredentialNFT, "CredentialIssued")
                .withArgs(owner.address, 1, '{"name": "John"}');
            // Check for token id counter
            expect(Number(await artCredentialNFT.tokenIdCounter())).to.equal(2);
            // Check for artDetails array
            expect(await artCredentialNFT.artDetails(0)).to.equal('{"name": "John"}');
        });
    });
});