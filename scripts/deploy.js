const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const ArtCredentialNFT = await hre.ethers.getContractFactory("ArtCredentialNFT");
  const artCredentialNFT = await ArtCredentialNFT.deploy(deployer.address);

  await artCredentialNFT.waitForDeployment();

  const address = await artCredentialNFT.getAddress();
  console.log("ArtCredentialNFT deployed to:", address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 