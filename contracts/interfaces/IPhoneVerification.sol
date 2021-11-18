pragma solidity ^0.8.7;

interface IPhoneVerification {
    function requestOwnership(uint256 _tokenId, uint256 _unitId, address _to, string memory _pin) external returns (bytes32 requestId);
}
