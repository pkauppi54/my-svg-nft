var block1 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(279.884074 202.028018)" paint-order="fill markers stroke" fill="none" stroke="#000" stroke-linejoin="bevel"/>'
var block2 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(291.384074 202.028018)" paint-order="fill markers stroke" fill="none" stroke="#000" stroke-linejoin="bevel"/>'
var block3 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(302.884074 202.028018)" paint-order="fill markers stroke" fill="none" stroke="#000" stroke-linejoin="bevel"/>'
var longRect = '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>'

var groups = []

// var score = scores[tokenId]


var board = [ [0, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1]] 



function createGroups() {
    for (let i = 0; i < board.length; i++) {
        let currentRow = board[i];
        
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
createGroups();

console.log(groups[0])
