# DecentralizedWill – A Smart Contract for Time-Locked Inheritance

## What's this project about?

**DecentralizedWill** is an Ethereum smart contract that allows users to securely designate a beneficiary who can claim their ETH if the original owner becomes inactive for a specified period. The contract implements a simple heartbeat mechanism and ensures funds are only released when truly necessary. The purpose of this project is to learn about smart contracts and Solidity programming.

---

The contract was deployed on Sepolia testnet.
https://sepolia.etherscan.io/address/0x5f212806cdb1a06f490fea2e70a80086870014df

Here is a transaction made with the contract:
https://sepolia.etherscan.io/tx/0x243b16f4ed24a4e8b025a012c53ef8a6a9fb761b001a70bf9addf3baca69e8ca

## How It Works

- Each user (owner) can **set a will** by specifying:
  - A **beneficiary** address (the person who will inherit the ETH)
  - An **inactivity period** (in seconds)
  - An initial **ETH deposit**
- The owner must regularly call `heartbeat()` to signal they are alive.
- If the owner fails to check in and the inactivity period passes, the beneficiary can claim the ETH.
- ETH can be added any time via `setWill()` or by sending ETH directly.

## Features

- Supports multiple owners — each with their own will
- Uses a heartbeat mechanism to reset inactivity countdown
- Beneficiaries can claim only when the owner is inactive
- Allows owners to send more ETH directly to their will.

## Functions

### `setWill(address beneficiary, uint inactivityPeriod) external payable`

- Sets or updates the caller’s will.
- Requires ETH deposit (`msg.value > 1`).
- Updates beneficiary, inactivity period, and last check-in time.

### `heartbeat() external`

- Updates the owner's last check-in timestamp.
- Must be called regularly to keep the will unclaimable.

### `claim(address owner) external`

- Allows a beneficiary to claim the inheritance if:
  - The owner hasn't checked in within the inactivity period
  - They are the registered beneficiary
  - The will hasn’t already been claimed

### `isClaimable(address owner) external view returns (bool)`

- View-only function that returns true if a will is claimable by its beneficiary.
