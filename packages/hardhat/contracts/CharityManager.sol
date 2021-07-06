//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import '@openzeppelin/contracts/access/Ownable.sol';

import './Charity.sol';

contract CharityManager is Ownable {
// manage Home lifecycle
  enum CharityStatus { New, Verified, Deactivated }

  struct C_Item {
    Charity _charity;
    uint _id;
    CharityManager.CharityStatus _status;
  }

  struct Donor {
    address addr;
    uint256 ammount;
  }

  mapping(uint => C_Item) public charities;
  uint index;

  event charityAdded(uint index, address toAdd);
  event charityStatusChanged(uint id, CharityStatus status);
  event charityUpdated(address oldAddress, string name);

  function addCharity(string memory _name) public {

    Charity charity = new Charity(this, payable(msg.sender), _name, index);
    charities[index]._charity = charity;
    charities[index]._id = index;
    charities[index]._status = CharityStatus.New;
    index++;

    emit charityAdded(index, msg.sender);
  }

  function verifyCharity(uint _id) public onlyOwner {
    charities[_id]._status = CharityStatus.Verified;
    emit charityStatusChanged(_id, charities[_id]._status);
  }

  function deactivateCharity(uint _id) public onlyOwner{
    charities[_id]._status = CharityStatus.Deactivated;
    emit charityStatusChanged(_id, charities[_id]._status);
  }

  function donateTo(uint _charity, uint256 _amount) public {
    // donate to charity
  }

}