// SPDX-License-Identifier: Unlicensed
pragma solidity 0.7.5;

import '../interfaces/I_Staking.sol';
import '../interfaces/Isynth.sol';
import '../libraries/SafeMath.sol';
contract ACXExchange{

    using SafeMath for uint256;

     I_Staking public StakingAddr;
     address public feeTo;
     address public SusdAddress = address(0x125d3488283F2A14891518edf7CFE0C08Ce7B16E);
     uint256 public fee;
     uint256 feeUnit=10000;

   
   
    constructor(I_Staking StakingContract) {
         StakingAddr=StakingContract;
              
    }
    
    function convertSynths(address _synth1, address _synth2, address to, uint256 _value) public 
    {
      Isynth  synthToken1 = StakingAddr.GetSynthInfo(_synth1);
      uint256 synthBalance=synthToken1.balanceOf(msg.sender);
      require(_value <= synthBalance,"insufficient synth balance");
      uint256 usdValue = synthToken1.synthToUsd(_value);
      uint256 feeInUsd = (usdValue.mul(fee)).div(feeUnit);//100 x 100 (100 % factor ,100 fee unit factor)
      uint256 usdValueAfterFee = usdValue.sub(feeInUsd.div(100));
      Isynth  synthToken2 = StakingAddr.GetSynthInfo(_synth2);
      uint256 synthValue =synthToken2.usdToSynth(usdValueAfterFee);
      synthToken1.burn(to, _value);
      synthToken2.mint(to, synthValue);
      Isynth  usdSynth = Isynth(0x125d3488283F2A14891518edf7CFE0C08Ce7B16E);
      uint256 usdSynthValue =usdSynth.usdToSynth(feeInUsd);
      usdSynth.mint(feeTo, usdSynthValue); 
    }
    

    function setFeeTo(address feeAddress) public {
      feeTo=feeAddress;
    }

    function setFee(uint256 Fee) public {
      fee=Fee;
    }

  
}
 