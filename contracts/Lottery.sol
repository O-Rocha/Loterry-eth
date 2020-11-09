pragma solidity ^0.6.12;
contract Lottery{
    
    uint LotteryEnd;
    uint NumberOfTickets;
    uint256 TicketPrice;
    uint NumberOfPlayers;
    uint BetTotal;
    uint LastEntry;
    address owner;
    
    //Marks the state of the game
    enum GameStatus {OnGoing, SoldOut, Finished}
    GameStatus public status;
    
    //builds an array with uint number as key
    //allows repetition of addresses
    mapping(uint => address payable)players;
    
    //sets the inicial parameters of the lottery
    constructor(uint _bettingPeriod, uint256 _tickPrice, uint _nOTickets) public {
        LotteryEnd = now + _bettingPeriod;
        TicketPrice = _tickPrice;
        NumberOfTickets = _nOTickets;
        BetTotal = 0;
        NumberOfPlayers = 0;
        LastEntry = 0;
        status = GameStatus.OnGoing;
        owner = msg.sender;
    }
    
    function getLoteryEnd() public view returns(uint){
        return LotteryEnd;
    }
    
    function getTicketPrice() public view returns(uint){
        return TicketPrice;
    }
    
    function getNumberOfPlayers() public view returns(uint){
        return NumberOfPlayers;
    } 
    
    function getPotTotal() public view returns(uint){
        return BetTotal;
    }
    
    function getNUmberOfTickets()public view returns(uint){
        return NumberOfTickets;
    }
    
    //attribues numbers on an array based on the ammount ou tickets bought
    function placeBet() public payable{
        if((msg.value < TicketPrice) || (now > LotteryEnd) || (!(status == GameStatus.OnGoing))){
            revert();
        }
        uint256 amountBought = uint256(msg.value) / uint256(TicketPrice); //make secure
        NumberOfTickets -= amountBought;
        
        for(uint i = LastEntry; i < (LastEntry + amountBought); i++){
            players[i] = msg.sender;
        }
        
        LastEntry += amountBought;
        
        BetTotal += msg.value;
        
        if(NumberOfTickets == 0){
            status = GameStatus.SoldOut;
        }
        NumberOfPlayers++;
    }
    
    function getRandomNumber() internal view returns(uint) {
        return 1;
        //TODO: find a way to generate a random number
    }
    
    function raffle() internal {
        uint randomWinner = getRandomNumber();
        address payable winner = players[randomWinner];
        winner.transfer(BetTotal);
        status = GameStatus.Finished;
    }
    
    function endLottery() public {
        if(msg.sender == owner && ( (!(status == GameStatus.OnGoing)) || (now < LotteryEnd) ) ){
            raffle();
        }
    }
    
    function resetLottery(uint _bettingPeriod, uint _tickPrice, uint _nOTickets) public {
        if(msg.sender == owner && (status == GameStatus.Finished)){
            LotteryEnd = now + _bettingPeriod;
            TicketPrice = _tickPrice;
            NumberOfTickets = _nOTickets;
            BetTotal = 0;
            NumberOfPlayers = 0;
            LastEntry = 0;
            status = GameStatus.OnGoing;
        }
    }
}
