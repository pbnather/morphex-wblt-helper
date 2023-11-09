// SPDX-License-Identifier: ISC

pragma solidity 0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../Utils.sol";
import "./IVault.sol";
import "../weth/IWETH.sol";
import "../WethProvider.sol";
import "./IYearnTokenVault.sol";
import "./IRewardRouterV3.sol";

abstract contract BMX is WethProvider {
    using SafeERC20 for IERC20;

    IYearnTokenVault internal immutable wblt;
    IRewardRouterV3 internal immutable rewardRouter;
    address internal immutable glpManager;
    address internal immutable stakedGlp;

    constructor(
        address _wblt,
        address _rewardRouter,
        address _glpManager,
        address _stakedGlp
    ) {
        wblt = IYearnTokenVault(_wblt);
        rewardRouter = IRewardRouterV3(_rewardRouter);
        glpManager = _glpManager;
        stakedGlp = _stakedGlp;
    }

    function swapOnBMX(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 fromAmount,
        address exchange
    ) internal {
        address _fromToken = address(fromToken) == Utils.ethAddress()
            ? WETH
            : address(fromToken);
        address _toToken = address(toToken) == Utils.ethAddress()
            ? WETH
            : address(toToken);

        if (address(fromToken) == Utils.ethAddress()) {
            IWETH(WETH).deposit{value: fromAmount}();
        }

        if (_fromToken == address(wblt)) {
            // Withdraw WBLT
            uint256 bltAmount = wblt.withdraw();
            Utils.approve(address(wblt), stakedGlp, bltAmount);
            rewardRouter.unstakeAndRedeemGlp(
                _toToken,
                bltAmount,
                0,
                address(this)
            );
        } else if (_toToken == address(wblt)) {
            // Deposit WBLT
            Utils.approve(glpManager, _fromToken, fromAmount);
            uint256 bltAmount = rewardRouter.mintAndStakeGlp(
                _fromToken,
                fromAmount,
                0,
                0
            );
            wblt.deposit();
        } else {
            // Normal Vault Swap
            IERC20(_fromToken).safeTransfer(exchange, fromAmount);
            IVault(exchange).swap(_fromToken, _toToken, address(this));
        }

        if (address(toToken) == Utils.ethAddress()) {
            IWETH(WETH).withdraw(IERC20(WETH).balanceOf(address(this)));
        }
    }
}
