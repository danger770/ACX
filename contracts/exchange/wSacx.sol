// SPDX-License-Identifier: MIT
import "../utils/ERC20.sol";
import "../libraries/SafeERC20.sol";
import "../interfaces/IsacxToken.sol";
pragma solidity 0.7.5;

contract wSACX is ERC20 {
    using SafeERC20 for ERC20;
    using Address for address;
    using SafeMath for uint;

    address public immutable SACX;

    constructor( address _SACX ) ERC20( 'Wrapped SACX', 'wSACX', 9) {
        require( _SACX != address(0) );
        SACX = _SACX;
    }

    /**
        @notice wrap SACX
        @param _amount uint
        @return uint
     */
    function wrap( uint _amount ) external returns ( uint ) {
        IERC20(SACX).transferFrom( msg.sender, address(this), _amount );
        
        uint value = SACXTowSACX( _amount );
        _mint( msg.sender, value );
        return value;
    }

    /**
        @notice unwrap SACX
        @param _amount uint
        @return uint
     */
    function unwrap( uint _amount ) external returns ( uint ) {
        _burn( msg.sender, _amount );

        uint value = wSACXToSACX( _amount );
        IERC20( SACX ).transfer( msg.sender, value );
        return value;
    }

    /**
        @notice converts wSACX amount to SACX
        @param _amount uint
        @return uint
     */
    function wSACXToSACX( uint _amount ) public view returns ( uint ) {
        return _amount.mul( IsacxToken( SACX ).index() ).div( 10 ** decimals() );
    }

    /**
        @notice converts SACX amount to wSACX
        @param _amount uint
        @return uint
     */
    function SACXTowSACX( uint _amount ) public view returns ( uint ) {
        return _amount.mul( 10 ** decimals() ).div(IsacxToken( SACX ).index() );
    }

}