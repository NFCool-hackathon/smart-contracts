pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

contract NFcool is ERC1155PresetMinterPauser {
    using Strings for uint256;

    mapping(uint256 => string) private _tokenURIs;

    constructor() ERC1155PresetMinterPauser("https://game.example/api/item/{id}.json") {

    }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenURIs[tokenId] = _tokenURI;
    }

}
