pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Verifier {
    address public severAddress;

    constructor(address _severAddress) public {
        severAddress = _severAddress;
    }

    function verifySignature(
        address _user,
        uint256 _balance,
        uint256 _nounce,
        bytes memory _signature
    ) public view returns (bool) {
        bytes32 messageHash = keccak256(
            abi.encodePacked(_user, _balance, _nounce)
        );

        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(
            messageHash
        );

        (address signer, ) = ECDSA.tryRecover(ethSignedMessageHash, _signature);

        return (severAddress == signer);
    }
}
