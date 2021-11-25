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

    constructor(string memory _brandName, address verificationContract) ERC1155Access("") {
        brandName = _brandName;
        _verificationContract = verificationContract;
    }

    function getBrandName() external view returns (string memory) {
        return brandName;
    }

    function haveClaimPermission(uint256 tokenId, uint256 unitId, address account) public view returns (bool) {
        return account == _claimPermissions[tokenId][unitId];
    }

    function allBalancesOf(address account) public view returns (uint256[] memory){
        uint[] memory amounts = new uint[](tokensCount);

        for (uint i = 0 ; i < tokensCount ; i++) {
            amounts[i] = balanceOf(account, i);
        }
        return amounts;
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
        require(hasRole(SUPPLIER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");
        require(_exists(tokenId), "The token do not exists");

        _mint(address(this), tokenId, 1, data);
        _tokenUnitData[tokenId][_tokenUnitsCount[tokenId]] = TokenUnitData(address(this), nfcId, "minted");

        emit TokenUnitMinted(tokenId, _tokenUnitsCount[tokenId], nfcId, data);

        _tokenUnitsCount[tokenId]++;

        return _tokenUnitsCount[tokenId] - 1;
    }

    function requestPhoneVerification(uint256 tokenId, uint256 unitId, address to, string calldata pin) external virtual override returns (bytes32 requestId) {
        require(_verificationContract != address(0), "You need to setup the verification contract address first");
        require(haveClaimPermission(tokenId, unitId, address(0)), "The permission is already gave");
        require(keccak256(abi.encodePacked(_tokenUnitData[tokenId][unitId].status)) == keccak256(abi.encodePacked("sold")), "This token can't be claimed");

        return IPhoneVerification(_verificationContract).requestOwnership(tokenId, unitId, to, pin);
    }

    function ownershipPermission(uint256 tokenId, uint256 unitId, address to, bool valid) external virtual override {
        require(msg.sender == _verificationContract, "You don't have the permission to give ownership");

        _claimPermissions[tokenId][unitId] = to;

        emit OwnershipPermissionGave(tokenId, unitId, to, valid);
    }

    function claimOwnership(uint256 tokenId, uint256 unitId, address to) external virtual override {
        require(haveClaimPermission(tokenId, unitId, to), "The address don't have the permission");
        require(keccak256(abi.encodePacked(_tokenUnitData[tokenId][unitId].status)) == keccak256(abi.encodePacked("sold")), "This token can't be claimed");

        _tokenUnitData[tokenId][unitId].status = "owned";
        _safeUnitTransferFrom(address(this), to, tokenId, unitId, '');
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

    function unitSold(uint256 tokenId, uint256 unitId) external {
        require(hasRole(SELLER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");
        require(keccak256(abi.encodePacked(_tokenUnitData[tokenId][unitId].status)) == keccak256(abi.encodePacked('minted')), "The status of this token can't be set as 'sold'");

        _tokenUnitData[tokenId][unitId].status = "sold";
    }

    function unitStolen(uint256 tokenId, uint256 unitId) external {
        require(_isOwner(tokenId, unitId, msg.sender), "You don't have the permission to edit the status of this token");
        require(keccak256(abi.encodePacked(_tokenUnitData[tokenId][unitId].status)) == keccak256(abi.encodePacked('owned')), "The status of this token can't be set as 'stolen'");

        _tokenUnitData[tokenId][unitId].status = "stolen";
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Access, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenData[tokenId].uri = _tokenURI;
    }

    function _exists(uint256 tokenId) private view returns (bool) {
        return tokenId < tokensCount;
    }

    function _isOwner(uint256 tokenId, uint256 unitId, address account) private view returns (bool) {
        return _tokenUnitData[tokenId][unitId].owner == account;
    }
}
