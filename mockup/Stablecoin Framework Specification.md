# Software Specification: Real Matter Stablecoin Issuer Web App

## 1. Overview
The "Real Matter Stablecoin Issuer" is a responsive HTML mockup web application designed to demonstrate the framework of a new stablecoin. The application features a cyber light theme with a glowing, hover, shadow box, and gradient background design. It consists of two pages: an introductory page and a framework configuration page with three interactive columns. The app is optimized for both desktop and mobile use and includes navigation to external HTML files for specific functionalities.

## 2. General Requirements
- **Platform**: Web-based, built using HTML, CSS, and JavaScript.
- **Theme**: Cyber light theme with glowing effects, hover animations, shadow boxes, and a gradient background.
- **Responsiveness**: ensuring proper layout and functionality across common desktop resolutions, and fitting into mobile view.
- **Navigation**: Smooth transitions between pages and external file links.
- **Footer**: Include a hyperlinked footer on both pages: "Contact us: Real Matter Technology Limited" linking to [www.realmatter.io](http://www.realmatter.io).

## 3. Page Specifications

### 3.1 Page 1: Introduction
- **Purpose**: Introduce the stablecoin issuer framework.
- **Layout**:
  - **Header**: Title text: "RWA Stablecoin Issuance Scenario Analysis by Real Matter" in bold, centered, with a glowing effect.
  - **Main Content**: Display an image named `RWA_Stablecoin.png` centered on the page, with subtle hover animation (e.g., slight zoom or glow enhancement).
  - **Navigation**: A "Try Mock Up" button at the bottom, styled as a hopping down arrow with a glowing hover effect. Clicking this button navigates to the second page.
- **Styling**:
  - Gradient background (e.g., light blue to white or neon green to blue).
  - button elements feature shadow boxes and glowing effects.
  - Responsive design ensures the image scales appropriately without distortion.

### 3.2 Page 2: Stablecoin and Compliance Framework
- **Purpose**: Allow users to explore and configure the stablecoin framework, liquidity protocols, and tokenomic/compliance settings.
- **Layout**: Three-column layout, each column in a shadow box with glowing hover effects. Title at the top: "Stablecoin and Compliance Framework" in bold, centered, with a glowing effect.
- **Styling**:
  - Gradient background consistent with Page 1.
  - Each column box has a shadow effect, glowing borders on hover, and a clean, modern font.
  - Columns are evenly spaced with responsive padding for desktop screens.

#### 3.2.1 Column 1: Stablecoin Framework
- **Title**: "Stablecoin Framework"
- **Inputs** (Dropdown menus with hover effects):
  1. **Collateral Type**:
     - Options: Asset-backed, Fiat-pegged, Commodity-pegged.
     - If **Asset-backed**, sub-options: Art, Real Estate, Carbon Offset, Other Illiquid Assets (e.g., Intellectual Property, Collectibles).
     - If **Fiat-pegged**, sub-options: USD, Bonds, HKD, CNY, Other Currencies (e.g., EUR, GBP).
     - If **Commodity-pegged**, sub-options: Gold, Silver, Petroleum, Other Liquid Assets (e.g., Copper, Agricultural Commodities).
  2. **Proof of Reserve Method**:
     - Suggested Options: Third-Party Audit, On-Chain Transparency (e.g., real-time blockchain attestation), Oracles, Bank Custody Reports.
     - Description: Methods to verify the backing reserves, ensuring transparency and trust in the stablecoin’s value.
  3. **Pegged Exchange Rate**:
     - Options: 1 stablecoin to 1 USD, 1 HKD, 1 CNY.
     - Description: Fixed exchange rate to maintain stablecoin value alignment with the selected fiat or asset.
  4. **Smart Contract Type**:
     - Options: ERC20, ERC1400.
     - Description: ERC20 for standard token functionality; ERC1400 for advanced features like compliance and transfer restrictions.
  5. **Primary Market**:
     - Options: Permissioned Besu, Ethereum, Layer 2 (e.g., Optimism, Arbitrum).
     - Description: Blockchain platform for issuing and managing the stablecoin.
  6. **Cross Bridge Protocol**:
     - Options: Locked and Mint, Burn and Mint.
     - Description: Mechanisms for cross-chain interoperability, ensuring secure transfers between blockchains.
- **Navigation**: A "Try Stablecoin Issuance" button styled as a hopping down arrow with a glowing hover effect. Clicking opens `IssuanceArbitrage.html` in a new browser tab.

#### 3.2.2 Column 2: Liquidity Protocols
- **Title**: "Liquidity Protocols"
- **Inputs** (Dropdown menus with hover effects):
  1. **Liquidity Pool**:
     - Suggested Options: Uniswap V3, Curve Finance, Balancer, Bancor.
     - Description: Decentralized platforms for pooling assets to facilitate trading and ensure liquidity for the stablecoin.
  2. **Market Maker**:
     - Suggested Options: Automated Market Maker (AMM), Centralized Market Maker, Hybrid Market Maker.
     - Description: Systems to provide liquidity and stabilize prices through automated or manual trading strategies.
  3. **Staking**:
     - Options: Yield Farming, Liquidity Provision Rewards, Governance Staking.
     - Description: Yield Farming allows users to earn rewards by locking stablecoins in liquidity pools; Liquidity Provision Rewards incentivize providing liquidity; Governance Staking enables participation in protocol governance.
  4. **Lending**:
     - Options: Savings, Overcollateralized Lending, Flash Loans.
     - Description: Savings allows users to earn interest on stablecoin deposits; Overcollateralized Lending enables borrowing against collateral; Flash Loans provide uncollateralized loans for arbitrage or liquidations.
  5. **Borrowing**:
     - Options: Loans, Margin Borrowing, Peer-to-Peer Borrowing.
     - Description: Loans allow users to borrow stablecoins against collateral; Margin Borrowing supports leveraged trading; Peer-to-Peer Borrowing enables direct lending between users.
- **Navigation**: A "Try Liquidity Protocols" button styled as a hopping down arrow with a glowing hover effect. Clicking opens `Staking.html` in a new browser tab.

#### 3.2.3 Column 3: Tokenomic and Compliance
- **Title**: "Tokenomic and Compliance"
- **Inputs** (Dropdown menus with hover effects):
  1. **Tokenomic**:
     - **Cross Border Remittance**:
       - Suggested Options: Instant Settlement, Scheduled Transfers, Multi-Currency Swaps.
       - Description: Facilitates fast, low-cost international transfers using stablecoins.
     - **Stablecoin Payment**:
       - Suggested Options: Peer-to-Peer Payments, Merchant Payments, Subscription Payments.
       - Description: Enables stablecoin use for everyday transactions, including retail and recurring payments.
     - **Stablecoin Point of Sale**:
       - Suggested Options: QR Code Payments, NFC Payments, Online Checkout Integration.
       - Description: Supports stablecoin payments at physical and online points of sale.
     - **Visa Debit Card**:
       - Suggested Options: Prepaid Stablecoin Card, Linked Wallet Card.
       - Description: Allows spending stablecoins via a Visa debit card linked to a wallet or prepaid balance.
     - **Visa Credit Card**:
       - Suggested Options: Stablecoin-Backed Credit, Collateralized Credit Line.
       - Description: Provides credit facilities backed by stablecoin collateral or linked to a wallet.
  2. **Compliance**:
     - **Custody**:
       - Options: Custodian-Based Wallet, Self-Custody-Based Wallet.
       - Description: Custodian-Based Wallet involves third-party management of assets; Self-Custody-Based Wallet gives users full control over their private keys.
     - **KYC**:
       - Options: Custodian-Based Procedures, Self-Custody-Based Procedures.
       - Description: Custodian-Based Procedures require KYC through a third party; Self-Custody-Based Procedures use decentralized identity verification.
     - **Cybersecurity**:
       - Option: Quantum-Safe Cybersecurity Protocols.
       - Description: Implements encryption resistant to quantum computing threats to secure transactions and data.
     - **AML/CFT**:
       - Suggested Options: Chainalysis Integration, Elliptic Monitoring, Automated Transaction Screening.
       - Description: Tools to monitor and prevent money laundering and terrorist financing, ensuring regulatory compliance.
     - **Travel Rule**:
       - Option: ISO 20022.
       - Description: Standard for exchanging financial transaction data to comply with cross-border regulatory requirements.
- **Navigation**: A "Try POS Payment" button styled as a hopping down arrow with a glowing hover effect. Clicking opens `Staking.html` in a new browser tab.

## 4. Technical Requirements
- **Frontend**:
  - HTML5 for structure, CSS3 for styling (including gradients, shadow boxes, and glowing effects), and JavaScript for interactivity (e.g., dropdowns, button actions).
  - Use a modern CSS framework (e.g., Tailwind CSS or Bootstrap) to streamline responsive design and animations.
- **Assets**:
  - Include `RWA.png` for the introductory page.
  - External HTML files: `Issurance.html`, `Staking.html` (assumed to be provided or placeholders).
- **Interactivity**:
  - Dropdown menus dynamically update based on selections (e.g., collateral type sub-options).
  - Buttons trigger navigation to new tabs or pages with smooth animations.
- **Accessibility**:
  - Ensure keyboard navigation and screen reader compatibility.
  - Use high-contrast colors for readability within the cyber light theme.

## 5. Footer
- **Content**: Hypertext "Contact us: Real Matter Technology Limited" linking to [www.realmatter.io](http://www.realmatter.io).
- **Placement**: Centered at the bottom of both pages, styled with a subtle glow effect on hover.

## 6. Assumptions
- External files (`Issurance.html`, `Staking.html`) are assumed to exist or will be created separately.
- The `RWA.png` image is provided and optimized for web use.
- No backend functionality is required; the mockup is frontend-only for demonstration purposes.

## 7. Deliverables
- HTML, CSS, and JavaScript files for the two-page web app.
- Directory structure including `RWA.png` and placeholders for `Issurance.html` and `Staking.html`.
- Documentation (this specification) detailing the design and functionality.

This specification provides a clear framework for developing the "Real Matter Stablecoin Issuer" web app, ensuring a visually appealing, user-friendly, and functional mockup.