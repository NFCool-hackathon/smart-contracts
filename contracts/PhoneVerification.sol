pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "./interfaces/IPhoneVerification.sol";

import "./interfaces/INFCool.sol";

contract PhoneVerification is IPhoneVerification, ChainlinkClient {
    using Chainlink for Chainlink.Request;

    // Chainlink variables
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    address private callerContract;

    constructor(address _callerContract) {
        setPublicChainlinkToken();
        oracle = 0xACADFbd7e4Ec5B29D18bcBc70cdA57Ef271cE931;
        jobId = "7b75d14b3c714fd19cbb199a36aaa9c9";
        fee = 0.1 * 10 ** 18; // (Varies by network and job)

        callerContract = _callerContract;
    }

    function requestOwnership(string calldata _tokenId, string calldata _unitId, string calldata _to, string calldata _pin) external virtual override returns (bytes32 requestId)
    {
//        require(msg.sender == callerContract, "You don't have the permission to call this function");

        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        request.add("tokenId", _tokenId);
        request.add("unitId", _unitId);
        request.add("pin", _pin);
        request.add("to", _to);

        // Multiply the result by 1000000000000000000 to remove decimals
        int timesAmount = 10**18;
        request.addInt("times", timesAmount);

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function fulfill(bytes32 _requestId, bool _valid, address _to, uint256 _tokenId, uint256 _unitId) public recordChainlinkFulfillment(_requestId)
    {
        INFCool(callerContract).giveOwnership(_tokenId, _unitId, _to, _valid);
    }
}
