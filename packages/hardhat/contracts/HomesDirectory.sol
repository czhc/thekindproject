pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT
import '@openzeppelin/contracts/access/Ownable.sol';

contract HomesDirectory is Ownable {

  mapping (address => bool) public homes;

  event homeAdded(address toAdd);
  event homeUpdated(address oldAddress, address newAddress);
  event homeDeleted(address toDelete);

  function addHome(address _address) public onlyOwner {
    require(homes[_address] != true, "Given address already whitelisted");
    emit homeAdded(_address);
    homes[_address] = true;
  }

  function updateHome(address _from, address _to) public onlyOwner {
    require(homes[_from], "Given address does not exist in directory");
    emit homeUpdated(_from, _to);
    homes[_to] = homes[_from];
    homes[_from] = false;
    assert(homes[_to] == true);
    assert(homes[_from] == false);
  }

  function deleteHome(address _address) public onlyOwner {
    emit homeDeleted(_address);
    homes[_address] = false;
  }
}