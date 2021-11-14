pragma solidity ^0.8.7;

interface IPhoneVerification {
    function requestOwnership(string calldata _tokenId, string calldata _unitId, string calldata _to, string calldata _pin) external returns (bytes32 requestId);
}
