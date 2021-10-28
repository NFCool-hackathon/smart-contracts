pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

contract NFcool is ERC1155PresetMinterPauser {
    constructor() ERC1155PresetMinterPauser("https://game.example/api/item/{id}.json") {

    }
}
