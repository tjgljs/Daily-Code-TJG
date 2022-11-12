pragma solidity 0.5.2;
contract zhongchou{
    struct funder{
        address  funderaddress;
        uint tomoney;
    }
    struct needer{
        address payable neederaddress;
        uint goal;
        uint amount;
        uint  funderaccount;
        mapping(uint=>funder)map;
    }
    uint public neederaccount;
    mapping(uint=>needer)needmap;

    function newneeder(address payable _neederaddress ,uint _goal)public {
        neederaccount++;
        needmap[neederaccount]=needer(_neederaddress ,_goal,0,0);

    }

    function contribute(address _address,uint _neederaccount)public payable{
        needer storage _needer=needmap[_neederaccount];
        _needer.amount+=msg.value;
        _needer.funderaccount++;
        _needer.map[_needer.funderaccount]=funder(_address,msg.value);

    }
    

    function iscompelete(uint _neederaccount)public payable {
        needer storage _needer=needmap[_neederaccount];
        if (_needer.amount>=_needer.goal){
            _needer.neederaddress.transfer(_needer.amount);
        }
    }
    function getbalance(uint _neederaccount)public view returns(address,uint,uint,uint){
         /*address payable neederaddress;
        uint goal;
        uint amount;
        uint funderaccount;*/
        needer storage _needer=needmap[_neederaccount];
        return (_needer.neederaddress,_needer.goal,_needer.amount,_needer.funderaccount);


    }
    function test()public view returns(uint,uint,uint){
        return (needmap[1].goal,needmap[1].amount,needmap[1].funderaccount);
    }
}
