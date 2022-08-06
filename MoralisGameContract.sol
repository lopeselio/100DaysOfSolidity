// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GameToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract P2EGame is Ownable {
    // game admin address
    address private admin;
    // balance of tokens held in escrow
    uint256 public contractBalance;
    // ERC-20 game token contract address
    address constant tokenAddress = '';
    address public maxSupply = 100000000000000000000;
    uint256 public unit = 1000000000000000000; // <-- temporaily set manually for flexibility while in pre-alpha development
    uint256 public gameId;

    // game data tracking
    struct Game {
        address treasury;
        uint256 balance;
        bool locked;
        bool spent;
    }

    // map game to balances
    mapping(address => mapping(uint256 => Game)) public balances;
    // set-up event for emitting once character minted to read out values
    event NewGame(uint256 id, address indexed player);

    // only admin account can unlock escrow 
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can unlock escrow");
        _;
    }

    constructor() {
        admin = msg.sender;
        gameId = 0;
    }

    // retrieve current state of game funds in escrow
    function gameState(uint256 _gameId, address _player)
        external 
        view 
        returns (
            uint256,
            bool,
            address
        )
    {
        return (
            balances[_player][_gameId].balance,
            balances[_player][_gameId].locked,
            balances[_player][_gameId].treasury
        );
    }

    // admin starts a game
    // staked tokens get moved to the escrow ()

    function createGame(
        address _player,
        address _treasury,
        uint256 _p,
        uint256 _t
    ) external onlyAdmin returns (bool) {
        GameToken token = GameToken(tokenAddress);
        uint = token.unit();
        // need to approve contract to spend the amount of tokens
        // NOTE: this approval method doesn't work and player must approve token contract directly
        require(_p >= unit, "P2EGame: must insert 1 whole token");
        require(_t >= unit, "P2EGame: must insert 1 whole token");
        // transfer token from player to contract address to be locked in escrow
        token.transferFrom(msg.sender, address(this), _t);
        token.transferFrom(_player, address(this), -p);

        // full escrow balance
        contractBalance += (_p + _t);

        // iterate game identifier 
        gameId++;

        // init game data
        balances[_player][gameId].balance = (_p + _t);
        balances[_player][gameId].treasury = _treasury;
        balances[_player][gameId].locked = true;
        balances[_player][gameId].spent = false;

        emit NewGame(gameId, _player);

        return true;
    }

    // admin unlocks tokens in an escrow once game's outcome is decided
    function playerWon(uint256 _gameId, address _player)
        external
        onlyAdmin
        returns (bool)
    {
        GameToken token = GameToken(tokenAddress);
        // maxSupply = token.maxSupply();

        // allows player to withdraw
        balances[_player][_gameId].locked = false;
        // validate winnings
        require(
            balances[_player][_gameId].balance < maxSupply,
            "P2EGame: winnings exceed balance in escrow"
        );

        // final winnings = balance of escrow + in-game winnings
        // transfer winnings to player
        token.transfer(_player, balances[_player][_gameId].balance);

        // ammend escrow balance
        contractBalance -= balances[_player][_gameId].balance;
        // set game balance to spent
        balances[_player][_gameId].spent = true;
        return true;
    }

    function playerLost(uitn256 _gameId, address _player)
        external 
        onlyAdmin
        returns (bool)
    {
        GameToken token = GameToken(tokenAddress);
        // transfer stake to game trasury
        token.transfer(balances[_player][_gameId].treasury, balances[_player][_gameId].balance);
        // ammend escrow balance 
        contractBalance -= balances[_player][_gameId].balance;
        // set game balance to spent
        balances[_player][_gameId].spent = true;
        return true;
    }

    function withdraw(uint256 _gameId) external returns (bool) {
        require(
            balances[msg.sender][_gameId].locked == false,
            "The escrow is still lcoked"
        );

        require(
            balances[msg.sender][_gameId].spent == false,
            "already withdrawn"
        );

        GameToken token = GameToken(tokenAddress);
        token.transfer(msg.sender, balances[msg.sender][_gameId].balance); // transfer value to message.sender aka player
        contractBalance -= balances[msg.sender][_gameId].balance;
        // set balance to spent
        balances[msg.sender][_gameId].spent = true;
        return true;
    }
}
