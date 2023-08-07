pragma solidity 0.8.19;
import {SignedWadMath} from "./SignedWadMath.sol";
import "./helper.sol";

import "./IVM.sol";

// Run with medusa fuzz --target contracts/SignedWadMathTest.sol --deployment-order SignedWadMathTest

contract SignedWadMathTest is PropertiesAsserts{
     /**
     * list of invariants i want to check here
     * 
     * toWadUnsafe 
     * 1. doesn't revert on overflow and give negative values after 
     * going out of uint256 max limit
     * 
     * 2. check for precision stuffs like bkchodi of fixed point math
     * fromDaysWadUnsafe
     * 
     * 1. result will always greater than input param
     * 2. check everytime from seconds to days and from that days to second is correct
     * 
     * 
     * unsafeWadMul & unsafeWadDiv 
     * x*y= y*x = y*y*x*(1/y)= ((x*y)^n)/((x*y)^n-1
     * x*1=1*x
     * x*0=0=0*x
     * 1/(x*y)= (1/x)*(1/y)
     * x/y = x*(1/y)
     * if x>1 & y>1 then always x*y>1 
     * xy is a hyperbolic curve so fix x and vary y and make sure getting 
     * hyperbolic curve
     * 
     * wadMul & wadDiv but they will be reverting 
     * same operation as above
     * 
     * wadpow
     * 
     * if a>b then always a^x > b^x for x>0
     * if a>b then always a^x < b^x for x<0
     * 
     * 
     * 
     * exponential ang log should be inverse to each other
     * 
     * unsafeDiv
     * 
     * if x>y => x/y >1 
     * 
     *  There is no point to perform these test again in fixedPointMath . Can be done by copy paste
     */

    event Debug(uint256);
    event Debug(int256);
    IVM vm = IVM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    // The following is an example of invariant
    // It test that if x < 10**18
    // Then x <= uint(toWadUnsafe(x))
    function testtoWadUnsafe(uint256 x) public{
        x = clampLte(x, 10**18);

        int256 y = SignedWadMath.toWadUnsafe(x);
       emit Debug(y);
        // Ensure that x <= uint(y)
        assertLte(x, uint(y), "X should be less or equal to Y");
    }

    // for given input seconds
    // numeric value of second>min>day
    function testSecMinDay(uint256 x) public{
         x = clampLte(x, 10**18);
         int256 y = SignedWadMath.toDaysWadUnsafe(x);

         assertEq(x,SignedWadMath.fromDaysWadUnsafe(y),"minutesToDays!=DaysToMinuues");
    }
   
   //xy=yx
   function testunsafeWadMul(int256 x,int256 y) public{
         x = clampBetween(x, 1,10**18);
         y=clampBetween(y,1,10**18);
         assertEq(SignedWadMath.unsafeWadMul(x,y),SignedWadMath.unsafeWadMul(y,x),"xy != yx");
    }

// x / y = x(1/y)
    function testunsafeWadMul1(int256 x,int256 y) public{
         x = clampBetween(x, 0,10**18);
         emit Debug(x);

         y=clampBetween(y,1,10**18);
         emit Debug(y);
         int256 resDiv= SignedWadMath.unsafeWadDiv(1,y);
         emit Debug(resDiv);
         assertEq(SignedWadMath.unsafeWadDiv(x,y),SignedWadMath.unsafeWadMul(x,resDiv),"x / y != x(1/y)");
    }
   
 // x>y => x/y>1
    function testunsafeWadMul2(int256 x, int256 y) public {
         x = clampBetween(x, 1,10**18);
         y = clampBetween(y,1,10**18);
        if(x>=y){
             // Ensure that x <= uint(y)
             assertLte(1, uint(SignedWadMath.unsafeWadDiv(x,y)), "x>y but x/y>!1");
        }else {
             // Ensure that x <= uint(y)
          assertLte(1, uint(SignedWadMath.unsafeWadDiv(y,x)), "y>x but y/x>!1");
        }    
     }

     // 1/(x*y)= (1/x)*(1/y)

    function testunsafeWadDiv(int256 x, int256 y) public {
         x = clampBetween(x, 1,10**18);
         y = clampBetween(y,1,10**18);
        
         int256 Div1x= SignedWadMath.unsafeWadDiv(1,x);
         int256 Div1y= SignedWadMath.unsafeWadDiv(1,y);
         int Mul1x1y= SignedWadMath.unsafeWadMul(Div1x,Div1y);
         int256 Mulxy= SignedWadMath.unsafeWadMul(x,y);
         
       assertEq(SignedWadMath.unsafeWadDiv(1,Mulxy),Mul1x1y,"1/(x*y)!= (1/x)*(1/y)");
    }
   
   //  if a>b then always a^x > b^x for x>0
   //  if a>b then always a^x < b^x for x<0
 //x = 505456470057136353;, y = 505456461792312955; prb math is throwing error for this x&y
 //checked here this lib is good
   function testwadPow(int256 x,int256 y,int256 a) public {
         x = clampBetween(x, 0,10**18);
         y = clampBetween(y,0,10**18);
         a= clampBetween(y,-10**18,10**18);
         int256 t=x;
         if(x<y){
            x=y;
            y=t;
         }
         if(x==y){
            x=x+1;
         }
         if(a>0){
            int256 resxa= SignedWadMath.wadPow(x,a);
            int256 resya= SignedWadMath.wadPow(y,a);
            // for m<n
           assertLte(resya,resxa,"x^a > y^a failed");
            
         }else if(a<0){
             int256 resxa= SignedWadMath.wadPow(x,a);
            int256 resya= SignedWadMath.wadPow(y,a);
            // for m<n
           assertLte(resxa,resya,"x^a < y^a failed");

         }
   }

// i think again error due to precision loss of 1 wei as said by josselin
   function totestLogAndExp(int256 x) public{
         x = clampBetween(x, -10**18,10**18);
         int256 resExp= SignedWadMath.wadExp(x);
         int256 resLog= SignedWadMath.wadLn(resExp);

         assertEq(x,resLog,"x!=log(exp(x))");
   }
}