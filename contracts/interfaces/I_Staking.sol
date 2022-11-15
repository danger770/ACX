// SPDX-License-Identifier: Unlicensed
pragma solidity 0.7.5;

import "./Isynth.sol";
interface I_Staking{
    function GetSynthInfo(address synthAddress) external view returns(Isynth);
}
