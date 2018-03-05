pragma solidity ^0.4.19;

// 20180302 - ERC20 NOT WORKING
// https://github.com/ethereum/EIPs/issues/20
// deployed addrss: 0x448822270578bbc4c5dcc6c0e11b6eb6f7c370d4
// 20180305 - Still not working. Removed new in front of ERC20(), added public
contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address _owner) public constant returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Lottery {
    address public manager;
    address[] public players;
    address public lastWinner;
    uint public lastWinAmount;
    address public _actuaryTokenAddress;
    ERC20 public token;
    uint public managerTokenCount;

    function Lottery() public {
        manager = msg.sender;
        _actuaryTokenAddress = 0x59e9a24D86A03A5d966e0c24d2ec304726fCb4e4;
        token = ERC20(_actuaryTokenAddress);
        managerTokenCount = token.balanceOf(manager);
    }


    function enter(uint amount) public payable {
        // require(msg.value > .01 ether);
        require(token.balanceOf(msg.sender) >= amount);
        // require(token.approve(this, amount));
        token.transferFrom(msg.sender, this, amount);

        players.push(msg.sender);
    }

    function random() private view returns (uint) {
        return uint(keccak256(block.difficulty, now, players));
    }
    
    function checkManagerERC20Tokens() public view returns (uint) {
        return uint(token.balanceOf(manager));
    }

    function pickWinner() public restricted {
        uint index = random() % players.length;
        lastWinner = players[index];
        // lastWinAmount = this.balance;
        lastWinAmount = token.balanceOf(this);
        // players[index].transfer(this.balance);
        // require(token.approve(lastWinner, lastWinAmount));
        token.transferFrom(this, lastWinner, lastWinAmount);        
        players = new address[](0);
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function getPlayers() public view returns (address[]) {
        return players;
    }
}