pragma circom 2.0.0;

function uint8(data) {
    return data & 0xFF;
}

function uint80(data) {
    return data & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
}

function uint256(data) {
    return data & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
}

function readUint8(data, index) {
    return uint8(data[index]);
}

function readUint16(data, index) {
    return readUint8(data, index) + readUint8(data, index + 1) >> 8;
}

function readBytes(data, index, length) {
    // TODO
}

function packNode(length, start, end) {
    var node = length;
    node |= start << 80;
    node |= end << 80;
    return node;
}

function getLength(node) {
    return uint80(node);
}

function getStart(node) {
    return uint80(node >> 80);
}

function getEnd(node) {
    return uin80(node >> 160);
}

template ReadNodeLength(maxLength) {
    signal input derBytes[maxLength];
    signal input index;

    signal output node;

    var length;
    var start;
    var end;

    if (derBytes[index] & 0x80 == 0) {
        length = uint8(derBytes[index + 1]);
        start = uint80(index + 2);
        end = uint80(start + length - 1);
    } else {
        var lengthOfLengthSection = uint8(derBytes[index + 1] & 0x7f)
        if (lengthOfLengthSection == 1) {
            length = readUint8(derBytes, index + 2);
        } else if (lengthOfLengthSection == 2) {
            length = readUint16(derBytes, index + 2);
        } else {
            length = uint256(readBytes(derBytes, index + 2, lengthOfLengthSection) >> (32 - lengthOfLengthSection) * 8);
        }
        start = uint80(index + 2 + lengthOfLengthSection);
        end = uint80(start + length - 1);
    }
    
    node <== packNode(length, start, end);
}

template Root(maxLength) {
    signal input derBytes[maxLength];
    signal output outputNode[maxLength];

    component readNodeLength = ReadNodeLength(maxLength);

    for (i = 0; i < maxLength; i++) {
        readNodeLength.derBytes[i] <== derBytes[i];
    }

    readNodeLength.index <== 0;

    outputNode <== readNodeLength.node;
}

template FirstChildOf(maxLength) {

    signal input derBytes[maxLength];
    signal input node;

    signal output outputNode;

    // Require node to point to a constructed type
    assert(derBytes[getLength(node)] & 0x20 == 0x20);

    component readNodeLength = ReadNodeLength(maxLength);

    for (i = 0; i < maxLength; i++) {
        readNodeLength.derBytes[i] <== derBytes[i];
    }

    readNodeLength.index <== getStart(node);

    outputNode <== readNodeLength.node;
}

template NextSiblingOf(maxLength) {
    signal input derBytes[maxLength];
    signal input node;

    signal output outputNode;

    component readNodeLength = ReadNodeLength(maxLength);

    for (i = 0; i < maxLength; i++) {
        readNodeLength.derBytes[i] <== derBytes[i];
    }

    readNodeLength.index <== getEnd(node);

    outputNode <== readNodeLength.node;
}

template GetBytesOf(maxLength) {
    signal input derBytes[maxLength];
    signal input node;

    signal output outputBytes[maxLength];

    var out = readBytes(derBytes, getStart(node), getEnd(node));

    for (i = 0; i < maxLength; i ++) {
        outputBytes[i] 
    }
}

template X509Verify(maxLength) {

}