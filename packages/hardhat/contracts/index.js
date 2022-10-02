// this script used to check if the number is even or odd

var board  =[]

var rectangle1 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(279.884074 202.028018)" paint-order="fill markers stroke" fill="none" stroke="#000" stroke-linejoin="bevel"/>'
var rectangle2 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(291.384074 202.028018)" paint-order="fill markers stroke" fill="none" stroke="#000" stroke-linejoin="bevel"/>'
var rectangle3 = '<rect width="10" height="8.268303" rx="0" ry="0" transform="translate(302.884074 202.028018)" paint-order="fill markers stroke" fill="none" stroke="#000" stroke-linejoin="bevel"/>'
var longRect = '<rect width="33" height="8.268303" rx="0" ry="0" transform="translate(279.884074 211.476621)" fill="none" stroke="#000" stroke-linejoin="bevel"/>'

var group = rectangle1+rectangle2+longRect+ rectangle3



for (let i = 0; i<18; i++) {
    board.push(1);
}

// display the result

console.log(group);