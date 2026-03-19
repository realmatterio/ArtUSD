# ArtID DAO Governance Setup Guide
Simple Menu & Step-by-Step Flow  
(Using ArtID ERC20 Votes Token + ArtIDGovernance)

## Quick Overview
You already have:
- ArtID → ERC20Votes upgradeable governance token
- ArtIDGovernance → OpenZeppelin Governor with Timelock

Goal: Turn them into a working on-chain DAO

## Main Menu – What You Need to Do

1. [ ] Deploy TimelockController  
2. [ ] Deploy ArtID token (if not yet) & mint initial supply  
3. [ ] Deploy ArtIDGovernance (pass ArtID + Timelock addresses)  
4. [ ] Transfer control: Give important roles to Timelock  
5. [ ] Users / community: Delegate tokens to activate voting power  
6. [ ] Verify everything works (test proposal + vote)  
7. [ ] (Optional) Connect frontend / Tally for easy usage  

## Step-by-Step Flow

### Phase 1 – Deployment (One-time setup)

1. Deploy TimelockController  
   - minDelay: 172800 seconds (2 days) or 432000 (5 days) – choose delay you want  
   - proposers: [ArtIDGovernance address] (add after deploy)  
   - executors: [ArtIDGovernance address]  
   - admin: your deployer address (you will renounce later)

2. Deploy ArtID (if not deployed yet)  
   - Call initialize(...) with:  
     - defaultAdmin = your multisig / safe address  
     - tokenBridge = 0x0 or bridge contract  
     - pauser = your multisig  
     - minter = your multisig or deployer (temporary)

3. Mint initial token supply  
   - Call mint(address to, uint256 amount) many times  
     Examples:  
     - Community airdrop / treasury  
     - Liquidity pool  
     - Team vesting (send to vesting contract later)

4. Deploy ArtIDGovernance  
   - Constructor arguments:  
     - _token      = ArtID contract address  
     - _timelock   = TimelockController address  
   → This links voting power directly to ArtID token

### Phase 2 – Make it Decentralized (Very Important!)

5. Transfer roles from deployer to Timelock  
   On ArtID contract, call:  
   - grantRole(MINTER_ROLE, timelock.address)  
   - grantRole(PAUSER_ROLE, timelock.address)  
   - grantRole(DEFAULT_ADMIN_ROLE, timelock.address)  

   Then (after grants succeed):  
   - renounceRole(MINTER_ROLE, your_address)  
   - renounceRole(PAUSER_ROLE, your_address)  
   - renounceRole(DEFAULT_ADMIN_ROLE, your_address)  

   → After this, only governance proposals (via Timelock) can mint, pause, or change admin

6. Add Timelock as proposer & executor (if not auto-added)  
   On TimelockController:  
   - grantRole(PROPOSER_ROLE, ArtIDGovernance.address)  
   - grantRole(EXECUTOR_ROLE, ArtIDGovernance.address)

### Phase 3 – Community Activation

7. Tell everyone to delegate  
   Each user must call (one time):  
   ArtID.delegate(their_own_address)  
   → This turns their ArtID balance into voting power

8. Test the full flow (strongly recommended on testnet first)  
   - Propose something small (e.g. call a harmless function)  
   - Wait voting delay (1 day)  
   - Community votes (For / Against / Abstain)  
   - Wait voting period (7 days)  
   - Queue → wait timelock delay → Execute

### Phase 4 – Make it User-Friendly (Recommended)

9. Connect to tools  
   - Tally.xyz → add your Governor address (easiest for voting)  
   - Snapshot.org → if you want off-chain signaling  
   - Build simple frontend (optional) with wagmi / ethers.js

## Final Checklist Before Mainnet Launch

- [ ] Timelock minDelay is reasonable (≥2 days)  
- [ ] All critical roles (MINTER, PAUSER, ADMIN) are on Timelock  
- [ ] Deployer renounced admin rights  
- [ ] Token distribution plan is public & fair  
- [ ] At least some users already delegated  
- [ ] Tested 1 full proposal cycle on testnet  

Done!  
You now have a standard, secure ArtID DAO Governance system using OpenZeppelin best practices.