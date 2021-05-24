// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.5.0;

import "./ethTempusClientRinkeby.sol";

contract EtherBank is EthTempusClient {
    address public owner;
    address public user;
    address[] public depositers;
    
    uint256 public counter;
    
    mapping(address => uint) public depositedBalance;
    mapping(address => bool) public hasDeposited;

    event etherDeposited(address depositer, uint ethAmount);
    event etherReturned(address depositer, uint ethAmount);
    
    constructor() public payable {
        owner = msg.sender;
    // In this example:
    // Schedule a call for 10 blocks after deploying (uint256)
    // Maximun gas to expend 200K (uint256) - the sytem uses only what the network requires (including fee of ~ 5 cents of dollar).
    // Aditional parameter to identify the call (uint256)  if not required, set to zero.  
    
        setCallrequest(block.number + 10, 200000, 0);    
        
    }

    
    function callBack(uint callId) public {
        // add here the code you want to execute
                
        // Return Eth to the Depositers after 10th block mining
        this.returnEth();
        
        counter = callId; 
        setCallrequest(block.number + 10, 200000, 0); // request another call in 10 blocks
    }

    
    function () public payable {}
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

/* 
    1. Anyone can depositEther to the EtherBank 
    2. DepositEther() function will deposit the Ether from user address 
    3. DepositEther() will save the balance and address of the depositers
*/

    function depositEther() public payable {
        user = msg.sender;
        uint amount = msg.value;
           
            depositers.push(user);
            // Eth is deposited to the contract 
            depositedBalance[user] += amount;
            hasDeposited[user] = true; 
            emit etherDeposited(user, amount);
    }
    
/*
    1. OnlyOwner can call returnEth() in order to return ethers to all the addresses
    2. returnEth() should be automated and can only be called from inside the contract
    3. If the etherBank Contract is deployed on rinkeby at Block : 0 
       Then 
       after 10 blocks are mined  ( 0 + 10 ) on the rinkeby testnet 
          => An automated scheduler should call the returnEth() function 
                from inside the deployed EtherBank smartContract
          => To return ethers deposited by the depositers
*/
    
    function returnEth() public {
        
        for (uint i=0; i<depositers.length; i++) {
            user = depositers[i];
            uint refundedAmount = depositedBalance[user];
            
            user.transfer(refundedAmount);
            depositedBalance[user] = 0;
            hasDeposited[user] = false;
            emit etherReturned(user, refundedAmount);
        }
    }
}
