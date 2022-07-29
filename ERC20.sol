// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;


contract myToken
{
    //function name() public view returns (string);    
    string public name;
    //function symbol() public view returns (string);
    string public symbol;
    //function decimals() public view returns (uint8);
    uint8 public decimals;
    //function totalSupply() public view returns (uint256);
    uint256 public totalSupply;
    //function balanceOf(address _owner) public view returns (uint256 balance);
    mapping(address => uint256) public balanceOf;
    //function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply)
    {// (ticket, tck, 0, 1000)
        name=_name;
        symbol=_symbol;
        decimals=_decimals;
        totalSupply=_totalSupply;
        balanceOf[msg.sender]=_totalSupply * (10 ** decimals);
    }

    function transfer(address _to, uint256 _value) public returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value,"You have not enaugh tokens for the transaction");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return(true);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
    {
        require(allowance[_from][msg.sender] >= _value);
        require(balanceOf[_from] >= _value);
        allowance[_from][msg.sender] -= _value;
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return(true);
    }

    function approve(address _spender, uint256 _value) public returns (bool success)
    {
        allowance[msg.sender][_spender]=0;
        allowance[msg.sender][_spender]=_value;
        emit Approval(msg.sender, _spender, _value);
        return(true);
    }
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}