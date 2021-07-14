//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import './Charity.sol';
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "hardhat/console.sol";

contract CharityToken is ERC1155 {
    address public charity;
    constructor(uint256 _id, uint256 _initialSupply, address _aManager) ERC1155("") {
        charity = msg.sender;
        _mint(msg.sender, _id, _initialSupply, "");
        setApprovalForAll(_aManager, true);
    }
}