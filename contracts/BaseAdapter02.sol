// SPDX-License-Identifier: ISC

pragma solidity 0.7.5;
pragma abicoder v2;

import "./interfaces/IAdapter.sol";
import "./lib/bmx/BMX.sol";
import "./lib/WethProvider.sol";

/*
 * @dev This contract will route calls to dexes according to the following indexing:
 * 1 - BMX by Morphex
 */
contract BaseAdapter02 is IAdapter, BMX {
    using SafeMath for uint256;

    constructor(
        address _weth,
        address _bmxWblt,
        address _bmxRewardRouter,
        address _bmxGlpManager,
        address _bmxStakedGlp
    )
        WethProvider(_weth)
        BMX(_bmxWblt, _bmxRewardRouter, _bmxGlpManager, _bmxStakedGlp)
    {}

    function initialize(bytes calldata) external override {
        revert("METHOD NOT IMPLEMENTED");
    }

    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        uint256,
        Utils.Route[] calldata route
    ) external payable override {
        for (uint256 i = 0; i < route.length; i++) {
            if (route[i].index == 1) {
                swapOnBMX(
                    fromToken,
                    toToken,
                    fromAmount.mul(route[i].percent).div(10000),
                    route[i].targetExchange
                );
            } else {
                revert("Index not supported");
            }
        }
    }
}
