// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.17;
interface IERC721Receiver {
   
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
interface IERC721Metadata {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
interface IERC721{
    event Transfer(address indexed from,address indexed to,uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner,address indexed operater,bool approved);
    event Approval(address indexed owner,address indexed approved,uint256 indexed tokenId);


    function balanceOf(address owner )external view returns(uint256 balance);
    function ownerOf(uint256 tokenId)external view returns(address owner);

    function approve(address to,uint256 tokenId)external;
    function setApprovalForAll(address operater,bool _approved)external;
    function getApproved(uint256 tokenId)external view returns(address operater);
    function isApprovedForAll(address owner,address operater)external view returns(bool);
    function transferfrom(address from,address to,uint256 tokenId)external;
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data)external;
    function safeTransferFrom(address from,address to,uint256 tokenId)external;
    function mint(address to ,uint256 tokenId)external;
    function safermint(address to ,uint256 tokenId,bytes memory data)external;
    function safermint(address to ,uint256 tokenId)external;
    function burn(uint256 tokenId)external;
     }
interface IERC165{
    function supportsInterface(bytes4 interfaceId)external view returns(bool);

    }     

contract ERC721 is IERC721,IERC721Metadata,IERC165{
    mapping(address=>uint256)_balance;
    mapping(uint256=>address)_owners;
    mapping(uint256=>address)_tokenApprovals;
    mapping(address=>mapping(address=>bool))_operaterApprovals;
    string _name;
    string _symbol;
    mapping(uint256=>string)_tokenURIs;

    constructor(string memory name_,string memory symbol_){
        _name=name_;
        _symbol=symbol_;
    }

    function name() public view  returns (string memory) {
        return _name;
    }

    
    function symbol() public view  returns (string memory) {
        return _symbol;
    }

   
    function tokenURI(uint256 tokenId) public view  returns (string memory) {
        address owner=_owners[tokenId];
        require(owner!=address(0),"error:token id is not valid");
        return _tokenURIs[tokenId];
    }
    function setTokenURI(uint256 tokenId,string memory URI) public  {
        address owner=_owners[tokenId];
        require(owner!=address(0),"error:token id is not valid");
        _tokenURIs[tokenId]=URI;
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
            
    }


    function balanceOf(address owner )public view returns(uint ){
        require(owner!=address(0),"error:address is address(0)");
        return _balance[owner];
    }
     function ownerOf(uint256 tokenId)public view returns(address ){
         address owner=_owners[tokenId];
         require(owner!=address(0),"error:tokenid is not valid id");
         return owner;
     }
      function approve(address to,uint256 tokenId)public{
          address owner=_owners[tokenId];
          require(owner!=to,"owner==to");
          require(owner==msg.sender || isApprovedForAll(owner,msg.sender),"error:caller is no token owner//for all");
          _tokenApprovals[tokenId]=to;
          emit Approval(owner,to,tokenId);
     }
     function getApproved(uint256 tokenId)public view returns(address){
         address owner=_owners[tokenId];
         require(owner!=address(0),"error:token is not minter or is burn");
         return _tokenApprovals[tokenId];
     }
     function setApprovalForAll(address operater,bool _approved)public{
         require(msg.sender!=operater,"error:owner==operater");
         _operaterApprovals[msg.sender][operater]=_approved;
         emit ApprovalForAll(msg.sender,operater,_approved);

     }
     function isApprovedForAll(address owner,address operater)public view returns(bool){
         return _operaterApprovals[owner][operater];
     }
      function transferfrom(address from,address to,uint256 tokenId)public{
          address owner=_owners[tokenId];
          require(owner==from,"error:owner is not from address");
          require(owner==msg.sender||isApprovedForAll(owner,from)||getApproved(tokenId)==msg.sender,"error:caller can not use it");
          delete _tokenApprovals[tokenId];
          _balance[from]-=1;
          _balance[to]+=1;
          _owners[tokenId]=to;
          emit Transfer(from,to,tokenId);
      }

      function safeTransferFrom(address from,address to,uint256 tokenId,bytes memory data)public{
          transferfrom(from,to,tokenId);
          require(_checkOnERC721Received(from,to,tokenId,data),"error:erc721receiver is not implmeneter");
      }
      function safeTransferFrom(address from,address to,uint256 tokenId)public{
          safeTransferFrom(from,to,tokenId,"");
      }

    function mint(address to ,uint256 tokenId)public{
        require(to!=address(0),"error:to is address 0");
        address owner=_owners[tokenId];
        require(owner==address(0),"error:tokenid is exited");
        _balance[to]+=1;
        _owners[tokenId]=to;
        emit Transfer(address(0),to,tokenId);
    }
    function safermint(address to ,uint256 tokenId,bytes memory data)public{
        mint(to,tokenId);
        require(_checkOnERC721Received(address(0),to,tokenId,data),"error:erc721receiver is not implmeneter");
    }
    function safermint(address to ,uint256 tokenId)public{
        safermint(to,tokenId,"");
    }
    function burn(uint256 tokenId)public{
        address owner=_owners[tokenId];
        require(msg.sender==_owners[tokenId],"error:only owner can burn");
        _balance[owner]-=1;
        delete _owners[tokenId];
        delete _tokenApprovals[tokenId];
        emit Transfer(owner,address(0),tokenId);


    }
      function _checkOnERC721Received( address from,address to,uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length>0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

}
