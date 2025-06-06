// test/ArtUSD.test.js
// Load dependencies
const { expect } = require('chai');

// Start test block
describe('ArtUSD', function () {
  before(async function () {
    this.ArtUSD = await ethers.getContractFactory('ArtUSD');
  });

  beforeEach(async function () {
    this.ArtUSD = await this.ArtUSD.deploy();
    await this.ArtUSD.waitForDeployment();
  });

  
});