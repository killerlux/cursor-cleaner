// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TaskManager is Ownable {
    struct Task {
        string title;
        string description;
        address creator;
        address assignee;
        bool completed;
    }

    event TaskCreated(uint256 indexed taskId, address indexed creator, string title);
    event TaskAssigned(uint256 indexed taskId, address indexed assignee);
    event TaskCompleted(uint256 indexed taskId, address indexed completedBy);

    error TaskNotFound(uint256 taskId);
    error InvalidAssignee();
    error TaskAlreadyCompleted(uint256 taskId);
    error NotAuthorized(uint256 taskId, address caller);

    mapping(uint256 => Task) private _tasks;
    uint256[] private _taskIds;
    uint256 private _taskIdTracker;

    constructor() Ownable(msg.sender) {}

    function createTask(string calldata title, string calldata description) external returns (uint256) {
        require(bytes(title).length > 0, "Title required");

        uint256 taskId = ++_taskIdTracker;
        Task storage task = _tasks[taskId];
        task.title = title;
        task.description = description;
        task.creator = msg.sender;
        task.assignee = address(0);
        task.completed = false;

        _taskIds.push(taskId);

        emit TaskCreated(taskId, msg.sender, title);
        return taskId;
    }

    function assignTask(uint256 taskId, address assignee) external onlyOwner {
        if (assignee == address(0)) {
            revert InvalidAssignee();
        }

        Task storage task = _requireTask(taskId);
        if (task.completed) {
            revert TaskAlreadyCompleted(taskId);
        }

        task.assignee = assignee;

        emit TaskAssigned(taskId, assignee);
    }

    function completeTask(uint256 taskId) external {
        Task storage task = _requireTask(taskId);
        if (task.completed) {
            revert TaskAlreadyCompleted(taskId);
        }

        address caller = msg.sender;
        if (caller != owner() && caller != task.assignee) {
            revert NotAuthorized(taskId, caller);
        }

        task.completed = true;

        emit TaskCompleted(taskId, caller);
    }

    function getTask(uint256 taskId) external view returns (Task memory) {
        Task storage task = _requireTask(taskId);
        return task;
    }

    function getTaskIds() external view returns (uint256[] memory) {
        return _taskIds;
    }

    function listTasks() external view returns (Task[] memory tasks_) {
        uint256 length = _taskIds.length;
        tasks_ = new Task[](length);
        for (uint256 i = 0; i < length; i++) {
            tasks_[i] = _tasks[_taskIds[i]];
        }
    }

    function totalTasks() external view returns (uint256) {
        return _taskIds.length;
    }

    function _requireTask(uint256 taskId) private view returns (Task storage task) {
        task = _tasks[taskId];
        if (task.creator == address(0)) {
            revert TaskNotFound(taskId);
        }
    }
}
