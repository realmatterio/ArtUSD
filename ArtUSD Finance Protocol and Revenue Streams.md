graph TD
    A[Public Sale of ArtUSD<br>e.g., $1B Raised] -->|70% Allocation| B[Core Investment Portfolio<br>$700M max]
    A -->|30% Allocation| C[Short-term Liquidity Pool<br>$300M max]
    B --> D[Earnings from Investments<br>e.g., Art Appreciation/Leasing]
    D -->|5-10% Dividends| E[Art Fund DAO Stakeholders]
    D -->|Lending Revenue| F[ArtUSD Lending Protocol]
    F -->|8% Yield| G[ArtUSD Staking Protocol]
    G --> H[Crypto Investors]
    C --> I[DEX Fund Swapper<br>ArtUSD/USDC Pair]
    I --> H
    I --> J[Artist Borrowers]

graph TD
    A[ArtUSD Lending Protocol] -->|Loans at 12-20% Interest| B[Artist Borrowers]
    B -->|Repay Interest + Principal| A
    A -->|Lending Revenue| C[ArtUSD Staking Protocol]
    C -->|8% Yield| D[Crypto Investors]
    D -->|Stake ArtUSD| C
    E[DEX Fund Swapper<br>ArtUSD/USDC Pair] -->|Buy ArtUSD| D
    E -->|Sell ArtUSD for Funding| B
    B -->|Buy ArtUSD for Repayment| E
    D -->|Sell ArtUSD for Redemption| E