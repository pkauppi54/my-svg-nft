// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library ToColor {
    bytes16 internal constant ALPHABET = "0123456789abcdef";

    function toColor(bytes3 value) internal pure returns (string memory) {
        bytes memory buffer = new bytes(6); 
        for (uint256 i = 0; i < 3; i++) {
            buffer[i*2+1] = ALPHABET[uint8(value[i]) & 0xf]; 
            buffer[i*2] = ALPHABET[uint8(value[i]>>4) & 0xf];  // >> is right shift 
        }
        return string(buffer);
    }

    // bytes3 == array of 3 bytes so:
    // bytes3 == 0x000000 
    // bytes2 = 0x0000

    // Our color is assigned as follows: bytes2(predictableRandom[0]) | ( bytes2(predictableRandom[1]) >> 8 ) | ( bytes3(predictableRandom[2]) >> 16 );

    // "|" is the or operator. This will return a 1 if one of the bytes has 1 and 0 if neither of them have a 1.
    // bytes2 = [byte, byte], bytes2(predictableRandom[0]) 

    // 1 hexadecimal digit = 4 bits, everything in a byte array are in the form of hexadecimal digits

}