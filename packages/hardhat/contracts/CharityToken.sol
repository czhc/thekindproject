//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './Charity.sol';
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract CharityToken is ERC1155 {
    address public charity;
    constructor(uint256 id, uint256 initialSupply, address _aManager) ERC1155("") {
        charity = msg.sender;
        _mint(msg.sender, id, initialSupply, "");
        setApprovalForAll(_aManager, true);
    }
}