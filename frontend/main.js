import Web3 from "web3";
import contractInfo from "./contract.json";

const state = {
  web3: null,
  contract: null,
  accounts: [],
  eventsSubscribed: false
};

const connectButton = document.getElementById("connectWallet");
const walletStatus = document.getElementById("walletStatus");
const contractAddressEl = document.getElementById("contractAddress");
const tasksBody = document.getElementById("tasksBody");
const eventsContainer = document.getElementById("events");

contractAddressEl.textContent = contractInfo.address || "Deploy the contract locally";

const forms = {
  create: document.getElementById("createTaskForm"),
  assign: document.getElementById("assignTaskForm"),
  complete: document.getElementById("completeTaskForm")
};

connectButton.addEventListener("click", async () => {
  try {
    await connectWallet();
  } catch (error) {
    console.error(error);
    setStatus(`Connection failed: ${error.message ?? error}`);
  }
});

async function connectWallet() {
  if (!window.ethereum) {
    setStatus("Install MetaMask to interact with the demo");
    return;
  }

  state.accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
  state.web3 = new Web3(window.ethereum);

  if (!contractInfo.address) {
    setStatus("Deploy the contract and refresh the page");
    return;
  }

  state.contract = new state.web3.eth.Contract(contractInfo.abi, contractInfo.address);
  setStatus(`Connected as ${shorten(state.accounts[0])}`);
  contractAddressEl.textContent = contractInfo.address;

  if (!state.eventsSubscribed) {
    subscribeToEvents();
    state.eventsSubscribed = true;
  }

  await loadTasks();
  await loadEvents();

  window.ethereum.on("accountsChanged", (accounts) => {
    state.accounts = accounts;
    if (accounts.length === 0) {
      setStatus("Wallet disconnected");
    } else {
      setStatus(`Connected as ${shorten(accounts[0])}`);
    }
  });
}

async function loadTasks() {
  if (!state.contract) {
    return;
  }
  try {
    const [tasks, ids] = await Promise.all([
      state.contract.methods.listTasks().call(),
      state.contract.methods.getTaskIds().call()
    ]);

    tasksBody.innerHTML = "";
    ids.forEach((id, index) => {
      const task = tasks[index];
      const row = document.createElement("tr");
      row.innerHTML = `
        <td>${id}</td>
        <td>${task.title}</td>
        <td>${task.description}</td>
        <td>${task.assignee === "0x0000000000000000000000000000000000000000" ? "Unassigned" : shorten(task.assignee)}</td>
        <td><span class="badge ${task.completed ? "closed" : "open"}">${task.completed ? "Completed" : "Open"}</span></td>
      `;
      tasksBody.appendChild(row);
    });
  } catch (error) {
    console.error("Failed to load tasks", error);
    setStatus("Could not load tasks. Check console for details.");
  }
}

function subscribeToEvents() {
  if (!state.contract) return;

  const options = { fromBlock: "latest" };

  state.contract.events.TaskCreated(options).on("data", (event) => {
    renderEvent("TaskCreated", event.returnValues);
    loadTasks();
    loadEvents();
  });

  state.contract.events.TaskAssigned(options).on("data", (event) => {
    renderEvent("TaskAssigned", event.returnValues);
    loadTasks();
    loadEvents();
  });

  state.contract.events.TaskCompleted(options).on("data", (event) => {
    renderEvent("TaskCompleted", event.returnValues);
    loadTasks();
    loadEvents();
  });
}

async function loadEvents() {
  if (!state.contract) return;
  try {
    const events = await state.contract.getPastEvents("allEvents", {
      fromBlock: 0,
      toBlock: "latest"
    });
    eventsContainer.innerHTML = "";
    [...events].reverse().forEach((evt) => {
      renderEvent(evt.event ?? "Event", evt.returnValues, false);
    });
  } catch (error) {
    console.error("Failed to load events", error);
  }
}

function renderEvent(type, payload, prepend = true) {
  const container = document.createElement("div");
  container.className = "event-row";
  const lines = Object.entries(payload)
    .filter(([key]) => isNaN(Number(key)))
    .map(([key, value]) => `<strong>${key}</strong>: ${value}`)
    .join("<br/>");
  container.innerHTML = `<strong>${type}</strong><br/>${lines}`;
  if (prepend) {
    eventsContainer.prepend(container);
  } else {
    eventsContainer.appendChild(container);
  }
}

forms.create.addEventListener("submit", async (event) => {
  event.preventDefault();
  if (!state.contract) {
    setStatus("Connect your wallet first");
    return;
  }
  const title = document.getElementById("createTitle").value.trim();
  const description = document.getElementById("createDescription").value.trim();
  try {
    setStatus("Submitting create transaction...");
    await state.contract.methods.createTask(title, description).send({ from: state.accounts[0] });
    setStatus("Task created ✅");
    event.target.reset();
    await loadTasks();
    await loadEvents();
  } catch (error) {
    console.error(error);
    setStatus(`Create failed: ${error.message ?? error}`);
  }
});

forms.assign.addEventListener("submit", async (event) => {
  event.preventDefault();
  if (!state.contract) {
    setStatus("Connect your wallet first");
    return;
  }
  const id = document.getElementById("assignId").value;
  const address = document.getElementById("assignAddress").value.trim();
  try {
    setStatus("Submitting assign transaction...");
    await state.contract.methods.assignTask(id, address).send({ from: state.accounts[0] });
    setStatus("Task assigned ✅");
    event.target.reset();
    await loadTasks();
    await loadEvents();
  } catch (error) {
    console.error(error);
    setStatus(`Assign failed: ${error.message ?? error}`);
  }
});

forms.complete.addEventListener("submit", async (event) => {
  event.preventDefault();
  if (!state.contract) {
    setStatus("Connect your wallet first");
    return;
  }
  const id = document.getElementById("completeId").value;
  try {
    setStatus("Submitting completion...");
    await state.contract.methods.completeTask(id).send({ from: state.accounts[0] });
    setStatus("Task completed ✅");
    event.target.reset();
    await loadTasks();
    await loadEvents();
  } catch (error) {
    console.error(error);
    setStatus(`Complete failed: ${error.message ?? error}`);
  }
});

function setStatus(message) {
  walletStatus.textContent = message;
}

function shorten(address) {
  if (!address) return "";
  return `${address.slice(0, 6)}…${address.slice(-4)}`;
}

if (window.ethereum && contractInfo.address) {
  // Attempt eager connection for convenience during demos
  connectWallet().catch((err) => console.debug("Eager connect skipped", err));
}
