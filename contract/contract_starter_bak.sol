pragma solidity >=0.4.22 <0.7.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.0.0/contracts/cryptography/ECDSA.sol";

contract Battleship {
    using ECDSA for bytes32;
    uint32 constant BOARD_LEN = 4;

    address public p1;//the first player
    address public p2;//the second player
    uint256 public bit = 0;//two player make the same bit.
    uint8 public state = 0;//game state transfer: inital:0 -> start:1 -> result claim:2
    address public winner;

    //the initail committed merkle_root;
    bytes32 public merkle_root_p1;
    bytes32 public merkle_root_p2;
    
    //store the leaf index of p1 where there is a ship hit by the p2
    uint256[] leaf_index_check_p1;
    //store the leaf index of p2 where there is a ship hit by the p1
    uint256[] leaf_index_check_p2;

    // Accuse opponent of leaving
    uint public timeout; 
    uint private time_limit = 1 minutes;
    address public timeout_claimed_party;


    event AccuseTimeout(address indexed defendant, address sender);
    
    // Declare state variables here.
    // Consider keeping state for:
    // - player addresses
    // - whether the game is over
    // - board commitments
    // - whether a player has proven 2 winning moves
    // - whether a player has proven their own board had 2 ships

    // Declare events here.
    // Consider triggering an event upon accusing another player of having left.

    // Store the bids of each player
    // Start the game when both bids are received
    // The first player to call the function determines the bid amount.
    // Refund excess bids to the second player if they bid too much.
    function store_bid() public payable{
        assert(p1 == address(0) || p2 == address(0));
        assert(state == 0);
        
        if(p1 == address(0)){
            require(msg.value > 0);
            p1 = msg.sender;
            bit = msg.value;
        }else if(p2 == address(0)){
            require(msg.value >= bit && msg.sender != p1);
            p2 = msg.sender;
            
            if(msg.value > bit){
                msg.sender.transfer(msg.value - bit);
            }
        }
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

    function withdrawAll()external{
        msg.sender.transfer(address(this).balance);
    }

    constructor () public payable{
       
    }


    //----------------------------test func - end ----------------------
    

    // Clear state - make sure to set that the game is not in session
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
        
        //For the case that the first player bits some coin but the second does not respond.
        //The first player can get back the bit.
        //if(msg.sender == p1 && bit > 0){
        //    msg.sender.transfer(bit);
        //}
    }

    // Store the initial board commitments of each player
    // Note that merkle_root is the hash of the topmost value of the merkle tree
    function store_board_commitment(bytes32 merkle_root) public {
        //only the function "store_bid()" sets the field p1 and p2;
        //so it should call the func "store_bid()" before this func.
        require(msg.sender == p1 || msg.sender == p2);
        require(state == 0);
        
        if(msg.sender == p1){
            merkle_root_p1 = merkle_root;
        }else if(msg.sender == p2){
            merkle_root_p2 = merkle_root;
        }
        if(merkle_root_p1 != 0 && merkle_root_p2 != 0){
            state = 1; //transfer the state to "start the game"
        }
    }


    // Verify the placement of one ship on a board
    // opening_nonce - corresponds to web3.utils.fromAscii(JSON.stringify(opening) + JSON.stringify(nonce)) in JS
    // proof - a list of sha256 hashes you can get from get_proof_for_board_guess
    // guess_leaf_index - the index of the guess as a leaf in the merkle tree
    // owner - the address of the owner of the board on which this ship lives
    
    function check_one_ship(bytes memory opening_nonce, bytes32[] memory proof,
        uint256 guess_leaf_index, address owner) public returns (bool result) {
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
                if(leaves[i] == guess_leaf_index){//if the index already exists in the array
                    return false;
                }
            }
            leaves.push(guess_leaf_index);
            return true;
        }
        return false;
    }

    // Claim you won the game
    // If you have checked 2 winning moves (hits) AND you have checked
    // 2 of your own ship placements with the contract, then this function
    // should transfer winning funds to you and end the game.
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

    // Forfeit the game
    // Regardless of cheating, board state, or any other conditions, this function
    // results in all funds being sent to the opponent and the game being over.
    function forfeit(address payable opponent) public {
        // TODO
        assert(msg.sender == p1 || msg.sender == p2);//The sender must put the bit before.
        opponent.transfer(address(this).balance);//transfer all funds to the opponent.
        state = 2;
        winner = opponent;
    }

    // Claim the opponent cheated - if true, you win.
    // opening_nonce - corresponds to web3.utils.fromAscii(JSON.stringify(opening) + JSON.stringify(nonce)) in JS
    // proof - a list of sha256 hashes you can get from get_proof_for_board_guess (this is what the sender believes to be a lie)
    // guess_leaf_index - the index of the guess as a leaf in the merkle tree
    // owner - the address of the owner of the board on which this ship lives
    function accuse_cheating(bytes memory opening_nonce, bytes32[] memory proof,
        uint256 guess_leaf_index, address owner) public returns (bool result) {
        
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

    // Claim the opponent of taking too long/leaving
    // Trigger an event that both players should listen for.
    function claim_opponent_left(address opponent) public {
        assert((msg.sender == p1 && opponent == p2) || (msg.sender == p2 && opponent == p1));
        require(state == 1);
        
        timeout = now;
        timeout_claimed_party = opponent;
        
        emit AccuseTimeout(opponent, msg.sender);
    }

    // Handle a timeout accusation - msg.sender is the accused party.
    // If less than 1 minute has passed, then set state appropriately to prevent distribution of winnings.
    // Otherwise, do nothing.
    function handle_timeout(address payable opponent) public {
        assert((msg.sender == p1 && opponent == p2) || (msg.sender == p2 && opponent == p1));
        require(timeout_claimed_party == msg.sender);
        
        if(now <= timeout + time_limit){
            timeout_claimed_party = address(0);
            timeout = 0;
        }
    }

    // Claim winnings if opponent took too long/stopped responding after claim_opponent_left
    // The player MUST claim winnings. The opponent failing to handle the timeout on their end should not
    // result in the game being over. If the timer has not run out, do nothing.
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

    // Check if game is over
    // Hint - use a state variable for this, so you can call it from JS.
    // Note - you cannot use the return values of functions that change state in JS.
    function is_game_over() public returns (bool) {
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

    // Verify the proof of a single spot on a single board
    // \args:
    //      opening_nonce - corresponds to web3.utils.fromAscii(JSON.stringify(opening) + JSON.stringify(nonce)));
    //      proof - list of sha256 hashes that correspond to output from get_proof_for_board_guess()
    //      guess - [i, j] - guess that opening corresponds to
    //      commit - merkle root of the board
    function verify_opening(bytes memory opening_nonce, bytes32[] memory proof, uint guess_leaf_index, bytes32 commit) public view returns (bool result) {
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
}
