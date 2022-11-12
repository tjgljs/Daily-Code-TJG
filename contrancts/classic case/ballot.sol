// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;



contract Ballot {
   	//投票人的结构体
    struct Voter {
        uint weight; 
        bool voted;  
        address delegate; 
        uint vote;   
    }
	
	//被选举人的结构体
    struct Proposal {
        
       
        bytes32 name;   
        uint voteCount; 
    }

    address public chairperson;		

    mapping(address => Voter) public voters;		

    Proposal[] public proposals;	

    
     //["0x2022542500000000000000000000000000000000000000000000000000000000","0x2022543500000000000000000000000000000000000000000000000000000000"]
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;		//将第一个部署合约的人设置为主持人
        voters[chairperson].weight = 1;		//其权重为1
		
		//将所有待选的被选举人存储到被选举人数组中
         for (uint i = 0; i < proposalNames.length; i++) {
           
            proposals.push(Proposal({
                name:proposalNames[i],
                voteCount: 0
            }));
         }
    }
      /// bytes32类型转化为string型转
    /*function bytes32ToString(bytes32 x)  pure internal returns(string memory){
        bytes memory bytesString = new bytes(32);
        uint charCount = 0 ;
        for(uint j = 0 ; j<32;j++){
            byte char = byte(bytes32(uint(x) *2 **(8*j)));
            if(char !=0){
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for(uint j=0;j<charCount;j++){
            bytesStringTrimmed[j]=bytesString[j];
        }
        return string(bytesStringTrimmed);
    }*/

    function giveRightToVote(address voter)public{
        require(msg.sender==chairperson,"only chairperson can give right to vote");
        require(voters[voter].voted!=true,"the voter already voted");
        require(voters[voter].weight==0);
        voters[voter].weight=1;
    }

    function delegate(address to)public {
        Voter storage sender=voters[msg.sender];
        require(sender.voted!=true,"sender can not vote");
        require(msg.sender!=to,"delegater can not youselfe");
        while(voters[to].delegate!=address(0)){
            to=voters[to].delegate;
            require(to!=msg.sender,"found loop in delegateion");
        }
        sender.voted=true;
        sender.delegate=to;
        Voter storage _delegate=voters[to];
        if(!_delegate.voted){
            proposals[_delegate.vote].voteCount+=sender.weight;
        }else{
            _delegate.weight+=sender.weight;
        }
    }
    function vote(uint proposal)public{
        Voter  storage sender=voters[msg.sender];
        require(sender.weight!=0,"you have right to vote");
        require(!sender.voted,"you already voted");
        sender.voted=true;
        sender.vote=proposal;
        proposals[proposal].voteCount+=sender.weight;
    }
    function winningProposal()public view returns(uint winningProposal_){
        uint winningVoteCount=0;
        for(uint i=0;i<proposals.length;i++){
            winningVoteCount>proposals[i].voteCount;
            winningProposal_=i;

        }
        return winningProposal_;
    }
    function winnerName()public view returns(bytes32  winnerName_){
        uint p=winningProposal();
       return winnerName_=proposals[p].name;
    }

}
