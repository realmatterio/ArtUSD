const { ethers } = require("ethers");
const dotenv = require("dotenv");
const fs = require("fs");

// Load environment variables
dotenv.config();

const INFURA_URL = "https://sepolia.infura.io/v3/022ff1f9bad14953828826e1ab5bdbe6";
const PRIVATE_KEY = process.env.PRIVATE_KEY;

if (!PRIVATE_KEY) {
  throw new Error("PRIVATE_KEY not set in .env");
}

async function main() {
  // Read ABI and bytecode from Hardhat artifacts
  const artifact = JSON.parse(fs.readFileSync("./artifacts/contracts/ArtCredentialNFT.sol/ArtCredentialNFT.json", "utf8"));
  const abi = artifact.abi;
  const bytecode = artifact.bytecode;

  // Set up provider and wallet
  const provider = new ethers.JsonRpcProvider(INFURA_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

  // Create contract factory
  const factory = new ethers.ContractFactory(abi, bytecode, wallet);

  // Deploy contract (constructor expects initialOwner)
  console.log("Deploying contract from:", wallet.address);
  const contract = await factory.deploy(wallet.address);
  await contract.waitForDeployment();
  const address = await contract.getAddress();
  console.log("ArtCredentialNFT deployed to:", address);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
}); 