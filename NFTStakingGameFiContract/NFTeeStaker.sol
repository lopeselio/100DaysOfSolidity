// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

contract NFTeeStaker is ERC20, ReentrancyGuard {
    // What do we need ?

    // a way for people to stake 1 or more nfts

    // every 24 hours they should be getting 100 tokens - prorated
    
    // Unstake

    // Claim those tokens

    // --

    // NFTee comtract : transfer NFTs in & out
    // struct Staker 

    IERC721 nftContract;
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant BASE_YIELD_RATE = 1000 ether; // 1 ether = 10**18
    struct Staker {
        // X number of tokens every 24 hours
        uint256 currYield;
        // how many tokens they have accumulated but not claimed so far
        uint256 rewards;
        // when was the last time rewards were calculated on-chain
        uint256 lastCheckpoint;
        // which NFTs were staked
        // uint256[] stakedNFTs; 
    }
    mapping(address => Staker) public stakers;
    mapping(uint256 => address) public tokenOwners;
    constructor(
        address _nftContract, 
        string memory name, 
        string memory symbol
    ) ERC20(name, symbol) {
        nftContract = IERC721(_nftContract);
    }

    function stake(uint256[] memory tokenIds) public {
        Staker storage user = stakers[msg.sender];
        uint256 yield = user.currYield;
        uint256 length = tokenIds.length;
        for(uint256 i=0; i<length; i++) {
            require(
                nftContract.ownerOf(tokenIds[i]) == msg.sender, 
                "Not an owner"
            );
            nftContract.safeTransferFrom(
                msg.sender, 
                address(this), 
                tokenIds[i]
            );
            tokenOwners[tokenIds[i]] = msg.sender;
            yield += BASE_YIELD_RATE;
            // user.stakedNFTs.push(tokenIds[i]);

        }
        accumulate(msg.sender);
        user.currYield = yield;
    }

    function unstake(uint256[] memory tokenIds) public {
        Staker storage user = stakers[msg.sender];
        uint256 yield = user.currYield;
        uint256 length = tokenIds.length;
        for(uint256 i=0; i<length; i++) {
            require (
                tokenOwners[tokenIds[i]] == msg.sender,
                "NOT ORIGINAL OWNER"
            );
            require(nftContract.ownerOf(tokenIds[i])== address(this),
            "NFT IS NOT STAKED"
            );

            tokenOwners[tokenIds[i]] = address(0);

            if(yield != 0) {
                yield -= BASE_YIELD_RATE;
            }

            nftContract.safeTransferFrom(address(this), msg.sender, tokenIds[i]);
        }
        accumulate(msg.sender);
        user.currYield = yield;

    }

    function claim() public nonReentrant {
        Staker storage user = stakers[msg.sender];
        accumulate(msg.sender);

        _mint(msg.sender, user.rewards);
        user.rewards = 0;
    }

    function accumulate(address staker) internal {
        stakers[staker].rewards += getRewards(staker);
        stakers[staker].lastCheckpoint = block.timestamp;

    }

    function getRewards(address staker) public view returns (uint256) {
        Staker memory user = stakers[staker];
        if(user.lastCheckpoint == 0) {
            return 0;
        }

        return ((block.timestamp - user.lastCheckpoint) * user.currYield)/SECONDS_PER_DAY;
    }

}


