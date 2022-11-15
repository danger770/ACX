// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

import '../libraries/SafeMath.sol';
import '../utils/Ownable.sol';
import '../interfaces/IERC20.sol';

contract VestingPresale
{
    address public Presale;
    address public ACX;
    uint256 public vestingTime; // in days
    uint256 public claimPercentage;
    // 10% means 1000  as 10*100 = 1000
    // 100% means 10000 as 100*100 = 10000
    struct Vesting
    {
        uint256 lastClaimed;
        uint256 totalClaimable;
        uint256 claimAmount;
        uint256 expiry;
    }
    mapping(address => Vesting[]) public userVesting;
    constructor(address _presale, address _ACX, uint256 _vestingTime, uint256 _vestingPercentage)
    {
        Presale = _presale;
        ACX = _ACX;
        vestingTime = _vestingTime * 1 minutes;
        claimPercentage = _vestingPercentage;
    }

    modifier onlyPresale()
    {
        require(msg.sender == Presale, "Only Presale Contract can lock Tokens!");
        _;
    }
    function lockTokens(address _user, uint256 _amount)public onlyPresale() returns(bool _locked)
    {
        IERC20(ACX).transferFrom(msg.sender, address(this), _amount);
        uint256 initialUnlock = _amount * claimPercentage / 10000;
        uint256 _totalClaimable = _amount - initialUnlock;
        uint256 _claimAmount = initialUnlock;
        uint256 _expiry = block.timestamp + (vestingTime * 9);
        IERC20(ACX).transfer(_user, initialUnlock);
        Vesting memory _vesting = Vesting
        ({
            lastClaimed : block.timestamp,
            totalClaimable   : _totalClaimable,
            claimAmount  : _claimAmount,
            expiry : _expiry
        });
        userVesting[_user].push(_vesting);
        return true;
    }
    function claimables(address _user)public view returns(uint256 _totalClaimable)
    {
        uint256 _userClaimable;
        for(uint256 i = 0; i < userVesting[_user].length; i++)
        {
            if(userVesting[_user][i].lastClaimed + vestingTime <= block.timestamp)
            {
                // user can claim tokens, but how many intervals have passed?
                uint256 _timeDiff = block.timestamp - userVesting[_user][i].lastClaimed;
                uint256 _claimCount = _timeDiff / vestingTime;
                uint256 _claimAmount = _claimCount * userVesting[_user][i].claimAmount;
                _userClaimable = _userClaimable + _claimAmount;
            }
        }
        
        return _userClaimable;
    }

    function currentTime()public view returns(uint256 _time)
    {
        return block.timestamp;
    }

    function claimTokens(address _user)public
    {
        for(uint256 i = 0; i < userVesting[_user].length; i++)
        {
            if(userVesting[_user][i].lastClaimed + vestingTime <= block.timestamp)
            {
                if(userVesting[_user][i].totalClaimable == 0)
                {
                    continue;
                }
                else
                {
                    // user can claim tokens, but how many intervals have passed?
                    uint256 _timeDiff = block.timestamp - userVesting[_user][i].lastClaimed;
                    uint256 _claimCount = _timeDiff / vestingTime;
                    uint256 _claimAmount = _claimCount * userVesting[_user][i].claimAmount;
                    // sending tokens...
                    IERC20(ACX).transfer(_user, _claimAmount);
                    // updating records...
                    userVesting[_user][i].lastClaimed = block.timestamp;
                    userVesting[_user][i].totalClaimable = userVesting[_user][i].totalClaimable - _claimAmount;
                }
                
            }
        }
    }

}