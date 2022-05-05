// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Timelock {
    error NotOwnerError(); // pending
    error AlreadyQueuedError(bytes32 txId);
    error TimestampNotInRangeError(bytes32 blockTimestamp, uint timestamp);

    event Queue (
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );
    uint public constant MIN_DELAY = 10;
    uint public constant MAX_DELAY = 1000;
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
        if(
            _timestamp < block.timestamp + MIN_DELAY ||
            _timestamp > block.timestamp + MAX_DELAY
        ) {
            revert TimestampNotInRangeError(block.timestamp, _timestamp);
        }
        // queue tx
        queued[txId] = true;

        emit Queue (
            txId, _target, _value, _func, _data, _timestamp
        );
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