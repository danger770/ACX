// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;
interface IRouter
{
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
}