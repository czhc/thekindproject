//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import './CharityManager.sol';
import './CharityToken.sol';
import "./ERC1155TokenReceiver.sol";

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
    mapping (uint256 => address) public charityTokensUintAddrMapping;

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
    
    
    function createCharityTokens(uint256 _supply) external onlyOwner {
        CharityToken tokens = new CharityToken(tokenIndex, _supply, address(manager));
        charityTokensUintAddrMapping[tokenIndex] = address(tokens);
        tokenIndex++;
    }

    function getActiveTokenIndexOrDefault(uint256 _index) internal view returns (uint256) {
        if (charityTokensUintAddrMapping[_index] == address(0)){
            return tokenIndex - 1; //last active campaign
        } else {
            return _index; //returns known campaign
        }
    }

    function transferTokensFor(address _to, uint256 _value, uint256 _index) public { //TODO: onlyManager
        uint256 sendTokenIndex = getActiveTokenIndexOrDefault(_index);
        CharityToken tokens = CharityToken(charityTokensUintAddrMapping[sendTokenIndex]);
        tokens.safeTransferFrom(address(this), _to, sendTokenIndex, 1, ""); //transfer latest token for now
    }

    receive() external payable {
        balance += msg.value;
        emit FundReceived(msg.sender, msg.value);
    }

    fallback() external payable{
    }


}