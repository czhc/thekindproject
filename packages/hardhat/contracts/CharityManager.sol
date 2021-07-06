//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import '@openzeppelin/contracts/access/Ownable.sol';

contract CharityManager is Ownable {
    // manage Home lifecycle
    
    address[] public cList;
    mapping (uint => Charity) public charityMap;
    uint index;
    
    event charityCreated(address cAddress);
    event charityStatusChanged(uint id, Charity.Status status);
    event charityUpdated();
    event receivedDonation();
    
    function createCharity(string memory _name) public {
        Charity c = new Charity(this, msg.sender, _name, index);
        charityMap[index] = c;
        cList.push(address(c));
        index++;
        emit charityCreated(address(c));
        
    }

    function verifyCharity(uint _id) public {
        emit charityStatusChanged(_id, Charity.Status.Verified);
    }

}

contract Charity {
//controlled by Home/beneficiary entity
    enum Status { New, Verified, Deactivated }
    
    struct Donor {
        address addr;
        uint256 ammount;
    }

    address payable public owner;
    string public name;
    uint public index;
    CharityManager manager;
    Status public status;        

    uint256 public balance;

    event fundWithdrawn(address _to, uint256 _amount);
    event fundReceived(address _from, uint256 _amount);
    
    constructor(CharityManager _manager, address _wallet, string memory _name, uint _index) {
        manager = _manager;
        owner = payable(_wallet);
        name = _name;
        index = _index;
        status = Status.New;
    }

    function verify() public {
        require(msg.sender == manager.owner(), "Unauthorized");
        status = Status.Verified;
        manager.verifyCharity(index);
    }


    function withdraw(uint256 amount) public payable {
        require(msg.sender == owner, "Unauthorized");
        require(balance >= amount, "Insufficient balance");
        owner.transfer(amount);
        emit fundWithdrawn(owner, msg.value);
    }

    function withdrawAll() public payable {
        withdraw(balance);
    }
    
    receive() external payable {
        require(status == Status.Verified, "Charity is not Verified");
        balance += msg.value;
        emit fundReceived(msg.sender, msg.value);
    }

    fallback() external {
        
    }

}