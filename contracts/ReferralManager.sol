//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ReferralManager is OwnableUpgradeable {
    mapping(bytes32 => address) public registeredCodes;
    mapping(address => address) public referrerInformation;

    /*  ╔══════════════════════════════╗
      ║            EVENTS            ║
      ╚══════════════════════════════╝ */

    event RegisteredCode(address sender, bytes32 code);

    event RegisteredReferrer(address sender, address referrer, bytes32 code);

    /**
     * @notice  .
     * @dev     Initialize function
     */
    function initialize() public initializer {
        __Ownable_init();
    }

    /*  ╔══════════════════════════════╗
      ║         USER FUNCTIONS       ║
      ╚══════════════════════════════╝ */

    /**
     * @notice  .
     * @dev     registerCode User register their created code here so other users may use it
     * @param   _code  Created referral code
     */
    function registerCode(bytes32 _code) external {
        require(_code != bytes32(0), "INVALID_CODE");
        require(registeredCodes[_code] == address(0), "CODE_UNAVAILABLE");

        registeredCodes[_code] = _msgSender();

        emit RegisteredCode(_msgSender(), _code);
    }

    /**
     * @notice  .
     * @dev     registerReferrer User register the referral code of the referrer
     * @param   _code  Referral code
     */
    function registerReferrer(bytes32 _code) external {
        require(_code != bytes32(0), "INVALID_CODE");
        require(registeredCodes[_code] != address(0), "CODE_NOT_EXISTS");
        require(
            registeredCodes[_code] != _msgSender(),
            "CAN_NOT_REFERRED_YOURSELF"
        );
        require(
            referrerInformation[_msgSender()] == address(0),
            "ALREADY_REFERRED"
        );

        address referrer = registeredCodes[_code];
        referrerInformation[_msgSender()] = referrer;

        emit RegisteredReferrer(_msgSender(), referrer, _code);
    }
}
