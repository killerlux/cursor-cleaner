# Live Demo Script: Web3 Task Manager (20–25 minutes)

> Audience: instructors walking a classroom through an end-to-end Web3 workflow using Hardhat, Solidity, and a vanilla JS frontend.

## 0. Prep (Before Going Live)
- Terminal tab 1: project root.
- Terminal tab 2: ready to run `npm run dev --prefix frontend` later.
- Make sure MetaMask is pointed at the Hardhat local network (chainId 31337) and has at least one funded account.
- Optional: run `npm config set progress false` to avoid spinner noise (already handled in repo).

## 1. Welcome & Goals (2 min)
- Slide/intro: "We are building a Web3 Task Manager in real time."
- Highlight takeaways: smart contract with access control, automated testing, deployment, and a browser UI.
- Mention repo structure briefly (contract, scripts, frontend, CI).

## 2. Contract Walkthrough (5 min)
- Open `contracts/TaskManager.sol`.
- Emphasize security patterns:
  - Ownable constructor with `msg.sender` as initial owner.
  - CEI flow in `assignTask` and `completeTask`.
  - Custom errors for gas-efficient revert reasons.
  - Events broadcast state changes for the frontend.
- Mention helper views `listTasks` & `getTaskIds` for indexing.

## 3. Test-Driven Confidence (4 min)
- Run compile + tests:
  ```bash
  npm run compile
  npm test
  ```
- Narrate fixtures via `loadFixture` and coverage of revert paths.
- Point out how tests assert events and custom errors (`OwnableUnauthorizedAccount`, `TaskNotFound`, etc.).

## 4. Local Deployment (3 min)
- If not already running, start the local node in a background tab:
  ```bash
  npm run dev:node
  ```
- Deploy the contract:
  ```bash
  npm run deploy:local
  ```
- Call out console output (deployer + address) and confirm `frontend/contract.json` is refreshed with ABI/address/metadata.
- Copy the contract address to share with the audience.

## 5. Frontend Walkthrough (6 min)
- Install deps (first run only):
  ```bash
  npm install --prefix frontend
  ```
- Start Vite dev server:
  ```bash
  npm run dev --prefix frontend
  ```
- In the browser:
  - Connect wallet (MetaMask prompt).
  - Create a task (e.g., "Prep slides").
  - Assign the task to another account (owner-only guard) and show the revert message if you try from a non-owner account.
  - Complete the task with the assignee account.
  - Highlight the live-updating task table and event log (past events + subscriptions).
- Mention the UI structure in `frontend/index.html` and `frontend/main.js`, focusing on Web3.js v4 usage and event polling fallback.

## 6. Optional: Sepolia Deployment (3 min)
- Explain environment setup using `.env` with `SEPOLIA_RPC_URL` + `PRIVATE_KEY` (show `.env.example`).
- **TODO for live class**: populate `.env` with instructor-owned credentials before running `npm run deploy:sepolia`.
- After deployment, rerun the frontend pointing MetaMask at Sepolia and repeat the task flow.

## 7. CI & Git Hygiene (2 min)
- Open `.github/workflows/ci.yml` to show automated compile/test on push/PR.
- Demo PR template quickly for student contributions.
- Mention Conventional Commit history used while bootstrapping (`feat`, `test`, `docs`, etc.).

## 8. Q&A / Wrap (2 min)
- Recap the flow from Solidity contract → tests → deployment → frontend.
- Invite students to extend features (task deadlines, filtering, etc.).
- Share resources: Hardhat docs, Web3.js v4 migration guide, OpenZeppelin library.
