// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IYearnTokenVault {
    function withdraw() external returns (uint256);

    function deposit() external returns (uint256);
}
