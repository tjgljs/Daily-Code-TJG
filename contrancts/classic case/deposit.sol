// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./WETH.sol";
import "./SafeMath.sol";

contract DepositContract {
    using SafeMath for uint256;

    address payable public immutable _weth; // 替换为自己部署的 WETH 地址
    uint256 public constant rewardBase = 5; // 每5个币经过一个区块，可以领取1个ETH奖励。注意这里的奖励是ETH而不是WETH；
    uint256 public immutable startBlock; // 在构造函数中定义
    uint256 public immutable endBlock; // 在构造函数中定义
    mapping(address => uint256) public depositAmount; // 用户的存款总量
    mapping(address => uint256) public checkPoint; // 每次存款或提取本金时，更新这个值
    mapping(address => uint256) public calculatedReward; // 已经计算的利息 记录之前的利息
    mapping(address => uint256) public claimedReward; // 已经提取的利息

    event Deposit(address indexed sender, uint256 amount);
    event Claim(address indexed sender, address recipient, uint256 amount);
    event Withdraw(address indexed sender, uint256 amount);

    constructor(address payable _wethAddress, uint256 _period) {
        // period 为从当前开始，延续多少个区块
        startBlock = block.number;
        endBlock = block.number + _period + 1;
        _weth = _wethAddress;
    }


    // 修饰符，充值时只允许在设定的区块范围内
    modifier onlyValidTime() {
        require(block.number>startBlock&&block.number<endBlock,"block out");
        _;
    }


    // 存钱到合约
    function deposit(uint256 _amount) public payable onlyValidTime returns (bool) {
        // 此处编写业务逻辑
        if(checkPoint[msg.sender]!=0){
        calculatedReward[msg.sender]+=(block.number- checkPoint[msg.sender]/depositAmount[msg.sender])*depositAmount[msg.sender]/5;
        }
        depositAmount[msg.sender]+=_amount;
        checkPoint[msg.sender]=depositAmount[msg.sender]*block.number;
        
        
        emit Deposit(msg.sender, _amount);
        return true;
    }

    // 查询利息
    function getPendingReward(address _account)
        public
        view
        returns (uint256 pendingReward)
    {
     // 此处编写业务逻辑
     if(depositAmount[_account]==0){
        return 0;
     }
    pendingReward=calculatedReward[_account]+(block.number- checkPoint[_account]/depositAmount[_account])*depositAmount[_account]/5-claimedReward[_account];
     
    }

    // 领取利息
   function claimReward(address payable _toAddress) public payable returns (bool) {
        // 此处编写业务逻辑
        uint pendingReward=getPendingReward(msg.sender);
        claimedReward[_toAddress]+=pendingReward;
        _toAddress.transfer(pendingReward);
        emit Claim(msg.sender, _toAddress, pendingReward);
        return true;
    }

    // 提取一定数量的本金
    function withdraw(uint256 _amount) public returns (bool) {
        // 此处编写业务逻辑
        

        calculatedReward[msg.sender]+=(block.number- checkPoint[msg.sender]/depositAmount[msg.sender])*depositAmount[msg.sender]/5;

        depositAmount[msg.sender]-=_amount;
        checkPoint[msg.sender]=depositAmount[msg.sender]*block.number;

       
        claimedReward[msg.sender]=calculatedReward[msg.sender];
        emit Withdraw(msg.sender, _amount);
        return true;
    }

    // 以下不用改
    // 用于在Remix本地环境中增加区块高度
    uint256 counter;

    function addBlockNumber() public {
        counter++;
    }

    // 获取当前区块高度
    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }
}
