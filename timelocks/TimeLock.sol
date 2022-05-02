// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Timelock {
    function queue() external {}
    function execute() external {}

}

contract TestTimeLock {
    address public timeLock;

    constructor(address _timeLock) {
        timeLock = _timeLock;
    }
    function test() external {
        require(msg.sender == timeLock);
    }
}