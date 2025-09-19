import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";

describe("TaskManager", function () {
  async function deployTaskManagerFixture() {
    const [owner, assignee, otherUser] = await ethers.getSigners();
    const TaskManager = await ethers.getContractFactory("TaskManager");
    const taskManager = await TaskManager.deploy();
    await taskManager.waitForDeployment();

    return { taskManager, owner, assignee, otherUser };
  }

  describe("createTask", function () {
    it("creates a task with metadata and tracks ids", async function () {
      const { taskManager, owner } = await loadFixture(deployTaskManagerFixture);

      await expect(taskManager.connect(owner).createTask("Lesson plan", "Outline the smart contract demo"))
        .to.emit(taskManager, "TaskCreated")
        .withArgs(1n, owner.address, "Lesson plan");

      const storedTask = await taskManager.getTask(1n);
      expect(storedTask.title).to.equal("Lesson plan");
      expect(storedTask.description).to.equal("Outline the smart contract demo");
      expect(storedTask.creator).to.equal(owner.address);
      expect(storedTask.completed).to.equal(false);

      const ids = await taskManager.getTaskIds();
      expect(ids).to.deep.equal([1n]);
    });

    it("reverts when title is empty", async function () {
      const { taskManager, owner } = await loadFixture(deployTaskManagerFixture);

      await expect(taskManager.connect(owner).createTask("", ""))
        .to.be.revertedWith("Title required");
    });
  });

  describe("assignTask", function () {
    it("allows only the owner to assign tasks", async function () {
      const { taskManager, owner, assignee, otherUser } = await loadFixture(deployTaskManagerFixture);
      await taskManager.createTask("Ship", "Deploy to Sepolia");

      await expect(taskManager.connect(otherUser).assignTask(1n, assignee.address))
        .to.be.revertedWithCustomError(taskManager, "OwnableUnauthorizedAccount")
        .withArgs(otherUser.address);

      await expect(taskManager.connect(owner).assignTask(1n, assignee.address))
        .to.emit(taskManager, "TaskAssigned")
        .withArgs(1n, assignee.address);

      const updated = await taskManager.getTask(1n);
      expect(updated.assignee).to.equal(assignee.address);
    });

    it("rejects zero address assignments", async function () {
      const { taskManager } = await loadFixture(deployTaskManagerFixture);
      await taskManager.createTask("Document", "Write README");

      await expect(taskManager.assignTask(1n, ethers.ZeroAddress))
        .to.be.revertedWithCustomError(taskManager, "InvalidAssignee");
    });
  });

  describe("completeTask", function () {
    it("allows the assignee to complete an assigned task", async function () {
      const { taskManager, assignee } = await loadFixture(deployTaskManagerFixture);
      await taskManager.createTask("Review", "Run through tests");
      await taskManager.assignTask(1n, assignee.address);

      await expect(taskManager.connect(assignee).completeTask(1n))
        .to.emit(taskManager, "TaskCompleted")
        .withArgs(1n, assignee.address);

      const finished = await taskManager.getTask(1n);
      expect(finished.completed).to.equal(true);
    });

    it("allows the owner to complete unassigned tasks", async function () {
      const { taskManager, owner } = await loadFixture(deployTaskManagerFixture);
      await taskManager.createTask("Polish", "Final walkthrough");

      await expect(taskManager.connect(owner).completeTask(1n))
        .to.emit(taskManager, "TaskCompleted")
        .withArgs(1n, owner.address);
    });

    it("reverts for unauthorized callers", async function () {
      const { taskManager, otherUser } = await loadFixture(deployTaskManagerFixture);
      await taskManager.createTask("Archive", "Wrap up artifacts");

      await expect(taskManager.connect(otherUser).completeTask(1n))
        .to.be.revertedWithCustomError(taskManager, "NotAuthorized")
        .withArgs(1n, otherUser.address);
    });

    it("reverts when re-completing a task", async function () {
      const { taskManager, owner } = await loadFixture(deployTaskManagerFixture);
      await taskManager.createTask("Slides", "Iterate deck");
      await taskManager.completeTask(1n);

      await expect(taskManager.connect(owner).completeTask(1n))
        .to.be.revertedWithCustomError(taskManager, "TaskAlreadyCompleted")
        .withArgs(1n);
    });
  });

  describe("views", function () {
    it("reverts on queries for missing tasks", async function () {
      const { taskManager } = await loadFixture(deployTaskManagerFixture);

      await expect(taskManager.getTask(42n))
        .to.be.revertedWithCustomError(taskManager, "TaskNotFound")
        .withArgs(42n);
    });

    it("lists all tasks with metadata", async function () {
      const { taskManager } = await loadFixture(deployTaskManagerFixture);
      await taskManager.createTask("Task A", "Alpha");
      await taskManager.createTask("Task B", "Beta");

      const tasks = await taskManager.listTasks();
      expect(tasks.length).to.equal(2);
      expect(tasks[0].title).to.equal("Task A");
      expect(tasks[1].title).to.equal("Task B");

      const ids = await taskManager.getTaskIds();
      expect(ids).to.deep.equal([1n, 2n]);
    });
  });
});
