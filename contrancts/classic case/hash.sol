// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract HashFunc{
    function hash(string memory text,uint num,address addr)external pure returns(bytes32){
        return keccak256(abi.encodePacked(text,num,addr));
    }
    //abi.encode 函数
    function encode(string memory text0,string memory text1)external pure returns(bytes memory){
        return abi.encode(text0,text1);
    }
    //abi.encodePacked函数
    function encodePacked(string memory text0,string memory text1)external pure returns(bytes memory){
        return abi.encodePacked(text0,text1);
    }
    //对比：abi.encode的返回值会自动补零，可以将两个参数分开，
    //而abi.encodePacked的返回值不会补零，因此返回值是黏在一起的，会有hash碰撞的可能。
    //为了避免hash碰撞，可以将传入hash的两个值用数字进行隔开
    function collision(string memory text0,uint num,string memory text1)external pure returns(bytes32){
        return keccak256(abi.encodePacked(text0,num,text1));
    }
    }
