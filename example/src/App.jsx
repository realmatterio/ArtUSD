import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'
import { getProvider, getSigner, getContract } from './utils/ethereum'

// Utility function to shorten wallet address
const shortenAddress = (address) => {
  if (!address) return '';
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
};

// ArtCredentialNFT contract details
const CONTRACT_ADDRESS = '0xd997cA7a85dD5a06DAbf3A0b1a6cAA099083Bad4';
const ABI = [
  {
    "inputs": [
      { "internalType": "address", "name": "initialOwner", "type": "address" }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": true, "internalType": "address", "name": "to", "type": "address" },
      { "indexed": false, "internalType": "uint256", "name": "tokenId", "type": "uint256" },
      { "indexed": false, "internalType": "string", "name": "artDetails", "type": "string" }
    ],
    "name": "CredentialIssued",
    "type": "event"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "to", "type": "address" },
      { "internalType": "string", "name": "details", "type": "string" }
    ],
    "name": "issueCredential",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
  // ... (add more ABI items as needed)
];

function App() {
  const [status, setStatus] = useState('');
  const [details, setDetails] = useState('');
  const [txHash, setTxHash] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [walletAddress, setWalletAddress] = useState('');
  const [selectedFile, setSelectedFile] = useState(null);
  const [previewUrl, setPreviewUrl] = useState('');

  const connectWallet = async () => {
    try {
      if (!window.ethereum) {
        setStatus('MetaMask not detected');
        return;
      }
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      setWalletAddress(accounts[0]);
      setStatus('Wallet connected!');
    } catch (err) {
      setStatus('Error connecting wallet: ' + err.message);
    }
  };

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setSelectedFile(file);
      // Create preview URL for the image
      const fileUrl = URL.createObjectURL(file);
      setPreviewUrl(fileUrl);
    }
  };

  // Issue credential handler
  const handleIssueCredential = async (e) => {
    e.preventDefault();
    if (!walletAddress) {
      setStatus('Please connect your wallet first');
      return;
    }
    if (!selectedFile) {
      setStatus('Please select an image file');
      return;
    }
    setStatus('Issuing credential...');
    setTxHash('');
    try {
      const provider = getProvider();
      const signer = await getSigner(provider);
      const contract = getContract(CONTRACT_ADDRESS, ABI, signer);
      const tx = await contract.issueCredential(walletAddress, details);
      setStatus('Transaction sent. Waiting for confirmation...');
      await tx.wait();
      setTxHash(tx.hash);
      setStatus('Credential issued!');
      // Reset form
      setDetails('');
      setSelectedFile(null);
      setPreviewUrl('');
      handleCloseModal();
    } catch (err) {
      setStatus('Error: ' + (err.reason || err.message));
    }
  };

  const handleOpenModal = () => {
    setShowModal(true);
    setStatus('');
    setDetails('');
    setTxHash('');
  };

  const handleCloseModal = () => {
    setShowModal(false);
    setDetails('');
    setSelectedFile(null);
    setPreviewUrl('');
    setStatus('');
    setTxHash('');
  };

  const handleOverlayClick = (e) => {
    if (e.target === e.currentTarget) {
      handleCloseModal();
    }
  };

  return (
    <>
      <nav>
        <p className="left">Mock Auction House</p>
        <div className="nav-buttons">
          <button className="connect-wallet" onClick={connectWallet}>
            {walletAddress ? shortenAddress(walletAddress) : 'Connect Wallet'}
          </button>
          <button 
            className="new-credential" 
            onClick={handleOpenModal}
            disabled={!walletAddress}
            style={{ opacity: walletAddress ? 1 : 0.5 }}
          >
            + New Credential
          </button>
        </div>
      </nav>

      <div className="art-grid">
        {[...Array(9)].map((_, index) => (
          <div key={index} className="art-item">
            <img 
              src={`https://picsum.photos/seed/${index}/300/300`} 
              alt={`Artwork ${index + 1}`}
              className="art-image"
            />
            <h3 className="art-title">Artwork {index + 1}</h3>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={handleOverlayClick}>
          <div className="modal-content">
            <button className="modal-close" onClick={handleCloseModal}>&times;</button>
            <h2>Issue New Credential</h2>
            <form className="credential-form" onSubmit={handleIssueCredential}>
              <div className="file-upload-container">
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleFileChange}
                  className="file-input"
                  id="file-upload"
                  required
                />
                <label htmlFor="file-upload" className="file-upload-label">
                  <span className="upload-icon">📁</span>
                  <span className="upload-text">
                    {selectedFile ? selectedFile.name : 'Choose an image file'}
                  </span>
                </label>
                {previewUrl && (
                  <div className="image-preview">
                    <img src={previewUrl} alt="Preview" />
                  </div>
                )}
              </div>
              <input
                type="text"
                placeholder="Art details"
                value={details}
                onChange={e => setDetails(e.target.value)}
                required
              />
              <button type="submit">Issue Credential</button>
            </form>
            {status && <p className="status-message">{status}</p>}
            {txHash && <p>Tx: <a href={`https://sepolia.etherscan.io/tx/${txHash}`} target="_blank" rel="noopener noreferrer">{txHash}</a></p>}
          </div>
        </div>
      )}
    </>
  )
}

export default App
