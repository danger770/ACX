// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

import '../libraries/SafeMath.sol';
import '../utils/Ownable.sol';
import '../interfaces/IERC20.sol';
import '../interfaces/IVesting.sol';

contract PreSale is Ownable
{
    address public ACX;
    address public DAI;
    address public Vesting;
    uint256 public initialPrice;
    uint256 public acxSold;
    uint256 public priceFactor;
    uint256 public acxSupply;

    // priceFactor
    // 10000015 means 1.0000015 * 10000000
    constructor(address _ACX, address _DAI, uint256 _initialPrice, uint256 _priceFactor)
    {
        ACX = _ACX;
        DAI = _DAI;
        initialPrice = _initialPrice;
        priceFactor = _priceFactor;
    }
    modifier isSaleLimit(uint256 _amount)
    {
        require(acxSold + _amount < acxSupply, "Presale limit reached!");
        _;
    }
    function initialize(address _vesting)external 
    {
        Vesting = _vesting;
    }

    function FundPresale(uint256 _amount)public onlyOwner
    {
        IERC20(ACX).transferFrom(msg.sender, address(this), _amount);
        acxSupply = acxSupply + _amount;
    }

    function currentPrice()public view returns(uint256 _currentPrice)
    {
        _currentPrice = (initialPrice ** (priceFactor ** acxSold));
    }

    enum POLICIES {PRICE_FACTOR}
    function policy(POLICIES _policies, uint256 _value)public onlyOwner
    {
        if(_policies == POLICIES.PRICE_FACTOR)
        {
            priceFactor = _value;  
        }
    }

    // _amount = ACX Amount
    function Purchase(uint256 _amount)public isSaleLimit(_amount)
    {
        uint256 _dai = (_amount * currentPrice()) / 1000000000;
        IERC20(DAI).transferFrom(msg.sender, address(this), _dai);
        IERC20(ACX).approve(Vesting, _amount);
        IVesting(Vesting).lockTokens(msg.sender, _amount);
        acxSold = acxSold + _amount;
    }

}
