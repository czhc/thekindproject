//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import './CharityManager.sol';

contract Charity is Ownable {
//controlled by Home/beneficiary entity
  struct Donor {
    address _addr;
    uint256 _amount;
  }

  address payable public wallet;
  string public name;
  uint public index;
  CharityManager manager;
  mapping(uint => Donor) public donors;

  constructor(CharityManager _manager, address payable _wallet, string memory _name, uint _index) {
    manager = _manager;
    wallet = _wallet;
    name = _name;
    index = _index;
  }

//   function owner() public view override returns (address){
//     return owner;
//   }
//   //withdraw funds
//   //upload gifts

}