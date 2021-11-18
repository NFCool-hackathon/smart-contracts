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
    function getAllTokens() external view returns (TokenData[] memory);

    function getTokensCount() external view returns (uint256);

    function tokenData(uint256 tokenId) external view returns (TokenData memory);

    function tokenUnitData(uint256 tokenId, uint256 tokenUnitId) external view returns (TokenUnitData memory);

    function mintToken(string calldata tokenUri, string calldata tokenName, bytes memory data) external returns (uint256);

    function mintTokenUnit(uint256 tokenId, string calldata nfcId, bytes memory data) external returns (uint256);

    function requestOwnership(uint256 _tokenId, uint256 _unitId, address _to, string calldata _pin) external returns (bytes32 requestId);

    function giveOwnership(uint256 _tokenId, uint256 _unitId, address _to, bool _valid) external;

    function setVerificationContract(address _contract) external;
}
