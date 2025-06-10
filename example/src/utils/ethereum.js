import { ethers } from 'ethers';

// Function to get a provider (defaults to Sepolia testnet)
export const getProvider = () => {
    if (!window.ethereum) {
        throw new Error('MetaMask not detected');
    }
    return new ethers.BrowserProvider(window.ethereum);
};

// Function to get a signer from the connected wallet
export const getSigner = async (provider) => {
    return await provider.getSigner();
};

// Function to get a contract instance
export const getContract = (address, abi, signerOrProvider) => {
    return new ethers.Contract(address, abi, signerOrProvider);
};

// Function to format ETH amounts
export const formatEther = (amount) => {
    return ethers.formatEther(amount);
};

// Function to parse ETH amounts
export const parseEther = (amount) => {
    return ethers.parseEther(amount);
};

// Function to get the current gas price
export const getGasPrice = async (provider) => {
    const gasPrice = await provider.getFeeData();
    return gasPrice;
};

// Function to estimate gas for a transaction
export const estimateGas = async (contract, method, ...args) => {
    try {
        const gasEstimate = await contract[method].estimateGas(...args);
        return gasEstimate;
    } catch (error) {
        console.error('Error estimating gas:', error);
        throw error;
    }
}; 