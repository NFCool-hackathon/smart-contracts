pragma solidity ^0.8.7;

interface IPhoneVerification {
    event Fulfilled(bytes32 requestId, bool valid);

    function requestOwnership(uint256 _tokenId, uint256 _unitId, address _to, string memory _pin) external returns (bytes32 requestId);
}
