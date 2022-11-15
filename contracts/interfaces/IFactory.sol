// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;


interface IFactory
{
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}