pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


import './base64.sol';

import "./SumArray.sol";
import "./HexStrings.sol";
import "./ToColor.sol";
import "./ConcatStrings.sol";
// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Jenga is ERC721Enumerable, Ownable {

  using Strings for uint256;
  using HexStrings for uint160;
  using ToColor for bytes3;
  using Counters for Counters.Counter;
  using ConcatStrings for string;
  using SumArray for uint8[3];

  Counters.Counter private _tokenIds;

  event Play(address player, uint256 tokenId, uint8[3][18] board, uint256 score);
  event SvgGenerated(string svgCode);

  constructor() public ERC721("Jengaaa", "JENGaaA") {
      // Add something
  }

  // all these mappings are from tokenId -> <value>
  mapping (uint256 => uint256) public score;          // score of the tokenId
  
  mapping (uint256 => uint8[3][18]) public boards;    // board: array with 18 3-length arrays
  
  mapping (uint256 => bytes3) public color;           // background color of the NFT
  
  mapping (uint256 => string) public ellipseColor;    // ellipse color of the NFT, might remove this and default to white
  
  mapping (uint256 => string[18]) internal groups;    // length 18 array with the svg code of the blocks, regenerated everytime a block is removed 
  
  mapping (uint256 => bool) public fallen;            // has the jenga fallen

  mapping (uint256 => uint256) public blocksRemoved;  // blocks removed used for the score calculation



  uint256 mintDeadline = block.timestamp + 24 hours;

  uint256 highestScore;
  uint256 leader;  // leading tokenID for golden color

  uint256 public nonceForRandom = 0; // nonce for the hash when generating "random" numbers



  function mintItem() public payable returns (uint256) {
    require (block.timestamp < mintDeadline, "Minting has ended" );
    _tokenIds.increment();

    uint256 id = _tokenIds.current();
    _safeMint(msg.sender, id);

    generateBoard(id);    
    generateGroups(id);

    // generating randoms

    bytes32 predictableRandom = keccak256(abi.encodePacked( blockhash(block.number-1), msg.sender, address(this) ));
    color[id] = bytes2(predictableRandom[0]) | ( bytes2(predictableRandom[1]) >> 8 ) | ( bytes3(predictableRandom[2]) >> 16 ); 
    ellipseColor[id] = '"#ffffff"';
    score[id] = 0;


    return id;

  }

  // GENERATION FUNCTIONS:

  function getRandomNum(address sender, uint256 _modulus) internal returns (uint256) {
    nonceForRandom++;
    // This should return an integer between 0-99 if the modulus is 100 which takes the last two digits
    return uint256(keccak256(abi.encodePacked(
        blockhash(block.number-1),
        sender,
        address(this),
        nonceForRandom
      ))) % _modulus;
  }


  function generateBoard(uint256 id) internal returns (uint8[3][18] memory) {
    boards[id] = [[1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1]];
    return boards[id];
  }


  function generateGroups(uint256 id) internal returns (string[18] memory) {
    
    string[18] memory group;

    for (uint256 i = 0; i < 18; i++) {
      //uint8[3][18] memory board = boards[id];
      uint8[3] memory currentRow = boards[id][i];
      

      if (currentRow[0] == 1 && currentRow[1] == 1 && currentRow[2] == 1) {
        group[i] = block1.concat(block2).concat(block3);
      } 
      else if (currentRow[0] == 1 && currentRow[1] == 1 && currentRow[2] == 0) {
        group[i] = block1.concat(block2);
      }
      else if ( currentRow[0] == 1 && currentRow[1] == 0 && currentRow[2] == 1) {
        group[i] = block1.concat(block3);
      }
      else if ( currentRow[0] == 0 && currentRow[1] == 1 && currentRow[2] == 1) {
        group[i] = block2.concat(block3);
      } 
      else if ( currentRow[0] == 1 && currentRow[1] == 0 && currentRow[2] == 0) {
        group[i] = block1;
      } 
      else if ( currentRow[0] == 0 && currentRow[1] == 1 && currentRow[2] == 0) {
        group[i] = block2;
      }
      else if ( currentRow[0] == 0 && currentRow[1] == 0 && currentRow[2] == 1) {
        group[i] = block3;
      } else {
        group[i] = "";
      }

    }
    groups[id] = group;

    return groups[id];
  }

///////////


  function play(uint256 id, uint256 blocksToRemove) public returns (uint8[3][18] memory) {
    require(ownerOf(id) == msg.sender, "Not the owner");
    require(fallen[id] == false, "This tower has fallen");
    
    //require(boards[id][randomFloor][randomBlock] != 0, "Please play again, block empty :)");
    // if the row is not empty: remove block and add to score
    // else if there is only two blocks: Emit a fumbling event?
    // else the row turns empty: tower falls

     
    // this deletes 4 blocks at once
    for (uint256 i = 0; i < blocksToRemove; i++) {
      uint256 randomFloor = getRandomNum({ sender: msg.sender, _modulus: 18 });
      uint256 randomBlock = getRandomNum({ sender: msg.sender, _modulus: 3 });

      if (boards[id][randomFloor][randomBlock] != 0 && 
          boards[id][randomFloor].sumArray() >=2 && 
          fallen[id] == false) { 
        
        boards[id][randomFloor][randomBlock] = 0; // block is taken off
        uint256 blocksLeftInRow = 1;
        blocksRemoved[id] += 1;
        score[id] += randomFloor * blocksRemoved[id] / blocksLeftInRow;
      } else {
        fallen[id] = true;
        // emit Fall(msg.sender, id, board[id], score[id]);
      }
    }
    
    // // this only deletes one
    // if (boards[id][randomFloor][randomBlock] != 0 && boards[id][randomFloor].sumArray() >=2) { 
    //   boards[id][randomFloor][randomBlock] = 0; // block is taken off
    //   uint256 blocksLeftInRow = 1;
    //   blocksRemoved[id] += 1;
    //   score[id] += randomFloor * blocksRemoved[id] / blocksLeftInRow;
    // } else {
    //   fallen[id] = true;
    // }


    if (score[id] > highestScore) {
      leader = id;
      highestScore = score[id];
    }

    generateGroups(id);

    emit Play(msg.sender, id, boards[id], score[id]);
  }


  // image = Base64.encode(bytes(string(abi.encodePacked('<svg....'>, string(abi.encodepacked(render))))))

  function tokenURI(uint256 id) public view override returns (string memory) {
    //require(_exists(id), "This token id doesn't exist");
    
    string memory name = string(abi.encodePacked("Board #", id.toString()));
    string memory image = fallen[id] ? Base64.encode(bytes(generateFallenSVG(id))) : Base64.encode(bytes(generateSVGofTokenById(id)));

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
      color[id].toColor(),'"',
      '}, {"trait_type": "fallen", "value": "',
      fallen[id] ? "fallen" : "standing",
      '"}],'
    ));
  }



  function generateSVGofTokenById(uint256 id) internal view returns (string memory) {
    
    string memory svg = string(abi.encodePacked(
      '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 600 600" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" style="background-color:', id == leader ? "rgb(255,215,0)" : color[id].toColor(), '">',
      renderTokenById(id),
      '</svg>'
    ));
    
    return svg;
  }

  function generateFallenSVG(uint256 id) internal view returns (string memory) {
    string memory svg = string(abi.encodePacked(
      '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 600 600" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" style="background-color:', color[id].toColor(), '">',
      '<text dx="0" dy="0" font-size="50" font-weight="400" transform="translate(274.948282 76.963439)" stroke-width="0"> Tower has fallen </text>',
      '</svg>'
    ));
    return svg;
  }


  // Generating the groups for svg rendering. 
  // "groups" are the rows in the jenga tower that consist of small blocks. Every time we want to modify the tower we need to call this function.
  // Rendering the single blocks for this game was the hardest part and I'm sure there are many better ways to do this as well.
  // Main thing to spot here is that the "boards" mapping has integers and the "groups" mapping has strings which follow the board numbers.
  string block1 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(279.884074 202.028018)" paint-order="fill markers stroke" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/>';
  string block2 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(291.384074 202.028018)" paint-order="fill markers stroke" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/>';
  string block3 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(302.884074 202.028018)" paint-order="fill markers stroke" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/>';
  
  


  function renderTokenById(uint256 id) public view returns (string memory) {
    
    string[18] memory group = groups[id];
    
    string memory render = string(abi.encodePacked(
      '<g transform="matrix(4.162486 0 0 4.242252-1060.704517-776.369059)"><g transform="translate(-1.321996 0.528799)">',
      '<g transform="matrix(1 0 0 0.604719 0.22 82.8471)">', 
      tower11(group),
      tower12(group),
      tower21(group),
      tower22(group),
      ellipseColor[id], ' stroke-width="0"/><text dx="0" dy="0" font-size="50" font-weight="400" transform="translate(274.948282 76.963439)" stroke-width="0">',

      uint2str(score[id]), '</text>'
    ));

    return render;
  }

  function tower11(string[18] memory group) internal pure returns (string memory) {
    return string(abi.encodePacked(group[0], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/></g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">',group[2], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/></g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">',group[4], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/></g><g transform="translate(0 34.290344)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">', group[6]));
  }
  function tower12(string[18] memory group) internal pure returns (string memory) {
    return string(abi.encodePacked('<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/></g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">', group[8], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/></g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">', group[10], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/> </g></g><g transform="translate(0 68.566717)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">', group[12], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/> </g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">', group[14], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/> </g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">', group[16], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/> </g></g></g><g transform="matrix(-1 0 0-1 655.116165 512.630228)">'));
  }
  function tower21(string[18] memory group) internal pure returns (string memory) {
    return string(abi.encodePacked('<g transform="matrix(1 0 0 0.604719 0.22 82.8471)">',group[1], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">', group[3], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">', group[5], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="translate(0 34.290344)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">',group[7], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">',group[9]));
  }
  function tower22(string[18] memory group) internal pure returns (string memory) {
    return string(abi.encodePacked('<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">',group[11], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/>', '</g></g><g transform="translate(0 68.566717)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">',group[13], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">',group[15], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/>', '</g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">',group[17], '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="#ffffff" stroke="#000" stroke-linejoin="bevel"/>', '</g></g></g></g><ellipse rx="78.191788" ry="37.8993" transform="translate(300 57.588093)" fill='));
  }



  /// TEST FUNCTIONS: 

  function getBoard(uint256 id) public view returns (uint8[3][18] memory) {
      return boards[id];
  }

  function getGroup(uint256 id) public view returns (string[18] memory) {
    return groups[id];
  }

  function getPredictableRandom() public view returns (bytes32) {
    bytes32 predictableRandomm = keccak256(abi.encodePacked( blockhash(block.number-1), msg.sender, address(this) ));

    return bytes32(predictableRandomm);
  }
  function getColor(uint256 id) public view returns (bytes3) {
    return color[id];
  }


//

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
