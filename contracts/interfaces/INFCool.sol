pragma solidity ^0.8.7;

    struct TokenData {
        string uri;
        string name;
    }

    struct TokenUnitData {
        address owner;
        string nfcId;
        string status;
    }

interface INFCool {

    event OwnershipGave(uint256 indexed tokenId, uint256 unitId, address indexed to, bool valid);

    event TokenMinted(uint256 tokenId, string tokenUri, string tokenName, bytes data);

    event TokenUnitMinted(uint256 indexed tokenId, uint256 unitId, string nfcId, bytes data);

    function getAllTokens() external view returns (TokenData[] memory);

    function getTokensCount() external view returns (uint256);

    function tokenData(uint256 tokenId) external view returns (TokenData memory);

    function tokenUnitData(uint256 tokenId, uint256 tokenUnitId) external view returns (TokenUnitData memory);

    function mintToken(string calldata tokenUri, string calldata tokenName, bytes memory data) external returns (uint256);

    function mintTokenUnit(uint256 tokenId, string calldata nfcId, bytes memory data) external returns (uint256);

    function requestOwnership(uint256 tokenId, uint256 unitId, address to, string calldata pin) external returns (bytes32 requestId);

    function giveOwnership(uint256 tokenId, uint256 unitId, address to, bool valid) external;

    function setVerificationContract(address contractAdr) external;
}
