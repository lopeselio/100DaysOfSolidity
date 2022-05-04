// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Timelock {
    error NotOwnerError(); // pending
    error AlreadyQueuedError(bytes32 txId);
    address owner;
    mapping(bytes32 => bool) public queued;
    constructor() {
        owner = msg.sender;
    }

    modifier OnlyOwner() {
        if(msg.sender != owner) {
            revert NotOwnerError();
        }
        _;
    }

    function getTxId(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) public pure returns(bytes32 txId) {
        return keccak256(
            abi.encode(_target, _value, _func, _data, _timestamp)
        );
    }
    function queue(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external OnlyOwner {
        // create tx id
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        // check if tx unique
        if (queued[txId]) {
            revert AlreadyQueuedError(txId);
        }
        // check timestamp
        // queue tx
    }
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