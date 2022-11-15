// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

import "./Treasury.sol";
import '../libraries/SafeMath.sol';
import "../interfaces/IFactory.sol";
import "../interfaces/ILpToken.sol";
import "../interfaces/IRouter.sol";


contract TreasuryV2 is OlympusTreasury
{
    using SafeMath for uint;
     
    address public Factory;
    address public Router;
    address public DAI;

    constructor (
        address _OHM,
        address _DAI
    ) OlympusTreasury(_OHM, _DAI) 
    {
       DAI = _DAI;
    }

    function _initialize(address _factory, address _router)public onlyOwner
    {
        Factory = _factory;
        Router = _router;
    }
    function valueOf( address _token, uint _amount ) public override view returns ( uint value_ ) 
    {
        uint112 _customTokenReserve;
        uint112 _busdTokenReserve;
        uint32 _blockTimestampLast;
        if ( isCustomToken[ _token ] )
        {
           address LpToken = IFactory(Factory).getPair(_token, DAI);
           require(LpToken != address(0));
           if(ILpToken(LpToken).token0() == _token)
           {
            (_customTokenReserve, _busdTokenReserve, _blockTimestampLast) = ILpToken(LpToken).getReserves();
            value_ = IRouter(Router).quote(_amount, _customTokenReserve, _busdTokenReserve);
            return super.valueOf(DAI, value_);
           }
           else
           {
            (_busdTokenReserve, _customTokenReserve, _blockTimestampLast) = ILpToken(LpToken).getReserves();
            value_ = IRouter(Router).quote(_amount, _customTokenReserve, _busdTokenReserve);
            return super.valueOf(DAI, value_);
            }
        }
        else
        {
            return super.valueOf(_token, _amount);
        }
    }
    
        function settings( MANAGING _managing, address _address, address _calculator) external onlyOwner() returns ( bool ) {
        require( _address != address(0));
        if ( _managing == MANAGING.RESERVEDEPOSITOR ) { // 0
            require(!isReserveDepositor[_address]);
            reserveDepositors.push( _address );
            isReserveDepositor[_address] = true;
        } else if ( _managing == MANAGING.RESERVESPENDER ) { // 1
            require(!isReserveSpender[_address]);
            reserveSpenders.push( _address );
            isReserveSpender[_address] = true;
        } else if ( _managing == MANAGING.RESERVETOKEN ) { // 2
            require(!isReserveToken[_address]);
            reserveTokens.push( _address );
            isReserveToken[_address] = true;
        } else if ( _managing == MANAGING.RESERVEMANAGER ) { // 3
            require(!isReserveManager[_address]);
            reserveManagers.push( _address );
            isReserveManager[_address] = true;
        } else if ( _managing == MANAGING.LIQUIDITYDEPOSITOR ) { // 4
            require(!isLiquidityDepositor[_address]);
            liquidityDepositors.push( _address );
            isLiquidityDepositor[_address] = true;
        } else if ( _managing == MANAGING.LIQUIDITYTOKEN ) { // 5
            require(!isLiquidityToken[_address]);
            bondCalculator = _calculator;
            liquidityTokens.push( _address );
            isLiquidityToken[_address] = true;
        } else if ( _managing == MANAGING.LIQUIDITYMANAGER ) { // 6
            require(!isLiquidityManager[_address]);
            liquidityManagers.push( _address );
            isLiquidityManager[_address] = true;
        } else if ( _managing == MANAGING.REWARDMANAGER ) { // 7
            require(!isRewardManager[_address]);
            rewardManagers.push( _address );
            isRewardManager[_address] = true;
        } else if ( _managing == MANAGING.SOHM ) { // 8
            sOHM = _address;
        } else if (_managing == MANAGING.CUSTOMTOKENDEPOSITOR){ // 9
            require(!isCustomDepositor[_address]);
            customDepositors.push( _address );
            isCustomDepositor[_address] = true;
        }else if(_managing == MANAGING.CUSTOMTOKEN){ // 10
        require(!isCustomToken[_address]);
           customTokens.push( _address );
           isCustomToken[_address] = true;
        }else if(_managing == MANAGING.CUSTOMTOKENSPENDER){ // 11
           require(!isCustomSpender[_address]);
           customSpenders.push( _address );
           isCustomSpender[_address] = true;
        }
        else
        return false;
        emit ChangeQueued( _managing, _address );
        return true;
    }

}
