pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";


contract NFCool is ERC1155PresetMinterPauser, ERC1155Holder {
    using Strings for uint256;

    struct TokenData {
        string uri;
        string name;
    }

    struct TokenUnitData {
        address owner;
        string nfcId;
        string status;
    }

    string brandName;

    uint8 tokensCount;
    mapping (uint256 => uint256) private _tokenUnitsCount;

    mapping(uint256 => TokenData) private _tokenData;

    mapping(uint256 => mapping(uint256 => TokenUnitData)) private _tokenUnitData;

    constructor(string memory _brandName) ERC1155PresetMinterPauser("") {
        brandName = _brandName;
    }

    function getAllTokens() public view virtual returns (TokenData[] memory) {
        TokenData[] memory tokens = new TokenData[](tokensCount);

        for (uint256 i = 0 ; i < tokensCount ; i++) {
            tokens[i] = _tokenData[i];
        }

        return tokens;
    }

    function tokenData(uint256 tokenId) public view virtual returns (TokenData memory) {
        return _tokenData[tokenId];
    }

    function tokenUnitData(uint256 tokenId, uint256 tokenUnitId) public view virtual returns (TokenUnitData memory) {
        return _tokenUnitData[tokenId][tokenUnitId];
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenData[tokenId].uri = _tokenURI;
    }

    function _exists(uint256 tokenId) private view returns (bool) {
        return keccak256(bytes(_tokenData[tokenId].name)) != keccak256(bytes(""));
    }

    function mintToken(string calldata tokenUri, string calldata tokenName, bytes memory data) external returns (uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");

        _mint(address(this), tokensCount, 0, data);
        _tokenData[tokensCount] = TokenData(tokenUri, tokenName);

        tokensCount++;
        return tokensCount;
    }

    function mintTokenUnit(uint256 tokenId, string calldata nfcId, bytes memory data) external returns (uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");

        _mint(address(this), _tokenUnitsCount[tokenId], 1, data);
        _tokenUnitData[tokenId][_tokenUnitsCount[tokenId]] = TokenUnitData(address(this), nfcId, "minted");

        _tokenUnitsCount[tokenId]++;
        return _tokenUnitsCount[tokenId];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155PresetMinterPauser, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
