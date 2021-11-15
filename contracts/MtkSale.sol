// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 ;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.0.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.0.0/contracts/access/Ownable.sol";
import "myTok.sol";
contract crowdSale{
    using SafeMath for uint256;
    uint256 public rate_1 = 454505;
    uint256 public rate_2 = 227252;
    uint256 public rate_3 = 70701;
    uint256 public limitTireOne = (30*10 **6)(10**token.decimals());
    uint256 public limitTireTwo = (50*10**6)(10**token.decimals());
    uint256 public limitTireThree = (20*10**6)(10**token.decimals());
    uint256 public icoStartTime;
    uint256 public icoEndTime;
    bool public icoCompleted;
    uint256 public fundingGoals;
    ICOToken public token;
    uint256 public tokenRate;
    address public owner;
    uint256 public tokenRaised;
    uint256 public ethRaised;
    
    modifier whenIcoCompleted{
        require(icoCompleted);
        _;
    }
    
    constructor ( uint256 _startIco , uint256 _endIco , uint256 _fundingGoals , address _tokenaddress , uint256 _tokenRate)public{
        require( _startIco!=0 &&
        _endIco!=0 &&
        _tokenRate!=0 &&
        _fundingGoals!=0 &&
        _tokenaddress !=0 &&
        _startIco<_endIco
            );
            
        icoStartTime= _startIco;
        icoEndTime= _endIco;
        fundingGoals=_fundingGoals;
        token=ICOToken(_tokenaddress);  //here we created an instance of that token in our Crowdsale contract with the address of the token that we’ll be using.
        tokenRate=_tokenRate; 
        owner= msg.sender;
    }
    
    
    function calculateExcessTokens(
      uint256 amount,
      uint256 tokensThisTier, // limitTire
      uint256 tierSelected, 
      uint256 _rate
    ) public returns(uint256 totalTokens) {
        
        
        require(amount > 0 && tokensThisTier > 0 && _rate > 0);
        require(tierSelected >= 1 && tierSelected <= 3);

        uint weiThisTier = tokensThisTier.sub(tokensRaised).div(_rate);
        uint weiNextTier = amount.sub(weiThisTier);
        uint tokensNextTier = 0;
        bool returnTokens = false;

        // If there's excessive wei for the last tier, refund those
        if(tierSelected != 3)
            tokensNextTier = calculateTokensTier(weiNextTier, tierSelected.add(1));
        else
            returnTokens = true;

        totalTokens = tokensThisTier.sub(tokensRaised).add(tokensNextTier);

        // Do the transfer at the end
        if(returnTokens) msg.sender.transfer(weiNextTier);
   }

    function calculateTokensTier(uint256 weiPaid, uint256 tierSelected)
        internal  returns(uint256 calculatedTokens)
    {
        require(weiPaid > 0);
        require(tierSelected >= 1 && tierSelected <= 4);

        if(tierSelected == 1)
            calculatedTokens = weiPaid.mul(rate_1);
        else if(tierSelected == 2)
            calculatedTokens = weiPaid.mul(rate_2);
        else if(tierSelected == 3)
            calculatedTokens = weiPaid.mul(rate_3);

   }

    
    
    
    
    
   
    function buy() public payable{
        require (tokenRaised < fundingGoals);
        require ( block.timestamp <icoEndTime && block.timestamp > icoStartTime);
        
        
        
        
    uint256 tokensToBuy;                          // will contain how many tokens the user is supposed to receive 
    uint256 etherUsed = msg.value;
    
    if (tokenRaised < limitTireOne){
        tokensToBuy= etherUsed * (10** tokens.decimals())/1 ether * rate_1;
        if (tokenRaised+tokensToBuy>limitTireOne){
            tokensToBuy= calculateExcessTokens(etherUsed,limitTireOne,1,rate_1);
        }
    } else if (tokenRaised>limitTireOne && tokenRaised<limitTireTwo ){
        tokensToBuy = etherUsed*(10**tokens.decimals())/1 ether * rate_2;
        if (tokenRaised+tokensToBuy>limitTireTwo){
            tokensToBuy= calculateExcessTokens(etherUsed, limitTireOne, 2, rate_2);
        }
    }else if(tokenRaised>=limitTireTwo){
        tokensToBuy= etherUsed*(10**tokens.decimals)/1 ether * rate_3;
    }
    
 
    //checking weather we have exceeded funding goals to refund the exceeding ether received
    
    if (tokenRaised + tokensToBuy>fundingGoals){
        uint256 exceedingTokens = tokenRaised+ tokensToBuy - fundingGoals;
        
        uint256 exceedingEther = exceedingTokens*1 /token.decimals() / tokenRate;
        
        msg.sender.transfer(exceedingEther);
        tokensToBuy -= exceedingTokens;
        etherUsed -= exceedingEther;
    }
    
    token.buyToken(msg.sender,tokensToBuy);
    
    tokenRaised+=tokensToBuy;
    ethRaised+=etherUsed;
    
    
    }
    


     
    function extractEther () public whenIcoCompleted onlyOwner{
        
        owner.transfer(this).balance;   //it will tranfer the eth raised in the crowd sale to the owner of the smart contract
    }
    
    
    
}