// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract Kill{
    constructor()payable{
    }
    function kill()external{
    selfdestruct(payable(msg.sender));
}
}
//自毁方法 kill 会将该合约所有主币发送给一个地址

contract Helper{
    function getbalance()external view returns(uint){
        return address(this).balance;
    }
    function testkill(Kill _kill)external{
        _kill.kill();
    } 
}
