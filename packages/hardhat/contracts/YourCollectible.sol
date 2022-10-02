pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//import 'base64-sol/base64.sol';

import "./HexStrings.sol";
import "./ToColor.sol";
// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract YourCollectible is ERC721, Ownable {

  using Strings for uint256;
  using HexStrings for uint160;
  using ToColor for bytes3;
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIds;


  constructor() public ERC721("MyToken", "MYTK") {
      // Add something
  }

  mapping (uint256 => uint256) public score;
  mapping (uint256 => uint256[]) public boards; // tokenId -> jenga board
  // some more mappings

  uint256 mintDeadline = block.timestamp + 24 hours;



  function mintItem() public returns (uint256) {
    require (block.timestamp < mintDeadline, "Minting has ended" );
    _tokenIds.increment();

    uint256 id = _tokenIds.current();
    _mint(msg.sender, id);

    // jenga board initialization: 1 = block
    for (uint256 i= 0; i<19; i++) {
      boards[id].push(1);
    }



    // creating some random values

    // giving this "id" some values from these random values
    // color[id] = bytes2(predictableRandom[0]) | ( bytes2(predictableRandom[1]) >> 8 ) | ( bytes3(predictableRandom[2]) >> 16 );
    // chubbiness[id] = 35+((55*uint256(uint8(predictableRandom[3])))/255);

  }

  function tokenURI(uint256 id) public view override returns (string memory) {
    require(_exists(id), "This token id doesn't exist");
    
    // assign some info for the given id:

    // string memory name = string(abi.encodePacked('Loogie #',id.toString()));
    // string memory description = string(abi.encodePacked('This Loogie is the color #',color[id].toColor(),' with a chubbiness of ',uint2str(chubbiness[id]),'!!!'));
    // string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

    // then create the tokenURI data:

    // return
    //       string(
    //           abi.encodePacked(
    //             'data:application/json;base64,',
    //             Base64.encode(
    //                 bytes(
    //                       abi.encodePacked(
    //                           '{"name":"',
    //                           name,
    //                           '", "description":"',
    //                           description,
    //                           '", "external_url":"https://burnyboys.com/token/',
    //                           id.toString(),
    //                           '", "attributes": [{"trait_type": "color", "value": "#',
    //                           color[id].toColor(),
    //                           '"},{"trait_type": "chubbiness", "value": ',
    //                           uint2str(chubbiness[id]),
    //                           '}], "owner":"',
    //                           (uint160(ownerOf(id))).toHexString(20),
    //                           '", "image": "',
    //                           'data:image/svg+xml;base64,',
    //                           image,
    //                           '"}'
    //                       )
    //                     )
    //                 )
    //           )
    //       );


  }


  function generateSVGofTokenById(uint256 id) internal view returns (string memory) {
    string memory svg = string(abi.encodePacked(
      '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
      renderTokenById(id),
      '<svg>'
    ));

    return svg;
  }


  function renderTokenById(uint256 id) internal view returns (string memory) {
    string memory render = string(abi.encodePacked(
      '<svg'
    ));

    return render;
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
      if (_i == 0) {
          return "0";
      }
      uint j = _i;
      uint len;
      while (j != 0) {
          len++;
          j /= 10;
      }
      bytes memory bstr = new bytes(len);
      uint k = len;
      while (_i != 0) {
          k = k-1;
          uint8 temp = (48 + uint8(_i - _i / 10 * 10));
          bytes1 b1 = bytes1(temp);
          bstr[k] = b1;
          _i /= 10;
      }
      return string(bstr);
  }




}
