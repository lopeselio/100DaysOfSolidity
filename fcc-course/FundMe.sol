// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.8;

conract FundMe {

    uint256 public minimumUsd = 50;
    function fund() public payable {
        
        require(msg.value >= minimumUsd, "Didn't send enough funds!"); // 1e18 = 1 * 10 ** 18 ETH

    }
}