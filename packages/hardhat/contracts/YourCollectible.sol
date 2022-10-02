pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import './base64.sol';

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

  event Play(address player, uint256 tokenId, uint256 score);
  event SvgGenerated(string svgCode);

  uint256 highestScore = 0;

  constructor() public ERC721("Jenga", "JENGA") {
      // Add something
  }

  mapping (uint256 => uint256) public score;
  mapping (uint256 => uint8[3][18]) public boards; // tokenId -> jenga board
  mapping (uint256 => bytes3) public color;
  mapping (uint256 => string) public ellipseColor;
  mapping (uint256 => string[]) internal groups;

  // tokenID => Struct for the groups?


  uint256 mintDeadline = block.timestamp + 24 hours;
  


  function mintItem() public returns (uint256) {
    require (block.timestamp < mintDeadline, "Minting has ended" );
    _tokenIds.increment();

    uint256 id = _tokenIds.current();
    _mint(msg.sender, id);
    boards[id] = [[1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1]];

    
    // generating randoms
    bytes32 predictableRandom = keccak256(abi.encodePacked( blockhash(block.number-1), msg.sender, address(this) ));

    color[id] = bytes2(predictableRandom[0]) | ( bytes2(predictableRandom[1]) >> 8 ) | ( bytes3(predictableRandom[2]) >> 16 );

    return id;

  }

  function play(uint256 id) public returns (uint8[3][18] memory) {
    require(ownerOf(id) == msg.sender);
    
    

    return boards[id];
  }


  function tokenURI(uint256 id) public view override returns (string memory) {
    //require(_exists(id), "This token id doesn't exist");
    string memory name = string(abi.encodePacked("Board #", id.toString()));
    string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

    return 
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"',
                name,
                '", "description":"',
                "On-Chain Jenga",
                '", "external_url":"https://on-chain-jenga.surge.sh", "attributes": ',
                getAttributesForToken(id),
                '"owner":"',
                (uint160(ownerOf(id))).toHexString(20),
                '", "image": "',
                'data:image/svg+xml;base64,',
                image,
                '"}'
              )
            )
          )
        )
      );
    
  
  }

  function getAttributesForToken(uint256 id) internal view returns (string memory) {
    return string(abi.encodePacked(
      '[{"trait_type": "score", "value": ',
      uint2str(score[id]),
      '}, {"trait_type": "color", "value": "#',
      color[id].toColor(),'"}],'
    ));
  }



  function generateSVGofTokenById(uint256 id) internal view returns (string memory) {
    
    string memory svg = string(abi.encodePacked(
      '<svg id="erbvmNVDPOR1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 600 600" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" style="background-color:', color[id], '">',
      renderTokenById(id),
      '<svg>'
    ));
    
    return svg;
  }


  function generateGroups(uint256 id) public returns (string[] memory) {
    groups[id][0] = "helloo";
    return groups[id];
  }
  

  function renderTokenById(uint256 id) internal view returns (string memory) {
    string memory block1 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(279.884074 202.028018)" paint-order="fill markers stroke" fill="none" stroke="#000" stroke-linejoin="bevel"/>';
    string memory block2 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(291.384074 202.028018)" paint-order="fill markers stroke" fill="none" stroke="#000" stroke-linejoin="bevel"/>';
    string memory block3 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(302.884074 202.028018)" paint-order="fill markers stroke" fill="none" stroke="#000" stroke-linejoin="bevel"/>';
    string memory longRect = '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>';
    
    string[] memory group = groups[id];
    
    string memory render = string(abi.encodePacked(
      '<g transform="matrix(4.162486 0 0 4.242252-1060.704517-776.369059)"><g transform="translate(-1.321996 0.528799)">',
      '<g transform="matrix(1 0 0 0.604719 0.22 82.8471)">', 
      tower11(group),
      tower12(group),
      tower21(group),
      tower22(group),
      ellipseColor[id], ' stroke-width="0"/><text dx="0" dy="0" font-size="50" font-weight="400" transform="translate(274.948282 76.963439)" stroke-width="0">',

      score[id], '</text>'
    ));

    return render;
  }

  function tower11(string[] memory group) internal pure returns (string memory) {
    return string(abi.encodePacked(group[0], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/></g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">',group[2], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/></g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">',group[4], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/></g><g transform="translate(0 34.290344)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">', group[6]));
  }
  function tower12(string[] memory group) internal pure returns (string memory) {
    return string(abi.encodePacked('<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/></g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">', group[8], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/></g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">', group[10], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/> </g></g><g transform="translate(0 68.566717)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">', group[12], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/> </g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">', group[14], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/> </g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">', group[16], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/> </g></g></g><g transform="matrix(-1 0 0-1 655.116165 512.630228)">'));
  }
  function tower21(string[] memory group) internal pure returns (string memory) {
    return string(abi.encodePacked('<g transform="matrix(1 0 0 0.604719 0.22 82.8471)">',group[1], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">', group[3], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">', group[5], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="translate(0 34.290344)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">',group[7], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">',group[9]));
  }
  function tower22(string[] memory group) internal pure returns (string memory) {
    return string(abi.encodePacked('<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">',group[11], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>', '</g></g><g transform="translate(0 68.566717)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">',group[13], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">',group[15], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">',group[17], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>', '</g></g></g></g><ellipse rx="78.191788" ry="37.8993" transform="translate(300 57.588093)" fill=' ));
  }


  function getBoard(uint256 id) public view returns (uint8[3][18] memory) {
      return boards[id];
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
