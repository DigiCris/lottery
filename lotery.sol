// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

interface myToken
{
    function balanceOf(address _address) external view returns(uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function decimals() external view returns (uint8);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}


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

    myToken private myTokenContract;

    modifier rightPrice()
    {
        require(myTokenContract.balanceOf(msg.sender) >= price,"You don't have enaugh tickets to play");
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
        require( ( myTokenContract.balanceOf(address(this)) )==0,"The contract is full of money");
        _;
    }

    constructor(uint256 _price, uint8 _playerAmount, uint256 _preSetValue,address _AddrContract)
    {
        price=_price;
        gameOver=false;
        owner= msg.sender;
        playerAmount=_playerAmount;
        counter=0;
        HashPreSetValue= hashValue(_preSetValue);
        round=0;

        myTokenContract=myToken(_AddrContract);

        emit roundEvent(round,"Hashed",HashPreSetValue);
    }

    function hashValue(uint256 _value) private pure returns(uint256)
    {
        return( uint256(keccak256(abi.encode(_value))) );
    }

    function play() public rightPrice EndGame(false)
    { 
        uint256 balanceAux;
        balanceAux=myTokenContract.balanceOf(address(this));
        myTokenContract.transferFrom(msg.sender,address(this), price);
        require( myTokenContract.balanceOf(address(this)) > balanceAux, "Why don't I have more tokens?" );

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
        require(counter<=playerAmount, "If counter is greater than playerAmount means there was a problem");
        uint256 winnerNumber=uint256(keccak256(abi.encode(randomNumber,preSetValue))) % playerAmount;
        address payable winnerAddress;
        winnerAddress= payable( ticketNumber[winnerNumber] );
        while(winnerAddress==address(0x0))
        {
            preSetValue--;
            winnerNumber=uint256(keccak256(abi.encode(randomNumber,preSetValue))) % playerAmount;
            winnerAddress= payable( ticketNumber[winnerNumber] );
        }
        uint256 amountToWinner;
        amountToWinner=(  ( myTokenContract.balanceOf(address(this)) ) * 8  ) / 10;
        require( amountToWinner < ( myTokenContract.balanceOf(address(this)) ), "Something is not right with the give-away calculation" );
        amountToWinner=mul(amountToWinner,uint256(10)**myTokenContract.decimals());
        require( myTokenContract.transfer(winnerAddress, amountToWinner) );
        address payable ownerPayable;
        ownerPayable= payable(owner);
        myTokenContract.transfer(ownerPayable, myTokenContract.balanceOf(address(this)));
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

    function hardFaultReset(uint256 _price, uint8 _playerAmount, uint256 _preSetValue) public onlyOwner
    {
        price=_price;
        gameOver=false;
        playerAmount=_playerAmount;
        counter=0;
        HashPreSetValue= hashValue(_preSetValue);
        round++;
        emit roundEvent(round,"Hashed",HashPreSetValue);
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
        if(a==0)
        {
            return 0;
        }
        uint256 c=a*b;
        require((c/a)==b);
        return(c);
    }

    event roundEvent(uint32 _roundNumber, string _presetValue, uint256 _number);
    event playEvent(uint32 _roundNumber, address _player, uint256 _timestamp);
}