
contract Raffle {
    uint256 public s_entranceFree = 10 gwei;
    address public s_recentWinner;
    address payable[] public s_players;
    
    function enterRaffle() public payable {
        require(msg.value == s_entranceFree, "Please send 10 gwei");
        s_players.push(payable(msg.sender));
    }
    
    function chooseWinner() public {
        uint256 randomWinner = 0;
        address payable winner = s_players[randomWinner];
        s_recentWinner = winner;
        (bool success,) = winner.call{value: address(this).balance}("");
        require(success, "Transfer to winner failed");
        delete s_players;
