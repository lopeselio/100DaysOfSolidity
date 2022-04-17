// SPDX-License-Identifier: MIT

//Dutch auction involves an auction, where a product is auctioned at a starting price and the price continuously decresases over the duration of time at a fixed discount rate and the auction ends as soon as someone buys the product at the discounted price. Following is the code for a Dutch-Auction for an NFT
pragma solidity ^0.8.10;

interface IERC721 {
    function transferFrom (
        address _from,
        address _to,
        uint _nftId
    ) external;
}

contract DutchAuction {
    uint private constant DURATION = 7 days;
    IERC721 public immutable nft;
    uint public immutable nftId;

    address payable public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable expiresAt;
    uint public immutable discountRate;

    constructor (
        uint _startingPrice,
        uint _discountRate,
        address _nft,
        uint _nftid,
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;

        require(
            _startingPrice >= _discountRate * DURATION,
            "starting price is less than discount"
        )
        nft = IERC721(_nft);
        nftId = _nftId;

    }
}
