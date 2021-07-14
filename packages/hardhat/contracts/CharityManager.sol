//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./Charity.sol";
import "./CharityToken.sol";
import  "hardhat/console.sol";

contract CharityManager is Ownable {
    // manage Home lifecycle
    
    address[] public cList;
    mapping (uint => Charity) public charityMap;
    mapping (Charity => uint) public idMap;
    uint public index = 1;
    
    event CharityCreated(address cAddress);
    event CharityStatusChanged(address cAddress, Charity.Status status);
    event DonationReceived(address from, address to, uint256 amount);
    event Log(string message);
    event LogBytes(bytes data);

    function getCharityList() public view returns (address[] memory){
        return cList;
    }

    function createCharity(string memory _name) public {
        Charity c = new Charity(this, address(msg.sender), _name, index);
        charityMap[index] = c;
        idMap[c] = index;
        cList.push(address(c));
        index++;
        emit CharityCreated(address(c));
        
    }

    function verifyCharity(address _cAddress) public onlyOwner {
        Charity _c = Charity(payable(_cAddress));
        emit CharityStatusChanged(_cAddress, Charity.Status.Verified);
        _c.verify();
        assert(_c.status() == Charity.Status.Verified);
    }

    function charityExists(address _cAddress) public view returns (bool, Charity) {
        Charity _c = Charity(payable(_cAddress));
        return (idMap[_c]>0, _c);
    }


    function donateTo(address _cAddress, uint256 _tokenIndex) public payable {
        // validate charity exists
        (bool exists, Charity charity) = charityExists(_cAddress);
        require(exists, "Charity does not exist");
        // moved out of Charity. minimize logic in receive()
        require(charity.status() == Charity.Status.Verified, "Charity is not Verified");

        emit DonationReceived(msg.sender, _cAddress, msg.value);

        (bool success,) = payable(_cAddress).call{value: msg.value}(""); //should throw on fail
        require(success, "Fund transfer failed");
        charity.transferTokensFor(msg.sender, msg.value, _tokenIndex);
    }

}
