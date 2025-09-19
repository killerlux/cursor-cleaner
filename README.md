# Web3 Task Manager

An end-to-end Hardhat + Vite demo DApp for managing classroom tasks on-chain. The project showcases a Solidity smart contract secured with OpenZeppelin's `Ownable`, deployment tooling, automated tests, a vanilla JavaScript frontend powered by Vite and Web3.js v4, and a lightweight CI workflow suitable for classroom demos or workshops.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Setup](#repository-setup)
3. [Prerequisites](#prerequisites)
4. [Installation](#installation)
5. [Local Development Workflow](#local-development-workflow)
6. [Running Tests](#running-tests)
7. [Deploying to Sepolia Testnet](#deploying-to-sepolia-testnet)
8. [Frontend Usage Guide](#frontend-usage-guide)
9. [Troubleshooting](#troubleshooting)
10. [Project Structure](#project-structure)
11. [License](#license)

## Project Overview

The Task Manager smart contract lets the owner create tasks, assign them to teammates, and mark them complete. Events are emitted for each state change so the frontend can react in real time. The repository contains:

- **Solidity contract** (`contracts/TaskManager.sol`) using OpenZeppelin `Ownable` and Checks-Effects-Interactions patterns.
- **Hardhat setup** with tests, TypeScript deployment script, and network configuration for localhost and Sepolia.
- **Vite frontend** (`frontend/`) built with vanilla JS and Web3.js v4 to read/write contract data after connecting a wallet.
- **Documentation** for both instructors (DEMO.md) and students (this README).
- **Automation** via GitHub Actions (`.github/workflows/ci.yml`) and a PR template.

## Repository Setup

If you intend to publish this project under your own GitHub account, follow these steps to create a clean repository named, for example, `web3-task-manager-demo`:

1. **Create the remote repository** on GitHub (no README/license auto-generated).
2. **Clone or copy this code** into a local folder:
   ```bash
   git clone <path-or-existing-fork> web3-task-manager-demo
   cd web3-task-manager-demo
   ```
   If you downloaded an archive of the code instead, run `git init` inside the extracted directory before continuing.
3. **Point the repository at your new remote**:
   ```bash
   git remote add origin git@github.com:<your-username>/web3-task-manager-demo.git
   # or use https://github.com/<your-username>/web3-task-manager-demo.git if you prefer HTTPS
   ```
4. **Push the existing history**:
   ```bash
   git push -u origin main
   ```
   (Replace `main` with your active branch if different.)

Once pushed, you can open pull requests from feature branches that follow the Conventional Commits style already in the history.

## Prerequisites

- Node.js **18.x** or newer
- npm **9.x** or newer
- Git 2.4+
- A browser wallet such as MetaMask for interacting with the frontend
- Optional: Sepolia testnet ETH for deploying beyond localhost

Verify your Node/npm versions:

```bash
node -v
npm -v
```

## Installation

1. **Install backend dependencies**:
   ```bash
   npm install
   ```
2. **Install frontend dependencies**:
   ```bash
   npm install --prefix frontend
   ```
3. **Bootstrap environment variables** for Sepolia (optional but recommended):
   ```bash
   cp .env.example .env
   ```
   Fill in `SEPOLIA_RPC_URL` and `PRIVATE_KEY` inside `.env` before attempting a Sepolia deployment. Leave the file untouched for local-only demos.

## Local Development Workflow

Follow this sequence whenever you want to run the full classroom demo locally. Each step is designed to be executed in order.

1. **Start a local Hardhat node** (new terminal tab/window):
   ```bash
   npm run dev:node
   ```
   The node listens on `http://127.0.0.1:8545` and pre-funds 20 accounts whose private keys Hardhat prints to the console.

2. **Compile contracts** (back in your main terminal):
   ```bash
   npm run compile
   ```

3. **Run the automated tests** to ensure everything is healthy:
   ```bash
   npm test
   ```

4. **Deploy the contract to the local node**:
   ```bash
   npm run deploy:local
   ```
   The script prints the deployed address and writes `frontend/contract.json` with the ABI and address consumed by the frontend.

5. **Launch the Vite dev server** (keep the Hardhat node running):
   ```bash
   npm run dev --prefix frontend
   ```
   Vite outputs a local URL such as `http://localhost:5173`. Open it in a browser with MetaMask installed. When prompted, switch MetaMask to the Hardhat network (chain ID 31337) and import one of the private keys from the Hardhat node log to test with funded accounts.

6. **Interact with the DApp**:
   - Connect your wallet via the UI.
   - Create tasks with a title and description.
   - Assign tasks from the owner account to another signer.
   - Complete tasks as the assignee or owner and observe event logs updating live.

When you are done, stop the Hardhat node and Vite dev server with `Ctrl+C` in their respective terminals.

## Running Tests

The test suite located at `test/TaskManager.ts` uses Mocha/Chai and Hardhat's fixture helpers. It verifies:

- Task creation stores the right metadata and emits `TaskCreated`.
- Only the owner can assign tasks and zero-address assignments are rejected.
- Tasks can be completed only once by the assignee or owner, emitting `TaskCompleted`.
- Helper reads (`getTask`, `getTaskIds`) return consistent data and invalid IDs revert.

Execute the suite at any time with:

```bash
npm test
```

## Deploying to Sepolia Testnet

1. Ensure `.env` contains:
   ```env
   SEPOLIA_RPC_URL=https://your-sepolia-rpc
   PRIVATE_KEY=0xYOUR_PRIVATE_KEY
   ```
2. Fund the account represented by `PRIVATE_KEY` with Sepolia ETH.
3. Deploy using Hardhat:
   ```bash
   npm run deploy:sepolia
   ```
4. The script overwrites `frontend/contract.json` with the Sepolia address. Restart the frontend (`npm run dev --prefix frontend`) and switch MetaMask to the Sepolia network to interact with the live contract.

## Frontend Usage Guide

- **Connect Wallet**: Click **Connect Wallet**. Approve the connection request in MetaMask.
- **Create Task**: Fill in the title and description, then submit to call `createTask`.
- **Assign Task**: Provide the numeric task ID and an assignee address. Only the contract owner can perform this action.
- **Complete Task**: Enter the task ID and confirm to mark it complete. Either the owner or assigned address may succeed.
- **Event Log**: The right-hand panel streams Solidity events in real time when supported by the provider. After page reloads, past events are refetched from the blockchain.

## Troubleshooting

- **`hardhat` command not found**: ensure `npm install` completed successfully; the project relies on the local `hardhat` binary in `node_modules/.bin`.
- **MetaMask shows the wrong network**: add the Hardhat network manually (chain ID 31337, RPC URL `http://127.0.0.1:8545`).
- **`frontend/contract.json` missing or stale**: rerun `npm run deploy:local` or `npm run deploy:sepolia` to regenerate it before starting the frontend.
- **Sepolia deployment fails with `insufficient funds`**: verify the Sepolia account balance via an explorer and re-run the deploy after funding.

## Project Structure

```
contracts/TaskManager.sol   # Solidity smart contract
scripts/deploy.ts           # Hardhat deployment script writing frontend artifacts
test/TaskManager.ts         # Mocha/Chai tests
frontend/                   # Vite + Web3.js frontend
  index.html
  main.js
  style.css
  contract.json             # Generated ABI + address (created at deploy time)
.github/
  workflows/ci.yml          # GitHub Actions workflow (npm ci, compile, test)
  PULL_REQUEST_TEMPLATE.md  # Required sections for PRs
DEMO.md                     # Instructor-led classroom script
.env.example                # Placeholder environment variables for Sepolia
```

## License

MIT

