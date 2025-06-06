// test/ArtUSD.test.js
// Load dependencies
// const { expect } = require('chai');
// const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")

// Start test block
// describe('ArtUSD', function () {
//     async function deployFixture() {
//         const [owner] = await ethers.getSigners();
//         const ArtUSD = await ethers.getContractFactory("artUSD");
//         const artUSD = await ArtUSD.deploy(owner.address);
//         await artUSD.waitForDeployment();

//         return { artUSD, owner };
//     }

//     describe('Deployment', function () {
//         it('should deploy the contract', async function () {
//             const { artUSD, owner } = await loadFixture(deployFixture);
//             expect(await artUSD.owner()).to.equal(owner.address);
//         });
//     });
// });