// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

interface myToken
{
    function balanceOf(address _address) external view returns(uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function decimals() external view returns (uint8);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}

contract TokenSale
{ 
    address private owner;
    uint64 private price;
    myToken private myTokenContract;

    constructor(address _AddrContract, uint64 _price)
    {
        owner=msg.sender;
        if(_price!=0)
            price=_price;
        else
            price=1000000000000000000;

        myTokenContract=myToken(_AddrContract);
    }

    modifier only_owner()
    {
        require(msg.sender==owner);
        _;
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

    function buy(uint256 _numTokens) public payable
    {
        require(msg.value==mul(_numTokens,price));
        uint256 scaledAmount=mul(_numTokens,uint256(10)**myTokenContract.decimals());
        require( myTokenContract.balanceOf(address(this)) >=scaledAmount );
        require( myTokenContract.transfer(msg.sender, scaledAmount) );
        emit Sold(msg.sender,_numTokens);
    }

    function sell(uint256 _numTokens) public payable
    {
        uint256 balanceAux;
        balanceAux=myTokenContract.balanceOf(address(this));
        myTokenContract.transferFrom(msg.sender,address(this), _numTokens);
        require( myTokenContract.balanceOf(address(this)) > balanceAux );
        uint256 _value;
        uint256 _price;
        _price=price/10;
        _value=mul(mul(_numTokens,_price),8);
        address payable him;
        him=payable(msg.sender);
        him.transfer(_value);
        emit Bought(msg.sender,_numTokens);
    }
    
    function endSold() only_owner public
    {
        require( myTokenContract.transfer(owner, myTokenContract.balanceOf(address(this))) );
        address payable me;
        me=payable(msg.sender);
        me.transfer(address(this).balance);
    }

    event Sold(address buyer, uint256 amount);
    event Bought(address seller, uint256 amount);

}