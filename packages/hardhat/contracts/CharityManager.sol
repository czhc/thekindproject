//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract CharityManager is Ownable {
    // manage Home lifecycle
    
    address[] public cList;
    mapping (uint => Charity) public charityMap;
    uint public index = 1;
    
    event CharityCreated(address cAddress);
    event CharityStatusChanged(address cAddress, Charity.Status status);
    event CharityUpdated();
    event DonationReceived();
    
    function getCharityList() public view returns (address[] memory){
        return cList;
    }

    function createCharity(string memory _name) public {
        Charity c = new Charity(this, address(msg.sender), _name, index);
        charityMap[index] = c;
        cList.push(address(c));
        index++;
        emit CharityCreated(address(c));
        
    }

    function verifyCharity(address cAddress) public onlyOwner {
        Charity _c = Charity(payable(cAddress));
        emit CharityStatusChanged(cAddress, Charity.Status.Verified);
        _c.verify();
        assert(_c.status() == Charity.Status.Verified);
    }

}

contract Charity {
    //controlled by Home/beneficiary entity
    enum Status { New, Verified, Deactivated }
    
    struct Donor {
        address addr;
        uint256 ammount;
    }

    CharityManager public manager;
    address private owner;
    string public name;
    uint public index;
    Status public status;        

    uint256 public balance;

    event FundWithdrawn(address _to, uint256 _amount);
    event FundReceived(address _from, uint256 _amount);
    
    constructor(CharityManager _manager, address _wallet, string memory _name, uint _index) {
        manager = _manager;
        owner = _wallet;
        name = _name;
        index = _index;
        status = Status.New;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized owner");
        _;
    }
    modifier onlyManager() {
        /*
            All non-payable calls should come from Manager contract
        */
        require(msg.sender == address(manager), "Unauthorized manager");
        _;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function verify() public onlyManager {
        status = Status.Verified;
    }

    function withdraw(uint256 amount) public payable onlyOwner {
        require(balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
        emit FundWithdrawn(owner, msg.value);
    }

    function withdrawAll() public payable {
        withdraw(balance);
    }
    
    receive() external payable {
        require(status == Status.Verified, "Charity is not Verified");
        balance += msg.value;
        emit FundReceived(msg.sender, msg.value);
    }

    fallback() external payable{
    }

}