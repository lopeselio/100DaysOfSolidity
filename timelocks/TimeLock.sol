// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Timelock {
    error NotOwnerError(); // pending
    error AlreadyQueuedError(bytes32 txId);
    error TimestampNotInRangeError(bytes32 blockTimestamp, uint timestamp);
    error NotQueuedError(bytes32 txId);
    error TimestampNotPassedError(bytes32 blockTimestamp, uint timestamp);
    error TimestampExpiredError(bytes32 blockTimestamp, uint expiresAt);
    error TxFailedError();

    event Execute (
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp 
    );

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
    uint public constant GRACE_PERIOD = 1000;
    address owner;
    mapping(bytes32 => bool) public queued;
    constructor() {
        owner = msg.sender;
    }

    receive() external payable {

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
    function execute(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external payable OnlyOwner returns(bytes memory) {
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        // check if tx is queued
        if(!queued[txId]) {
            revert NotQueuedError(txId);
        }
        // check if block.timestamp > _timestamp
        if (block.timestamp < _timestamp){
            revert TimestampNotPassedError(block.timestamp, _timestamp);
        }
        if (block.timestamp > _timestamp + GRACE_PERIOD){
            revert TimestampExpiredError(block.timestamp, _timestamp + GRACE_PERIOD);
        }
        //delete the transaction from the queue
        queued[txId] = false;
        // execute the tx
        bytes memory data;
        if(bytes(_func).length > 0){
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data
            );
        } else {
            data = _data;
        }
        (bool ok, bytes memory res) = _target.call{value: _value}(data);
        if(!ok) {
            revert TxFailedError();
        }
        emit Execute (
            txId, _target, _value, _func, _data, _timestamp
        );
        return res;
    }

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