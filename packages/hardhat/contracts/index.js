// this script used to check if the number is even or odd


var block1 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(279.884074 202.028018)" paint-order="fill markers stroke" fill="none" stroke="#000" stroke-linejoin="bevel"/>'
var block2 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(291.384074 202.028018)" paint-order="fill markers stroke" fill="none" stroke="#000" stroke-linejoin="bevel"/>'
var block3 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(302.884074 202.028018)" paint-order="fill markers stroke" fill="none" stroke="#000" stroke-linejoin="bevel"/>'
var longRect = '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>'


var highestScore = 15

var groups = []
var board = [ [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1]] 
var score = 10
var backgroundColor = "#DBB7B7"
var ellipseColor = "#ffff"
function generateVariables() {
    let ellipseColor;
    if (score > highestScore) {
        ellipseColor = "#ffdc34"
    } else (
        ellipseColor = "#ffff"
    )

    var backgroundColor = "#DBB7B7"
    //var score = scores[tokenId]
}

function createGroups() {
    for (let i = 0; i < board.length; i++) {
        let currentRow = board[i]; // board[id][i] == uint8[3]
        
        if (currentRow[0] == 1 && currentRow[1] == 1 && currentRow[2] == 1) {
            groups[i] = block1 + block2 + block3
        }
        else if (currentRow[0] == 1 && currentRow[1] == 1 && currentRow[2] == 0) {
            groups[i] = block1 + block2
        }
        else if ( currentRow[0] == 1 && currentRow[1] == 0 && currentRow[2] == 1) {
            groups[i] = block1 + block3
        }
        else if ( currentRow[0] == 0 && currentRow[1] == 1 && currentRow[2] == 1) {
            groups[i] = block2 + block3
        } 
        else if ( currentRow[0] == 1 && currentRow[1] == 0 && currentRow[2] == 0) {
            groups[i] = block1
        } 
        else if ( currentRow[0] == 0 && currentRow[1] == 1 && currentRow[2] == 0) {
            groups[i] = block2
        }
        else if ( currentRow[0] == 0 && currentRow[1] == 0 && currentRow[2] == 1) {
            groups[i] = block3
        }
    }
}

function getSvg() {
    var svg = '<svg id="erbvmNVDPOR1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 600 600" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" style="background-color:' + backgroundColor + '"><g transform="matrix(4.162486 0 0 4.242252-1060.704517-776.369059)"><g transform="translate(-1.321996 0.528799)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">'+ groups[0] + longRect + '</g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">' +groups[2] + longRect + '</g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">' + groups[4] + longRect + '</g><g transform="translate(0 34.290344)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">' + groups[6] + longRect + '</g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">' + groups[8] + longRect + '</g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">' + groups[10] + longRect + '</g></g><g transform="translate(0 68.566717)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">' + groups[12] + longRect + '</g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">' + groups[14] + longRect + '</g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">' + groups[16] + longRect + '</g></g></g><g transform="matrix(-1 0 0-1 655.116165 512.630228)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">' + groups[1] + longRect + '</g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">' + groups[3]+ longRect + '</g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">' + groups[5] + longRect + '</g><g transform="translate(0 34.290344)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">' + groups[7] + longRect + '</g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">' + groups[9] + longRect + '</g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">' + groups[11] + longRect + '</g></g><g transform="translate(0 68.566717)"><g transform="matrix(1 0 0 0.604719 0.22 82.8471)">' + groups[13] + longRect + '</g><g transform="matrix(1 0 0 0.604719 0.22 94.254655)">' + groups[15] + longRect+ '</g><g transform="matrix(1 0 0 0.604719 0.22 105.66221)">' + groups[17] + longRect + '</g></g></g></g><ellipse rx="78.191788" ry="37.8993" transform="translate(300 57.588093)" fill='+ ellipseColor +' stroke-width="0"/><text dx="0" dy="0" font-size="50" font-weight="400" transform="translate(274.948282 76.963439)" stroke-width="0">' + score + '</text></svg>'
    console.log(svg)
}

function play() {
    // randomly eliminate a block from the board


}


generateVariables();
createGroups();
getSvg();
