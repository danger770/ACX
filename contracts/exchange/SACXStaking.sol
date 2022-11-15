// SPDX-License-Identifier: Unlicensed
pragma solidity 0.7.5;

import '../interfaces/Isynth.sol';
import '../interfaces/IsacxToken.sol';
import '../libraries/SafeMath.sol';
import "../interfaces/IRouter.sol";
import "../interfaces/IFactory.sol";
import "../interfaces/ILpToken.sol";

contract SACXStaking{

    using SafeMath for uint256;

    IsacxToken public WsacxToken;
    uint256 public collatteralRatio = 750;
    mapping (address => Staker) public StakerInfo;
    uint256 public WsacxPrice;
    uint256 public Synthprice;
    mapping (address => bool) public getSynthInfo;
    address[] public synthAddresses;
    uint256 public StakedCollateral;
    address public Factory=address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    address public Router=address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public ACXtokenAddress;
    address public DAItokenAddress;
    uint256 public synthCount;

    event Transfer(address indexed from, address indexed to, uint256 value);


      struct Staker{ 
        uint256 TotalSacxStakedAsCollateral; 
    }
    
   
    constructor(IsacxToken wrappedAddress,address acxToken, address daiToken){
         WsacxToken= wrappedAddress;    
         ACXtokenAddress=acxToken;
         DAItokenAddress=daiToken;
    }


//function stakes the SACX token as collateral and mints synths by calculating 
//the respective prices
     function StakeSacx(address _synth, uint256 amount) external  {
        Isynth synthToken1 = GetSynthInfo(_synth);
        uint256 TotalSynthPrice=synthToken1.synthToUsd(amount);//synthPriceinUSD.mul(amount);//price of 10 synth e.g 10 sETH = 1000$
        uint256 collatteralPrice = ((TotalSynthPrice.mul(collatteralRatio)).div(100));//price of the collateral we need to stake
        uint256 CollatteralToStake= SacxToWsacx(collatteralPrice);//price of 1 SACX
        require(WsacxToken.balanceOf(msg.sender) >= CollatteralToStake,"User does not have sufficient SACX to Mint synths");
        WsacxToken.transferFrom(msg.sender,address(this),CollatteralToStake);
        StakedCollateral=StakedCollateral.add(CollatteralToStake);
        StakerInfo[msg.sender].TotalSacxStakedAsCollateral= StakerInfo[msg.sender].TotalSacxStakedAsCollateral.add(CollatteralToStake);
        synthToken1.mint(msg.sender,amount);     
        
    }
  
//function unstakes SACX for a given amount of synth provided by user
   function UnstakeSacx(address _synth, uint256 amount) external
   {
      uint256 UsdPrice=SynthUsdValue(_synth,amount);
      Isynth synthToken1 = Isynth(GetSynthInfo(_synth));
      uint256 TotalStakedSacx=totalSacx();
      uint256 TotalSynthUsd=totalDollarprice();
      uint256 UserGets=(UsdPrice.div(TotalSynthUsd)).mul(TotalStakedSacx);
      WsacxToken.transfer(msg.sender,UserGets);
      StakerInfo[msg.sender].TotalSacxStakedAsCollateral= StakerInfo[msg.sender].TotalSacxStakedAsCollateral.sub(UserGets);
      StakedCollateral=StakedCollateral.sub(UserGets);
      synthToken1.burn(msg.sender,amount); 
   }

//returns the dollar price for an amount of synthetic asset
//e.g; *(1 sTSLA = 1$) so 100 sTSLA = 100$ 
   function SynthUsdValue(address  synthAddr,uint256 amount) public view returns (uint256)
   {
    
     Isynth synthToken1 = GetSynthInfo(synthAddr);
     uint256 totalValue=synthToken1.synthToUsd(amount);
     return totalValue;
      
   }
   function UsdToSynth (address  synthAddr,uint256 amount) public view returns (uint256) {
     Isynth synthToken1 = GetSynthInfo(synthAddr);
     uint256 totalValue=synthToken1.usdToSynth (amount);
      return totalValue;
  }



   //function returns the total amount of SACX tokens staked in the contract.
   function totalSacx() public view returns (uint256)
   {
     //uint256 TotalStakedSacx=SacxToken.balanceOf(address(this));
     return StakedCollateral;
      
   }



//function returns the total amount of synthetic tokens minted 
//by adding total supply of each synth
   function totalSynths()public view returns(uint256){
     uint256 totalTokens;
for (uint256 i = 0; i < synthAddresses.length; i++){
        Isynth synthToken1 = GetSynthInfo(synthAddresses[i]);
        uint256 TotalSynthSupply=synthToken1.totalSupply();
        totalTokens=totalTokens.add(TotalSynthSupply);   
      }
      return totalTokens;
 
   }

   //returns the dollar value of total synthetic assets in the pool
   //e.g; total synths in pool= 200, dollar worth =300$
 function totalDollarprice()public view returns(uint256){
     uint256 dollarvalue;
     for (uint256 i = 0; i < synthAddresses.length; i++){
        Isynth synthToken1 = GetSynthInfo(synthAddresses[i]);
        uint256 totalTokens=synthToken1.totalSupply();//total supply
        uint256 DollarPrice=synthToken1.synthToUsd(totalTokens);//dollar price of 1 synth token
        dollarvalue=dollarvalue.add(DollarPrice);
      
     }
        
      return dollarvalue;
 
   }


 //function stores the synthetic asset addresses and info to use in the system
    function SetSynthInfo(address synthAddress) public {
        require(!getSynthInfo[synthAddress], "Synth is already existing");
        getSynthInfo[synthAddress]=true;
        synthAddresses.push(synthAddress); 
        synthCount++;

    }
//function gets the synthetic asset addresses and info to use in the system
    function GetSynthInfo(address synthAddress) public view returns(Isynth){
      require(getSynthInfo[synthAddress], "Synth is does not exist");
      address _address;
        for (uint256 i = 0; i < synthAddresses.length; i++){
        if(synthAddresses[i] == synthAddress)  
         {
           _address=address(synthAddress);
           break;
         }
        }
       return Isynth(_address);
    }

    //set the price of SACX token
    function SetWsacxPrice(uint256 price) public {
        
        WsacxPrice=price;
    }
   
     //function getSacxPrice() public  view returns(uint256){
  function getSacx( address _DAI, uint _amount ) public view returns ( uint value ) 
    {
        uint112 _acxTokenReserve;
        uint112 _daiTokenReserve;
        uint32 _blockTimestampLast;
        uint256 amountACX;
        
           address LpToken = IFactory(Factory).getPair(_DAI, ACXtokenAddress);
           require(LpToken != address(0));
           if(ILpToken(LpToken).token0() == _DAI)
           {
            (_daiTokenReserve, _acxTokenReserve, _blockTimestampLast) = ILpToken(LpToken).getReserves();
            amountACX = IRouter(Router).quote(_amount, _daiTokenReserve, _acxTokenReserve);
            return amountACX;
           }


           {
            (_acxTokenReserve, _daiTokenReserve, _blockTimestampLast) = ILpToken(LpToken).getReserves();
            amountACX = IRouter(Router).quote(_amount, _daiTokenReserve, _acxTokenReserve);
            return amountACX;
            }
  

       // return SacxPrice;       
    }
     
      function SacxToWsacx(uint256 amount) public view returns (uint256) {
      uint256 _Sacx=getSacx(DAItokenAddress,amount.mul(10**9));
      uint256 WsacxAmount = WsacxToken.SACXTowSACX(_Sacx);
      return  WsacxAmount;
    
  }
   }
