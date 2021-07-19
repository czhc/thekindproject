//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./Charity.sol";
import "./CharityToken.sol";

contract CharityManager is
            Ownable,
            ReentrancyGuard {
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

    function getCharityList()
        external
        view
        returns (address[] memory)
    {
        return cList;
    }

    function createCharity(string memory name)
        external
    {
        Charity c = new Charity(this, address(msg.sender), name, index);
        charityMap[index] = c;
        idMap[c] = index;
        cList.push(address(c));
        index++;
        emit CharityCreated(address(c));
        
    }

    function verifyCharity(address cAddress)
        external
        onlyOwner
    {
        Charity _c = Charity(payable(cAddress));
        emit CharityStatusChanged(cAddress, Charity.Status.Verified);
        _c.verify();
        assert(_c.status() == Charity.Status.Verified);
    }

    function charityExists(address cAddress)
        public
        view
        returns (bool, Charity)
    {
        Charity _c = Charity(payable(cAddress));
        return (idMap[_c]>0, _c);
    }


    function donateTo(address cAddress, uint256 tokenIndex)
        external
        payable
        nonReentrant
    {
        (bool exists, Charity charity) = charityExists(cAddress);
        require(exists, "Charity does not exist");
        // moved out of Charity. minimize logic in receive()
        require(charity.status() == Charity.Status.Verified, "Charity is not Verified");
        require(msg.value <= charity.donationCap(), "Value sent exceeds donation cap");

        emit DonationReceived(msg.sender, cAddress, msg.value);

        charity.transferTokensFor(msg.sender, tokenIndex);
        Address.sendValue(payable(cAddress), msg.value); // OZ replacement for transfer()
    }

}
