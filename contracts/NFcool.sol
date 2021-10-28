pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

contract NFcool is ERC1155PresetMinterPauser {
    using Strings for uint256;

    uint8 tokensCount;

    struct TokenData {
        string uri;
        string name;
    }

    struct TokenUnitData {
        address owner;
        string nfcId;
    }

    mapping(uint256 => TokenData) private _tokenData;

    mapping(uint256 => mapping(uint256 => TokenUnitData)) private _tokenUnitData;

    constructor() ERC1155PresetMinterPauser("https://game.example/api/item/{id}.json") {
    }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        return _tokenData[tokenId].uri;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenData[tokenId].uri = _tokenURI;
    }

    function _exists(uint256 tokenId) private view returns (bool) {
        return keccak256(bytes(_tokenData[tokenId].name)) != keccak256(bytes(""));
    }

    function createToken(string calldata tokenUri, string calldata tokenName) external returns (uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");

        _mint(_msgSender(), tokensCount, 0, "");
        _tokenData[tokensCount] = TokenData(tokenUri, tokenName);

        tokensCount++;
        return tokensCount;
    }

}
