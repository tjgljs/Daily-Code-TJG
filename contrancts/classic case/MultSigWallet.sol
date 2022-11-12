// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.17;
//多人签名
//需要当同意的人数到达一定数量该提议才能成功
contract MultSigWallet{
    
    event Deposit(address indexed sender,uint amount);
    event Submit(uint indexed txid);
    event Approve(address indexed owner,uint indexed txid);
    event Revoke(address indexed owner,uint indexed txid);
    event Execte(uint indexed txid);
//交易提议的结构体
    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool executed;
    }
    
    address[]public owners;//有赞成权人的数组
    mapping(address=>bool)public isowner;//由地址到是否有赞成权的人的影视
    uint public required;//需要多少票 提议才能通过
    Transaction[]public transactions; //交易提议结构体类型的数组
    mapping(uint=>mapping(address=>bool))public approved;//由txid =》address=》bool 的映射，true则赞成 反之 不赞成
//判断是否是有资格投票的人
    modifier onlyowner(){
        require(isowner[msg.sender],"not owner");
        _;
    }
    //判断是否该交易提议存在
    modifier txExists(uint _txid){
        require(_txid<transactions.length,"tx doesnot exit");
        _;
    }
    //判断投票者是否已经赞成 赞成则无法再进行投票
    modifier notApproved(uint _txid){
        require(!approved[_txid][msg.sender],"tx already approved");
        _;
    }
    //判断该提议是否通过
    modifier notExecuted(uint _txid){
        require(!transactions[_txid].executed,"tx already executed");
        _;
    }

//["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
    constructor(address[]memory _owners,uint _required){
        require(_owners.length>0,"owners required");
        require(_required>0&&_required<=_owners.length,"invalid required number of owners");
        //遍历人是否是owner
        for(uint i;i<_owners.length;i++){
            address owner=_owners[i];
            require(owner!=address(0),"this address is address(0)");
            require(!isowner[owner],"owner is not unique");
            isowner[owner]=true;
            owners.push(owner);
        }
        required=_required;
    }

    receive()payable external{
        emit Deposit(msg.sender,msg.value);
    }
//交易提议
    function submit(address _to,uint _value,bytes calldata _data)external onlyowner{
        transactions.push(Transaction({
            to:_to,
            value:_value,
            data:_data,
            executed:false

        }));
        emit Submit(transactions.length-1);
    }
//赞成是否
    function approve(uint _txid)external onlyowner txExists(_txid) notApproved(_txid) notExecuted(_txid){
        approved[_txid][msg.sender]=true;
        emit Approve(msg.sender,_txid);
    }
//统计通过票数
    function _getApprovalCount(uint _txid)private view returns(uint count){
        for(uint i;i<owners.length;i++){
            if(approved[_txid][owners[i]]){
                count+=1;
            }
        }
    }
    //交易通过
    function execute(uint _txid)external txExists(_txid) notExecuted(_txid){
        require(_getApprovalCount(_txid)>=required,"approvals<required");
        Transaction storage transaction=transactions[_txid];
        transaction.executed=true;
        (bool success,)=transaction.to.call{value:transaction.value}(transaction.data);
        require(success,"tx failed");
        emit Execte(_txid);
    }
    //撤销自己的赞成
    function revoke(uint _txid)external onlyowner txExists(_txid) notExecuted(_txid){
        require(approved[_txid][msg.sender],"tx not approved");
        approved[_txid][msg.sender]=false;
        emit Revoke(msg.sender,_txid);
    }
}
