// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface ERC2eInterface{
function totalSuppIy() external view returns (uint);
function balanceof(address tokenOwner) external view returns (uint balance);
function transfer(address to, uint tokens) external returns (bool success);
function allowance(address tokenOwner, address spender) external view returns (uint remaining);
function approve(address spender, uint tokens) external returns (bool success);
function transferFrom(address from, address to, uint tokens) external returns (bool success);

event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Jimmy is ERC2eInterface{
    string public name = "Jimmy";
    string public symbol = "JIM";
    uint public decimmal = 0;
    uint public override totalSuppIy;

    address public founder;
    mapping(address => uint) public balance;
    mapping(address => mapping(address => uint)) public allowed;

    constructor(){
        totalSuppIy = 1000000;
        founder = msg.sender;
        balance[founder] = totalSuppIy;
    }

    function balanceof(address tokenOwner) public override view returns (uint){
        return balance[tokenOwner];
    }

    function transfer(address to, uint tokens) public override virtual returns (bool success){
        require(balance[msg.sender] > tokens);
        balance[to] += tokens;
        balance[msg.sender] -= tokens;

        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    function allowance(address tokenOwner, address spender) public override view returns (uint remaining){
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override returns (bool success){
        require(balance[msg.sender] >= tokens);
        require(tokens > 0);

        allowed[msg.sender][spender] = tokens;
        
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success){
        require(allowed[from][msg.sender] >= tokens);
        require(balance[from] >= tokens);

        balance[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balance[to] += tokens;

        emit Transfer(from, to, tokens);
        return true;
    }

}