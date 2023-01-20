//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IReferralManager {
    /*  ╔══════════════════════════════╗
      ║            EVENTS            ║
      ╚══════════════════════════════╝ */

    event RegisteredCode(address sender, bytes32 code);

    event RegisteredReferrer(address sender, address referrer, bytes32 code);

    /*  ╔══════════════════════════════╗
      ║         USER FUNCTIONS       ║
      ╚══════════════════════════════╝ */

    function registeredCodes(bytes32) external returns (address);

    function referrerInformation(address) external returns (address);

    /**
     * @notice  .
     * @dev     registerCode User register their created code here so other users may use it
     * @param   _code  Created referral code
     */
    function registerCode(bytes32 _code) external;

    /**
     * @notice  .
     * @dev     registerReferrer User register the referral code of the referrer
     * @param   _code  Referral code
     */
    function registerReferrer(bytes32 _code) external;
}
