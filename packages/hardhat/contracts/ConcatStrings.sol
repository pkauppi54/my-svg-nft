//SPDX-License-Identifier: GPT-3
pragma solidity >=0.8.4;

library ConcatStrings {
    
    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return string(bytes.concat(bytes(a),bytes(b)));
    }
}