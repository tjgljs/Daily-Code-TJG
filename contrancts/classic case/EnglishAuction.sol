// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.17;
interface IERC721{
  function transferfrom(address from,address to,uint256 tokenId)external;
}
contract EnglishAuction{
    event Start();
    event Bid(address indexed sender,uint amount);
    event Withdraw(address indexed bidder,uint amount);
    event End(address highestBidder,uint highestBid);
    IERC721 public nft;
    uint public nftid;
    address payable public   seller;
    uint32 public endAt;
    bool public started;
    bool public ended;

    address public highestBidder;
    uint public highestBid;
    mapping(address=>uint)public bids;


constructor(address _nft,uint _nftid,uint _startingBid){
    nft=IERC721(_nft);
    nftid=_nftid;
    highestBid=_startingBid;
    seller=payable( msg.sender);
}
function start()external{
    require(!started,"started");
    require(msg.sender==seller,"not seller");
    started=true;
    endAt=uint32(block.timestamp+300);
    nft.transferfrom(seller,address(this),nftid);
    emit Start();

}

function bid()external payable{
    require(started,"not started");
    require(block.timestamp<endAt,"ended");
    require(msg.value>highestBid,"value<hightest bid");
    if(highestBidder!=address(0)){
        bids[highestBidder]=highestBid+bids[highestBidder];
    }
    highestBid=msg.value;
    highestBidder=msg.sender;
    emit Bid(msg.sender,msg.value);
}

function withdraw()external{
    uint bal=bids[msg.sender];
    bids[msg.sender]=0;
    payable(msg.sender).transfer(bal);
    emit Withdraw(msg.sender,bal);
}

function end()external{
      require(started,"not started");
      require(!ended,"ended");
      require(block.timestamp>=endAt,"not ended");
      ended=true;

      if(highestBidder!=address(0)){
          nft.transferfrom(address(this),highestBidder,nftid);
         seller.transfer(highestBid);
      }else{
          nft.transferfrom(address(this),seller,nftid);
      }
      emit End(highestBidder,highestBid);
   
}
}
