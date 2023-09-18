// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract IDO {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private token;
    uint256 private tokenPrice;
    uint256 private tokenAmount;
    uint256 private minBuyAmount;
    uint256 private maxBuyAmount;
    uint256 private startTime;
    uint256 private endTime;
    address payable private  owner;
    mapping(address => uint256) private balances;

    event BuyTokens(address indexed buyer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    constructor(
        IERC20 _token,
        uint256 _tokenPrice,
        uint256 _tokenAmount,
        uint256 _minBuyAmount,
        uint256 _maxBuyAmount,
        uint256 _startTime ,
        uint256 _endTime,
        address payable _owner
    ) {
        // require(_startTime >= block.timestamp, "Start time must be in the future.");
        // require(_endTime > _startTime, "End time must be after start time.");
        require(_minBuyAmount > 0, "Minimum buy amount must be greater than 0.");
        require(_maxBuyAmount > 0 && _maxBuyAmount >= _minBuyAmount, "Maximum buy amount must be greater than 0 and greater than or equal to minimum buy amount.");

        token = _token;
        tokenPrice = _tokenPrice;
        tokenAmount = _tokenAmount;
        minBuyAmount = _minBuyAmount;
        maxBuyAmount = _maxBuyAmount;
        startTime =block.timestamp +_startTime;
        endTime = block.timestamp+_endTime;
        owner = _owner;
    }
/////////////////////////show methode //////////////////////////////////////////////


 function showToken()view public returns(IERC20){
        return token;
    }
     function showTokenPrice()view public returns(uint256){
        return tokenPrice;
    }
     function showAmount()view public returns(uint256){
        return tokenAmount;
    }
     function showStartTime()view public returns(uint256){
        return startTime;
    }
     function showEndTime()view public returns(uint256){
        return endTime;
    }
     function showBalance(address account)view public returns(uint256){
        return balances[account];
    }
        function showOwner()view public returns(address){
        return owner;
    }
 function timestamp()view public returns(uint256){
        return block.timestamp;
    }
/////////////////////////change methode //////////////////////////////////////////////
    function changeOwner(address payable ownerAddress)  public onlyOwner {
        owner = ownerAddress;
    }
    function changeSupply(uint256 newAmount)  public onlyOwner {
       tokenAmount = newAmount ;
    }
    function buyTokens(uint256 _amount) public payable {
        require(block.timestamp >= startTime, "IDO has not started yet.");
        require(block.timestamp <= endTime, "IDO has ended.");
        require(_amount >= minBuyAmount, "Amount is less than minimum buy amount.");
        require(_amount <= maxBuyAmount, "Amount is greater than maximum buy amount.");
        require(balances[msg.sender].add(_amount) <= maxBuyAmount, "Total buy amount exceeds maximum buy amount.");
require(msg.value >= _amount*tokenPrice ,"you have to sent eth to contract");
  
        require(token.balanceOf(address(this)) >= _amount, "Not enough tokens in contract.");

        balances[msg.sender] = balances[msg.sender].add(_amount);
        token.safeTransfer(msg.sender, _amount);
        tokenAmount = tokenAmount- _amount;
        emit BuyTokens(msg.sender, _amount);
    }

    function withdrawTokens() public onlyOwner {
        require(block.timestamp > endTime, "IDO has not ended yet.");

        uint256 tokensRemaining = token.balanceOf(address(this));
        require(tokensRemaining > 0, "No tokens left in contract.");

        token.safeTransfer(owner, tokensRemaining);
    }

    function withdrawFunds() public onlyOwner {
        require(block.timestamp > endTime, "IDO has not ended yet.");

        uint256 totalFunds = address(this).balance;
        require(totalFunds > 0, "No funds left in contract.");

        payable(owner).transfer(totalFunds);
    }
   
}