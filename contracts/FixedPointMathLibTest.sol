pragma solidity 0.8.19;

import {FixedPointMathLib} from "./FixedPointMathLib.sol";
import "./helper.sol";
import "./IVM.sol";

// Run with medusa fuzz --target contracts/FixedPointMathLibTest.sol --deployment-order FixedPointMathLibTest


contract FixedPointMathLibTest is PropertiesAsserts{

    event Debug(uint256);
    IVM vm = IVM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    // The following is an example of invariant
    // It test that if z = x / y, then z <= x
    // For any x and y greater than 1 unit
    function testDivWadDown(uint256 x, uint256 y) public{

        // We work with a decimals of 18
        uint decimals = 10**18; 

        // Ensure x and y are greater than 1
        x = clampGte(x, decimals);
        y = clampGte(y, decimals);

        // compute z = x / y
        uint z = FixedPointMathLib.divWadDown(x, y);

        // Ensure that z <= x
        assertLte(z, x, "Z should be less or equal to X");
    }


    /**
     * check for all the things that was in signedMathWad
     */
// x*y=y*x
    function testrPow(uint256 x,uint256 y,uint256 a) public{
        //  uint decimals = 10**18; 

         x = clampBetween(x, 0,10**18);
         y = clampBetween(y,0,10**18);
         a= clampBetween(y,0,10**18);
        //ensure a>0
       // a = clampGte(a, 0);
       uint256 scalar = 10**18;
        uint256 t=x;
         if(x<y){
            x=y;
            y=t;
         }
         if(x==y){
            x=x+1;
         }
         if(a>0){
            uint256 resxa= FixedPointMathLib.rpow(x,a,scalar);
            uint256 resya= FixedPointMathLib.rpow(y,a,scalar);
            // for m<n
           assertLte(resya,resxa,"x^a > y^a failed");
            
         }else if(a<0){
             uint256 resxa= FixedPointMathLib.rpow(x,a,scalar);
            uint256 resya= FixedPointMathLib.rpow(y,a,scalar);
            // for m<n
           assertLte(resxa,resya,"x^a < y^a failed");

         }

    }
   // sqrt(x)= rpow(x,1/2,scalar)

   function testSqrtToRpow(uint256 x) public{

        uint decimals = 10**18; 

        // Ensure x and y are greater than 1
        x = clampGte(x, decimals);

        uint256 n=(10**18)/2;
        uint256 scalar= 10**18;

        // uint256 a= FixedPointMathLib.sqrt(100*(10**18));
        // emit Debug(a);
        // uint256 b= FixedPointMathLib.rpow(100*(10**18),(10**18)/2,scalar);
        // emit Debug(b);
        //assertEq(FixedPointMathLib.sqrt(x),FixedPointMathLib.rpow(x,n,scalar),"sqrt(x) != rpow(x,1/2,scalar)");

   }

   
}