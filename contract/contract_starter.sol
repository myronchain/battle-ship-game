// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.7.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.0.0/contracts/cryptography/ECDSA.sol";

contract Battleship {
    using ECDSA for bytes32;

    /*
    声明状态变量，考虑保持状态:
        - 玩家地址
        - 游戏是否结束
        - 赌注费用
        - 玩家是否已经证明了2赢棋
        - 玩家是否已经证明自己的甲板有2艘船
    */

    // 陆地长宽格数
    uint32 constant BOARD_LEN = 4;
    // 玩家1账户
    address public p1;
    // 玩家2账户
    address public p2;
    // 两个玩家相同的赌注
    uint256 public bit = 0;
    // 游戏状态转移:initial:0 -> start:1 -> result claim:2
    uint8 public state = 0;
    address public winner;

    // 初始化提交的默克尔树根节点;
    bytes32 public merkle_root_p1;
    bytes32 public merkle_root_p2;

    // 存储玩家1被击中的船
    uint256[] leaf_index_check_p1;
    // 存储玩家2被击中的船
    uint256[] leaf_index_check_p2;

    // 指责对手离开
    uint public timeout;
    uint private time_limit = 1 minutes;
    // 被指责玩家账户
    address public timeout_claimed_party;

    /** 在这里声明事件，考虑在指控其他玩家离开时触发事件 **/
    event AccuseTimeout(address indexed defendant, address sender);

    // 存储每个玩家的出价，当两个出价都收到时开始游戏，第一个调用函数的玩家决定出价。如果第二个玩家出价过高，将超额出价退还给第二个玩家。
    function store_bid() public payable {
        assert(p1 == address(0) || p2 == address(0));
        assert(state == 0);

        if (p1 == address(0)) {
            require(msg.value > 0);
            p1 = msg.sender;
            bit = msg.value;
        } else if (p2 == address(0)) {
            require(msg.value >= bit && msg.sender != p1);
            p2 = msg.sender;

            if (msg.value > bit) {
                msg.sender.transfer(msg.value - bit);
            }
        }
    }

    // 清除状态-确保设置游戏不在会话中
    function clear_state() internal {
        //require(state == 0);

        p1 = address(0);
        p2 = address(0);
        bit = 0;
        winner = address(0);

        state = 0;

        merkle_root_p1 = bytes32(0);
        merkle_root_p2 = bytes32(0);

        delete leaf_index_check_p1;
        delete leaf_index_check_p2;

        timeout_claimed_party = address(0);
        timeout = 0;

        // 对于第一个玩家掷硬币而第二个玩家没有反应的情况。第一个玩家可以拿回赌注
        //if(msg.sender == p1 && bit > 0){
        //    msg.sender.transfer(bit);
        //}
    }

    // 存储每个玩家最初的棋盘承诺。注意merkle_root是默克尔树最顶层值的哈希值
    function store_board_commitment(bytes32 merkle_root) public {
        //只有函数"store_bid()"设置字段p1和p2。所以应该在调用本函数之前调用"store_bid()"
        require(msg.sender == p1 || msg.sender == p2);
        require(state == 0);

        if(msg.sender == p1){
            merkle_root_p1 = merkle_root;
        }else if(msg.sender == p2){
            merkle_root_p2 = merkle_root;
        }
        if(merkle_root_p1 != 0 && merkle_root_p2 != 0){
            // 将状态转换为“开始游戏”
            state = 1;
        }
    }

    // 确认一艘船在甲板上的位置
    // opening_nonce - 对应于JS中的web3.utils.fromAscii(JSON.stringify(opening) + JSON.stringify(nonce))
    // proof - 一个sha256哈希列表，你可以从get_proof_for_board_guess获得
    // guess_leaf_index - 猜测船只位置的索引
    // owner -这艘船所在的board的玩家的地址
    function check_one_ship(
        bytes memory opening_nonce,
        bytes32[] memory proof,
        uint256 guess_leaf_index,
        address owner
    ) public returns (bool result) {
        assert((msg.sender == p1 && owner == p2) || (msg.sender == p2 && owner == p1) );

        //check the openning is "true";
        //web3.utils.fromAscii("true") retunrs "0x74727565"
        require(opening_nonce.length >= 4 && uint8(opening_nonce[0]) == 0x74
        && uint8(opening_nonce[1]) == 0x72
        && uint8(opening_nonce[2]) == 0x75
        && uint8(opening_nonce[3]) == 0x65);

        bytes32 com = merkle_root_p1;
        uint256[] storage leaves = leaf_index_check_p1;
        if(owner == p2){
            com = merkle_root_p2;
            leaves = leaf_index_check_p2;
        }

        bool ret = verify_opening(opening_nonce, proof, guess_leaf_index, com);
        if(ret == true){
            for(uint32 i = 0; i < leaves.length; i++){
                if(leaves[i] == guess_leaf_index){
                    // 如果索引在数组中已经存在（已经将船只打破）
                    return false;
                }
            }
            leaves.push(guess_leaf_index);
            return true;
        }
        return false;
    }

    // 宣布你赢了比赛
    // 如果你击中了2个舰艇，然后这个函数会转移赢钱给你和结束游戏。
    function claim_win() public{
        assert(msg.sender == p1 || msg.sender == p2);

        bool isP1Win = true;
        if(msg.sender == p2){
            isP1Win = false;
        }

        if(isP1Win){
            require(leaf_index_check_p2.length>= 2);
            winner = p1;
        }else {
            require(leaf_index_check_p1.length >= 2);
            winner = p2;
        }

        msg.sender.transfer(address(this).balance);//transfer all the tokens from this contract to the winner (i.e., msg sender)
        state = 2;
    }

    // 放弃这个游戏
    // 不管作弊，棋盘状态，或任何其他条件，这个函数调用后所有的资金被发送到对手和游戏结束。
    function forfeit(address payable opponent) public {
        // TODO
        // 发送方调用之前必须存放赌注
        assert(msg.sender == p1 || msg.sender == p2);
        // 将所有资金转移给对手
        opponent.transfer(address(this).balance);
        state = 2;
        winner = opponent;
    }

    // 声称对手作弊 — 如果是真的，你就赢了。
    // opening_nonce - 对应于JS中的web3.utils.fromAscii(JSON.stringify(opening) + JSON.stringify(nonce))
    // proof - 一个sha256哈希列表，你可以从get_proof_for_board_guess(这是发送者认为是一个谎言)
    // guess_leaf_index - 猜测船只位置的索引
    // owner - 这艘船所在的board的所有者的地址
    function accuse_cheating(
        bytes memory opening_nonce,
        bytes32[] memory proof,
        uint256 guess_leaf_index,
        address owner
    ) public returns (bool result) {

        assert((msg.sender == p1 && owner == p2) || (msg.sender == p2 && owner == p1));

        bytes32 com = merkle_root_p1;
        if(owner == p2){
            com = merkle_root_p2;
        }

        if(!verify_opening(opening_nonce, proof, guess_leaf_index, com)){
            msg.sender.transfer(address(this).balance);
            state = 2;
            winner = msg.sender;
            return true;
        }
        return false;
    }

    // 举报花太长时间/离开 触发一个双方玩家都应该监听的事件
    function claim_opponent_left(address opponent) public {
        assert((msg.sender == p1 && opponent == p2) || (msg.sender == p2 && opponent == p1));
        require(state == 1);

        timeout = now;
        timeout_claimed_party = opponent;

        emit AccuseTimeout(opponent, msg.sender);
    }

    // 处理超时指控消息。发件人是被告一方。
    // 如果不超过1分钟，则适当设置状态，防止奖金分配。否则，什么都不做。
    function handle_timeout(address payable opponent) public {
        assert((msg.sender == p1 && opponent == p2) || (msg.sender == p2 && opponent == p1));
        require(timeout_claimed_party == msg.sender);

        if(now <= timeout + time_limit){
            timeout_claimed_party = address(0);
            timeout = 0;
        }
    }

    // 如果玩家被举报超时后没有在指定时间回应，则声称举报方获胜，获得奖金。
    // 如果玩家没有举报超时，则不应该导致游戏结束。
    // 如果计时器还没有用完，什么也不做。
    function claim_timeout_winnings(address opponent) public {
        assert((msg.sender == p1 && opponent == p2) || (msg.sender == p2 && opponent == p1));
        require(opponent == timeout_claimed_party, "should opponent == timeout_claimed_party");

        if(now > timeout + time_limit){
            msg.sender.transfer(address(this).balance);
            state = 2;
            winner = msg.sender;
            timeout_claimed_party = address(0);
        }
    }

    // 检查游戏是否结束
    // Hint使用一个状态变量，所以可以从JS调用它。注意不能在JS中使用改变状态函数的返回值。
    function is_game_over() public view returns (bool) {
        return state != 1;
    }

    /**** Helper Functions below this point. Do not modify. ****/
    /***********************************************************/

    function merge_bytes32(bytes32 a, bytes32 b) pure public returns (bytes memory) {
        bytes memory result = new bytes(64);
        assembly {
            mstore(add(result, 32), a)
            mstore(add(result, 64), b)
        }
        return result;
    }

    // 验证单个单板上的单个点的证明
    // args:
    // - opening_nonce - 对应于web3.utils.fromAscii(JSON.stringify(open) + JSON.stringify(nonce)));
    // - proof - sha256哈希表，对应于 get_proof_for_board_guess()的输出
    // - guess - [i, j] - guess开口对应（guess that opening corresponds to）
    // - commit - board的默克尔根
    // - Verify the proof of a single spot on a single board
    function verify_opening(bytes memory opening_nonce, bytes32[] memory proof, uint guess_leaf_index, bytes32 commit) public pure returns (bool result) {
        bytes32 curr_commit = keccak256(opening_nonce); // see if this changes hash
        uint index_in_leaves = guess_leaf_index;

        uint curr_proof_index = 0;
        uint i = 0;

        while (curr_proof_index < proof.length) {
            // index of which group the guess is in for the current level of Merkle tree
            // (equivalent to index of parent in next level of Merkle tree)
            uint group_in_level_of_merkle = index_in_leaves / (2**i);
            // index in Merkle group in (0, 1)
            uint index_in_group = group_in_level_of_merkle % 2;
            // max node index for currrent Merkle level
            uint max_node_index = ((BOARD_LEN * BOARD_LEN + (2**i) - 1) / (2**i)) - 1;
            // index of sibling of curr_commit
            uint sibling = group_in_level_of_merkle - index_in_group + (index_in_group + 1) % 2;
            i++;
            if (sibling > max_node_index) continue;
            if (index_in_group % 2 == 0) {
                curr_commit = keccak256(merge_bytes32(curr_commit, proof[curr_proof_index]));
                curr_proof_index++;
            } else {
                curr_commit = keccak256(merge_bytes32(proof[curr_proof_index], curr_commit));
                curr_proof_index++;
            }
        }
        return (curr_commit == commit);

    }


    //----------------------------test func-----------------------------

    function clear_state_test() public{ //only for test
        clear_state();
    }

    function getleaf_index_check_p1() public view returns(uint256[] memory){
        return leaf_index_check_p1;
    }

    function getleaf_index_check_p2() public view returns(uint256[] memory){
        return leaf_index_check_p2;
    }

    function getBalance() public view returns (uint256){
        return address(this).balance;
    }

    function withdrawAll() external{
        msg.sender.transfer(address(this).balance);
    }

    constructor () public payable{

    }


    //----------------------------test func - end ----------------------


}
