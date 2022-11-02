// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.8;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

contract FundMe {

    uint256 public minimumUsd = 50;
    function fund() public payable {
        require(msg.value >= minimumUsd, "Didn't send enough funds!"); // 1e18 = 1 * 10 ** 18 ETH
    }

    function getPrice() public {
        // ABI
        // Address of oracle ETH/USD 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
    }

    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        return priceFeed.version();
    }

    function getConversionRate() public {

    }
}