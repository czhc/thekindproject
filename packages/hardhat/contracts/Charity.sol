//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './CharityManager.sol';
import './CharityToken.sol';
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract Charity is 
    ERC1155Holder,
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

    event FundWithdrawn(address to, uint256 _amount);
    event FundReceived(address _from, uint256 _amount);
    
    constructor(CharityManager manager_, address wallet, string memory name_, uint index_) payable {
        require(wallet != address(0), "Wallet must be valid");
        manager = manager_;
        owner = payable(wallet);
        name = name_;
        index = index_;
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

    function getOwner() external view returns (address) {
        return owner;
    }

    function verify() external onlyManager {
        status = Status.Verified;
    }

    function withdraw(uint256 amount) public payable onlyOwner {
        require(balance >= amount, "Insufficient balance");
        balance -= amount;
        emit FundWithdrawn(owner, amount);
        payable(owner).transfer(amount);
    }

    function withdrawAll() external payable {
        withdraw(address(this).balance);
    }
    
    
    function createCharityTokens(uint256 supply) external onlyOwner {
        uint256 _currentIndex = tokenIndex;
        tokenIndex++;
        CharityToken tokens = new CharityToken(_currentIndex, supply, address(manager));
        charityTokensUintAddrMapping[tokenIndex] = address(tokens);
    }

    function getActiveTokenIndexOrDefault(uint256 index_) internal view returns (uint256) {
        if (charityTokensUintAddrMapping[index_] == address(0)){
            return tokenIndex - 1; //last active campaign
        } else {
            return index_; //returns known campaign
        }
    }

    function transferTokensFor(address to, uint256 index_) external onlyManager {
        uint256 sendTokenIndex = getActiveTokenIndexOrDefault(index_);
        CharityToken tokens = CharityToken(charityTokensUintAddrMapping[sendTokenIndex]);
        tokens.safeTransferFrom(address(this), to, sendTokenIndex, 1, ""); //transfer latest token for now
    }

    receive() external payable {
        balance += msg.value;
        emit FundReceived(msg.sender, msg.value);
    }

    fallback() external payable{
    }


}