pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

library SumArray {
    function sumArray(uint8[3] memory array) internal pure returns (uint256) {
        uint256 sum;
        for (uint256 i=0; i<3; i++) {
            sum+=array[i];
        }
        return sum;
    }
}