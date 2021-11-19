pragma solidity ^0.8.7;

import "./interfaces/INFCool.sol";
import "./interfaces/IPhoneVerification.sol";
import "./ERC1155Access.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract NFCool is INFCool, ERC1155Access, ERC1155Holder {
    string brandName;
    uint8 tokensCount;

    address private _verificationContract;

    mapping (uint256 => uint256) private _tokenUnitsCount;
    mapping(uint256 => TokenData) private _tokenData;
    mapping(uint256 => mapping(uint256 => TokenUnitData)) private _tokenUnitData;
    mapping(uint256 => mapping(uint256 => address)) private _claimPermissions;

    constructor(string memory _brandName) ERC1155Access("") {
        brandName = _brandName;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenData[tokenId].uri = _tokenURI;
    }

    function _exists(uint256 tokenId) private view returns (bool) {
        return tokenId < tokensCount;
    }

    function getAllTokens() public view virtual override returns (TokenData[] memory) {
        TokenData[] memory tokens = new TokenData[](tokensCount);

        for (uint256 i = 0 ; i < tokensCount ; i++) {
            tokens[i] = _tokenData[i];
        }

        return tokens;
    }

    function getTokensCount() public view virtual override returns (uint256) {
        return tokensCount;
    }

    function tokenData(uint256 tokenId) public view virtual override returns (TokenData memory) {
        return _tokenData[tokenId];
    }

    function tokenUnitData(uint256 tokenId, uint256 tokenUnitId) public view virtual override returns (TokenUnitData memory) {
        return _tokenUnitData[tokenId][tokenUnitId];
    }

    function mintToken(string calldata tokenUri, string calldata tokenName, bytes memory data) external virtual override returns (uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");

        _mint(address(this), tokensCount, 0, data);
        _tokenData[tokensCount] = TokenData(tokenUri, tokenName);

        emit TokenMinted(tokensCount, tokenUri, tokenName, data);

        tokensCount++;
        return tokensCount - 1;
    }

    function mintTokenUnit(uint256 tokenId, string calldata nfcId, bytes memory data) external virtual override returns (uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");
        require(_exists(tokenId), "The token do not exists");

        _mint(address(this), _tokenUnitsCount[tokenId], 1, data);
        _tokenUnitData[tokenId][_tokenUnitsCount[tokenId]] = TokenUnitData(address(this), nfcId, "minted");

        emit TokenUnitMinted(tokenId, _tokenUnitsCount[tokenId], nfcId, data);

        _tokenUnitsCount[tokenId]++;

        return _tokenUnitsCount[tokenId] - 1;
    }

    function requestPhoneVerification(uint256 tokenId, uint256 unitId, address to, string calldata pin) external virtual override returns (bytes32 requestId) {
        require(_verificationContract != address(0), "You need to setup the verification contract address first");
        require(_claimPermissions[tokenId][unitId] == address(0), "The permission is already gave");
        require(keccak256(abi.encodePacked(_tokenUnitData[tokenId][unitId].status)) == keccak256(abi.encodePacked("sold")), "This token can't be claimed");

        return IPhoneVerification(_verificationContract).requestOwnership(tokenId, unitId, to, pin);
    }

    function ownershipPermission(uint256 tokenId, uint256 unitId, address to, bool valid) external virtual override {
        require(msg.sender == _verificationContract, "You don't have the permission to give ownership");

        _claimPermissions[tokenId][unitId] = to;

        emit OwnershipPermissionGave(tokenId, unitId, to, valid);
    }

    function claimOwnership(uint256 tokenId, uint256 unitId, address to) external virtual override {
        require(_claimPermissions[tokenId][unitId] == to, "The address don't have the permission");
        require(keccak256(abi.encodePacked(_tokenUnitData[tokenId][unitId].status)) == keccak256(abi.encodePacked("sold")), "This token can't be claimed");

        _tokenUnitData[tokenId][unitId].status = "owned";
        _safeTransferFrom(address(this), to, tokenId, 1, '');
    }

    function safeUnitTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 unitId,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeUnitTransferFrom(from, to, tokenId, unitId, data);
    }

    function _safeUnitTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 unitId,
        bytes memory data
    ) internal virtual {
        _tokenUnitData[tokenId][unitId].owner = to;
        _safeTransferFrom(from, to, tokenId, 1, data);
    }

    function setVerificationContract(address contractAdr) external virtual override {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");
        _verificationContract = contractAdr;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Access, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
