//SPDX-License-Identifier: Unlicensed

pragma solidity >0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 

contract Maringo is ERC20 {

    uint256 public _totalSupply;
    mapping (address => uint256) private _balances;
    
    uint256 reflectionFee = 2; //2% for every buy and sell transaction
    uint256 marketingFee = 3; //Marketing: 3%
    uint256 totalFee = 5; //total Fee to charge
    uint256 _denominator = 100;
    
    mapping(address => int64) dumpCounter; // a counter for the number of sell order before a user can sell all their coins
    
    constructor() ERC20("MARINGO", "MGO") {
        _totalSupply = 270000000 * 10**18;
        _mint(msg.sender, _totalSupply);
    }

    function transfer(address to, uint tokens) public virtual override returns (bool) {
        require(tokens <= balanceOf(msg.sender),"Insufficient Balance.");

        //place a sell order after 3 sells
        if(balanceOf(msg.sender) == tokens){
            dumpCounter[msg.sender] += 1; //increment counter for sell
            require(dumpCounter[msg.sender] == 3, "Transaction error");
        }
        
        dumpCounter[msg.sender] = 0; //reset sell count for seller

        uint256 amountReceived = takeFee(msg.sender,tokens);
        
        _transfer(msg.sender, to, amountReceived);
        return true;
    }

    function takeFee(address sender, uint256 amount) public virtual returns (uint256) {
        uint256 feeAmount = amount * (totalFee / _denominator);

        _transfer(sender, address(this), feeAmount);

        return amount - feeAmount;
    }
}