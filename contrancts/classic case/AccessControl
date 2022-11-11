// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract AccessControl{
    event GrantRole(bytes32 indexed role,address indexed account);
    event RevokeRole(bytes32 indexed role,address indexed account);

    mapping(bytes32=>mapping(address=>bool))public roles;

    bytes32 public constant ADMIT=keccak256(abi.encodePacked("ADMIT"));
    bytes32 public constant USER=keccak256(abi.encodePacked("USER"));
    
    modifier onlyRole(bytes32 _role){
        require(roles[_role][msg.sender],"not authorized");
        _;
    }
    //构造函数 
    constructor(){
        _grantRole(ADMIT,msg.sender);
    }
    //内置函数，仅内部可见
    function _grantRole(bytes32 _role,address _account)internal{
        roles[_role][_account]=true;
        emit GrantRole(_role,_account);
    }
    //赋予权力
    function grantRole(bytes32 _role,address _account)external onlyRole(ADMIT){
        _grantRole(_role,_account);
    }
    //撤销权力
    function revokeRole(bytes32 _role,address _account)external onlyRole(ADMIT){
        roles[_role][_account]=false;
        emit RevokeRole(_role,_account);
    }

}
