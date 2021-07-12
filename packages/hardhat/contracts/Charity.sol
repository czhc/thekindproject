//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import './CharityManager.sol';
import './CharityToken.sol';
import "./ERC1155TokenReceiver.sol";
import "hardhat/console.sol";

contract Charity is 
    ERC1155TokenReceiver {
    //controlled by Home/beneficiary entity
    enum Status { New, Verified, Deactivated }
    
    struct Donor {
        address addr;
        uint256 amount;
    }

    CharityManager public manager;
    address payable private owner;
    string public name;
    uint public index;
    uint public tokenIndex;
    Status public status;        

    uint256 public balance;
    

    event FundWithdrawn(address _to, uint256 _amount);
    event FundReceived(address _from, uint256 _amount);
    
    constructor(CharityManager _manager, address _wallet, string memory _name, uint _index) payable {
        manager = _manager;
        owner = payable(_wallet);
        name = _name;
        index = _index;
        status = Status.New;
    }

    modifier onlyOwner() {
        /*
            All payable calls should come from charity/contract owner
        */
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
        balance -= amount;
        payable(owner).transfer(amount);
        emit FundWithdrawn(owner, amount);
    }

    function withdrawAll() public payable {
        withdraw(address(this).balance);
    }
    
    
    function createCampaignTokens(uint256 _supply) external payable {
        new CharityToken(tokenIndex, _supply);
        tokenIndex++;
    }

    receive() external payable {
        require(status == Status.Verified, "Charity is not Verified");
        balance += msg.value;
        emit FundReceived(msg.sender, msg.value);
    }

    fallback() external payable{
    }


}