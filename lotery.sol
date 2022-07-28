// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

contract lotery
{
    mapping(address => uint256) public timeStamp;
    mapping(uint256 => address) public ticketNumber;
    uint256 randomNumber;
    uint256 price;
    bool gameOver;
    address owner;
    uint8 playerAmount;
    uint8 counter;
    uint256 HashPreSetValue;
    uint32 round;

    modifier rightPrice()
    {
        require(price==msg.value,"The money you are sending is just not right");
        _;
    }
    modifier EndGame(bool _comp)
    {
        require(gameOver==_comp, "The game should be over or still playable but it is just in the oposite state");
        _;
    }
    modifier onlyOwner()
    {
        require(owner==msg.sender, "Inteligent hacker, you are not the owner");
        _;
    }
    modifier rightWinner(uint256 _preSetValue)
    {
        require( (hashValue(_preSetValue))==HashPreSetValue,"The preset number you are sending is not right");
        _;
    }
    modifier balance0()
    {
        require( ( address(this).balance )==0,"The contract is full of money");
        _;
    }

    constructor(uint256 _price, uint8 _playerAmount, uint256 _preSetValue)
    {
        price=_price;
        gameOver=false;
        owner= msg.sender;
        playerAmount=_playerAmount;
        counter=0;
        HashPreSetValue= hashValue(_preSetValue);
        round=0;
        emit roundEvent(round,"Hashed",HashPreSetValue);
    }

    function hashValue(uint256 _value) private pure returns(uint256)
    {
        return( uint256(keccak256(abi.encode(_value))) );
    }

    function play() public rightPrice EndGame(false) payable
    { 
        counter++;
        timeStamp[msg.sender]=block.timestamp;
        ticketNumber[counter]=msg.sender;
        randomNumber=randomNumber+timeStamp[msg.sender];
        if(counter==playerAmount)
        {
            gameOver=true;
        }
        emit playEvent(round, msg.sender, timeStamp[msg.sender]);
    }

    function pickWinner(uint256 preSetValue) private EndGame(true) onlyOwner rightWinner(preSetValue) returns(address)
    {
        uint256 winnerNumber=uint256(keccak256(abi.encode(randomNumber,preSetValue))) % playerAmount;
        address payable winnerAddress;
        winnerAddress= payable( ticketNumber[winnerNumber] );
        uint256 amountToWinner;
        amountToWinner=(  ( address(this).balance ) * 8  ) / 10;
        require( amountToWinner < ( address(this).balance ), "Something is not right with the give-away calculation" );
        winnerAddress.transfer(amountToWinner);
        address payable ownerPayable;
        ownerPayable= payable(owner);
        ownerPayable.transfer(address(this).balance);
        return(winnerAddress);
    }

    function finishGame(uint256 _preSetValue) public onlyOwner rightWinner(_preSetValue) returns(address)
    {
        gameOver=true;
        address winner=pickWinner(_preSetValue);
        emit roundEvent(round,"unhashed",_preSetValue);
        return(winner);
    }

    function startGame(uint256 _price, uint8 _playerAmount, uint256 _preSetValue) public onlyOwner EndGame(true) balance0
    {
        price=_price;
        gameOver=false;
        playerAmount=_playerAmount;
        counter=0;
        HashPreSetValue= hashValue(_preSetValue);
        round++;
        emit roundEvent(round,"Hashed",HashPreSetValue);
    }

    event roundEvent(uint32 _roundNumber, string _presetValue, uint256 _number);
    event playEvent(uint32 _roundNumber, address _player, uint256 _timestamp);
}