// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;
import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= minimumUsd, "Didn't send enough funds!"); // 1e18 = 1 * 10 ** 18 ETH
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }



    function withdraw() public onlyOwner {
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex = funderIndex + 1) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }

    modifier onlyOwner {
        require(msg.sender == owner, "Sender is not the owner");
        _;
    }
}