// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

library SafeMath {
   function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
      // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
      // benefit is lost if 'b' is also tested.
      // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
      if (a == 0) {
         return 0;
      }
      c = a * b;  
      assert(c / a == b);
      return c;
   }
   function div(uint256 a, uint256 b) internal pure returns (uint256) {
      // assert(b > 0); // Solidity automatically throws when dividing by 0
      // uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
      return a / b;
   }
   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
   }
   function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
      c = a + b;
      assert(c >= a);
      return c;
   }
}
contract Token {
   using SafeMath for uint256;
   event Transfer(address indexed from, address indexed to, uint256 value);
   event Approval(address indexed owner, address indexed spender, uint256 value);
   mapping(address => uint256) balances;
   uint256 totalSupply_;
   function totalSupply() public view returns (uint256) {
      return totalSupply_;
   }
   function transfer(address _to, uint256 _value) public virtual  returns (bool) {
      require(_value <= balances[msg.sender]);
      require(_to != address(0));
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      emit Transfer(msg.sender, _to, _value);
      return true;
   }
   function balanceOf(address _owner) public view returns (uint256) {
      return balances[_owner];
   }
   mapping (address => mapping (address => uint256)) internal allowed;
   function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
      require(_value <= balances[_from]);
      require(_value <= allowed[_from][msg.sender]);
      require(_to != address(0));
      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
      emit Transfer(_from, _to, _value);
      return true;
   }
   function approve(address _spender, uint256 _value) public virtual returns (bool) {
      allowed[msg.sender][_spender] = _value;
      emit Approval(msg.sender, _spender, _value);
      return true;
   }
   function allowance(address _owner,address _spender) public view returns (uint256) {
      return allowed[_owner][_spender];
   }
   function increaseApproval(address _spender, uint256 _addedValue) public virtual returns (bool) {
      allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);   
   }
   function decreaseApproval(address _spender, uint256 _subtractedValue) public virtual returns (bool) {
      uint256 oldValue = allowed[msg.sender][_spender];
      if (_subtractedValue >= oldValue) {
         allowed[msg.sender][_spender] = 0;
      } else {
         allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
      }
      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
   }
}


contract ICOToken is Token {
   string public name = 'ICOToken';
   string public symbol = 'ITK';
   uint256 public decimals = 18;
   address public crowdSaleAddress;
   address public owner;
   uint256 public icoEndTime;
   
   modifier onlyCrowdsale{
       require(msg.sender== crowdSaleAddress );
       _;
   }
   
   modifier onlyOwner{
       require(msg.sender==owner);
       _;
       
   }
   
   modifier afterCrowdsale{
       require(block.timestamp > icoEndTime || msg.sender== crowdSaleAddress );
       _;
       
   }
   
   constructor (uint256 _icoEndTime) public Token() {
       require(icoEndTime!=0);
      totalSupply_ = 10**8;
      owner = msg.sender;
      icoEndTime=_icoEndTime;
   }
   
   //I created the setCrowdale() function which will be used to set the value of the crowdsaleAddress variable
   
   function setCrowdsale(address _crowdsaleAddress) public onlyOwner{
       require (crowdSaleAddress!=address(0));
       
       crowdSaleAddress=_crowdsaleAddress;
       
   }
   
   //Finally I created the buyTokens() function which will be used to send tokens to people that participate in the ICO.
   //This function is only executable by the Crowdsale contract, that’s why we need the address of it.
   
   function buyToken (address _receiver, uint256 _amount) public onlyCrowdsale{
        require( _receiver!=address(0));
        require(_amount!=0);
        transfer(_receiver,_amount);
   }
   
   
   
   
   // @notice Override the functions to not allow token transfers until the end of the ICO
   function transfer(address _to, uint256 _value) public virtual override afterCrowdsale returns(bool) {
      return super.transfer(_to, _value);
   }
   /// @notice Override the functions to not allow token transfers until the end of the ICO
   function transferFrom(address _from, address _to, uint256 _value) public virtual override  afterCrowdsale returns(bool) {
      return super.transferFrom(_from, _to, _value);
   }
   /// @notice Override the functions to not allow token transfers until the end of the ICO
   function approve(address _spender, uint256 _value) public virtual override afterCrowdsale returns(bool) {
      return super.approve(_spender, _value);
   }
   /// @notice Override the functions to not allow token transfers until the end of the ICO
   function increaseApproval(address _spender, uint _addedValue) public virtual override afterCrowdsale returns(bool success) {
      return super.increaseApproval(_spender, _addedValue);
   }
   /// @notice Override the functions to not allow token transfers until the end of the ICO
   function decreaseApproval(address _spender, uint _subtractedValue) public virtual override afterCrowdsale returns(bool success) {
      return super.decreaseApproval(_spender, _subtractedValue);
   }
   
   
   
   
//   function emergencyExtract() external onlyOwner payable {
//       owner.transfer(address(this).balance);
//   }
}    
