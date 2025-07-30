**Software Requirement Specification for USD Stablecoin Issuance, Fund Pool, and Digital Exchange Market**

Develop an English-language HTML mockup application to demonstrate the operation of a stablecoin arbitrage mechanism within a digital exchange market, titled **USD Stablecoin Issuance, Fund Pool, and Digital Exchange Market**. Use a modern white-themed CSS style with hover glowing and shadow box effects. Ensure the layout is responsive for desktop, divided into three column boxes: **Stablecoin Issuance**, **Fund Pool**, and **Exchange Market**.

### Stablecoin Issuance Column Box
Contains four row boxes:

1. **Stablecoin Contract Constructor Row**:
   - Input field for stablecoin name.
   - Button labeled "Constructor" to generate and display the smart contract address code.

2. **Collateral Basket Row**:
   - Input fields for a pair of NFT credential address codes and the collateral's cash value.
   - Buttons for "Auction In", "Auction Out", and "Revaluation" to add, remove, or modify the collateral basket.
   - Scrolling console window to display the pair of address codes and cash values in the collateral basket.
   - Display box to show the total collateral value.

3. **Stablecoin Mint-Burn Row**:
   - Input field for Loan-to-Value (LTV) ratio.
   - Button labeled "Mint-Burn" to calculate and display `stablecoin totalSupply = total collateral value * LTV ratio`.

4. **ICO and Reserve Row**:
   - Input field for ICO token sales USD amount, with stablecoin:USD pair fixed at 1:1.
   - Display `USD reserve fund pool = sum of token sales USD amount + exchange net USD value`.
   - Indicator light: Red for `USD reserve fund pool < total collateral value` (under-collateralized), green for `USD reserve fund pool > total collateral value` (over-collateralized).

### Fund Pool Column Box
Contains three row boxes:

1. **Fund Pool Row**:
   - Display a comparison of `USD reserve fund pool` and `stablecoin fund pool`.
   - Calculate `stablecoin fund pool = stablecoin total supply - exchange net stablecoin value`.
   - Show comparison as actual numbers and relative percentages.

2. **Stablecoin Arbitrary Level Row**:
   - Input fields for lower and upper USD value bounds, with default values of 0.97 and 1.13, respectively.

3. **Liquidity Pool Row**:
   - Display three values:
     - `exchange net USD value = all buy-side USD value - all sell-side USD value`.
     - `exchange net stablecoin value = all sell-side event count - all buy-side event count`.
     - `suggested liquidity in USD/Stablecoin pair = 30% of USD reserve fund pool and 30% of stablecoin fund pool`.

### Exchange Market Column Box
Contains three row boxes:

1. **Stablecoin Buy and Sell Row**:
   - Input field for USD value to buy or sell a stablecoin.
   - Buttons for "Buy" or "Sell" to submit the order to the order book console in the next row.

2. **Order Book Console Row**:
   - Scrolling console displaying buy-side orders in red and sell-side orders in green.
   - One second after submission, a checkmark is added to the buy or sell event to indicate a simulated successful transaction.

3. **Short-Term Arbitrary Console Row**:
   - Scrolling console displaying arbitrary buy-side orders in light red and arbitrary sell-side orders in light green.
   - If a buy-side event's USD value < lower USD value bound, the arbitrary protocol automatically generates an arbitrary sell-side event equal to the lower USD value bound in the arbitrary console.
   - If a sell-side event's USD value > upper USD value bound, the arbitrary protocol automatically generates an arbitrary buy-side event equal to the upper USD value bound in the arbitrary console.
   - One second after submission, a checkmark is added to the arbitrary buy or sell event to indicate a simulated successful transaction.

---

