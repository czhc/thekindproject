//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CharityToken is ERC1155 {
    address public charity;

    constructor(
        address _aManager,
        string memory uri
    ) ERC1155(uri) {
        charity = msg.sender;
        setApprovalForAll(_aManager, true);
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        require(msg.sender == charity, "Unauthorized");
        _mint(to, id, amount, data);
    }
}