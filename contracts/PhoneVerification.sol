pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IPhoneVerification.sol";

import "./interfaces/INFCool.sol";

contract PhoneVerificationTest is IPhoneVerification, ChainlinkClient {
    using Chainlink for Chainlink.Request;

    struct Request {
        uint16 tokenId;
        uint32 unitId;
        address to;
    }

    address private oracle;
    string private jobId;

    uint256 constant private ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY;

    address private callerContract;
    mapping (bytes32 => Request) private _requests;

    constructor(address _callerContract) {
        setPublicChainlinkToken();
        oracle = 0xACADFbd7e4Ec5B29D18bcBc70cdA57Ef271cE931;
        jobId = "7b75d14b3c714fd19cbb199a36aaa9c9";
        callerContract = _callerContract;
    }

    function requestOwnership(uint256 _tokenId, uint256 _unitId, address _to, string memory _pin) external virtual override returns (bytes32 requestId)
    {
        //        require(msg.sender == callerContract, "You don't have the permission to call this function");

        Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32(jobId), address(this), this.fulfillOwnership.selector);

        request.add("tokenId", Strings.toString(_tokenId));
        request.add("unitId", Strings.toString(_unitId));
        request.add("pin", _pin);

        requestId = sendChainlinkRequestTo(oracle, request, ORACLE_PAYMENT);

        _requests[requestId] = Request(uint16(_tokenId), uint32(_unitId), _to);
    }

    function fulfillOwnership(bytes32 _requestId, bool _valid) public recordChainlinkFulfillment(_requestId)
    {
        INFCool(callerContract).giveOwnership(uint256(_requests[_requestId].tokenId), uint256(_requests[_requestId].unitId), _requests[_requestId].to, _valid);
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly { // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}

