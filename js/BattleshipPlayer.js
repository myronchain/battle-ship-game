// BattleshipPlayer.js
//    Defines a Battleship player and the functions that the player calls to
//    interact with the solidity contract
// =============================================================================
//                                EDIT THIS FILE
// =============================================================================
//      written by: [your name]
// #############################################################################
// This is the address of the contract you want to connect to; copy this from Remix
// TODO: fill this in with your contract's address/hash
let contractAddress = "0x74eC8efA3097F45177CB9a503Ed5B96de8099519";

// sets up web3.js
// let web3 = new Web3(Web3.givenProvider || "ws://82.156.1.187:8545");
let web3 = new Web3("ws://82.156.1.187:8545");

// This is the ABI for your contract (get it from Remix, in the 'Compile' tab)
// ============================================================
var abi = [
	{
		"inputs": [],
		"stateMutability": "payable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "defendant",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			}
		],
		"name": "AccuseTimeout",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "bytes",
				"name": "opening_nonce",
				"type": "bytes"
			},
			{
				"internalType": "bytes32[]",
				"name": "proof",
				"type": "bytes32[]"
			},
			{
				"internalType": "uint256",
				"name": "guess_leaf_index",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "accuse_cheating",
		"outputs": [
			{
				"internalType": "bool",
				"name": "result",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "bit",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes",
				"name": "opening_nonce",
				"type": "bytes"
			},
			{
				"internalType": "bytes32[]",
				"name": "proof",
				"type": "bytes32[]"
			},
			{
				"internalType": "uint256",
				"name": "guess_leaf_index",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "check_one_ship",
		"outputs": [
			{
				"internalType": "bool",
				"name": "result",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "opponent",
				"type": "address"
			}
		],
		"name": "claim_opponent_left",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "opponent",
				"type": "address"
			}
		],
		"name": "claim_timeout_winnings",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "claim_win",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "clear_state_test",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address payable",
				"name": "opponent",
				"type": "address"
			}
		],
		"name": "forfeit",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getBalance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getleaf_index_check_p1",
		"outputs": [
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getleaf_index_check_p2",
		"outputs": [
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address payable",
				"name": "opponent",
				"type": "address"
			}
		],
		"name": "handle_timeout",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "is_game_over",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "a",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "b",
				"type": "bytes32"
			}
		],
		"name": "merge_bytes32",
		"outputs": [
			{
				"internalType": "bytes",
				"name": "",
				"type": "bytes"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "merkle_root_p1",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "merkle_root_p2",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "p1",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "p2",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "state",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "store_bid",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "merkle_root",
				"type": "bytes32"
			}
		],
		"name": "store_board_commitment",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "timeout",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "timeout_claimed_party",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes",
				"name": "opening_nonce",
				"type": "bytes"
			},
			{
				"internalType": "bytes32[]",
				"name": "proof",
				"type": "bytes32[]"
			},
			{
				"internalType": "uint256",
				"name": "guess_leaf_index",
				"type": "uint256"
			},
			{
				"internalType": "bytes32",
				"name": "commit",
				"type": "bytes32"
			}
		],
		"name": "verify_opening",
		"outputs": [
			{
				"internalType": "bool",
				"name": "result",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "winner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "withdrawAll",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]; // TODO: replace this with your contract's ABI
// ============================================================
abiDecoder.addABI(abi);

// Reads in the ABI
var Battleship = new web3.eth.Contract(abi, contractAddress);

class BattleshipPlayer {
  /* constructor
    \brief
      constructor for both battleship players is called after the "start game" button is pressed
      both players are initialized with the following parameters
    \params:
      name          - string - either 'player1' or 'player2', for jquery only for the most part
      my_addr       - string - this player's address in hex
      opponent_addr - string - this player's opponent's address in hex for this game of battleship
      ante          - int    - amount of ether being wagered
  */
  constructor(name, my_addr, opponent_addr, ante) {
    this.my_name = name;
    this.my_addr = my_addr;
    this.opp_addr = opponent_addr;
    this.guesses = Array(BOARD_LEN).fill(Array(BOARD_LEN).fill(false));
    this.my_board = null;
    // ##############################################################################
    //    TODO initialize a battleship game on receiving solidity contract
		//		- Save anything you'd like to track locally
		//	  - Ideas: hits, opponent's last guess/response, whether timer is running, etc.
		//		- Register an event handler for any events you emit in solidity.
		//			(see the spec for an example of how to do this)
    // ##############################################################################
		// Your code here

    //0: initial state; 1: hit the opponent ship; 2: miss
    this.opponent_board = new Array();                  
      for(var x=0; x < BOARD_LEN; x++){
        this.opponent_board[x]=new Array();        
        for(var y=0; y < BOARD_LEN; y++){
          this.opponent_board[x][y] = 0; //initialize with 0    
        }
      }


	//register a event listener that listens to events from the smart contract.
	//only when the defendant is me, then call "alert" function.
	Battleship.events.AccuseTimeout({filter: {defendant: this.my_addr}}, function (err, event) {
		console.log("AccuseTimeout");
		console.log(err);
		console.log(event);
		if (err) {
			return error(err);
		}
		alert(event.returnValues.defendant + " is accused. You get 1 min to response it.");
	});
  }
	async clear_state() {
		console.log("clear_state_test");
		console.log(this.my_addr);
		Battleship.methods.clear_state_test().send({from: this.my_addr, gas: 3141592});
	}

	async place_bet(ante) {
		// ##############################################################################
		//    TODO make a call to the contract to store the bid
		//	  Hint: When you send value with a contract transaction, it must be in WEI.
		//					wei = eth*10**18
		// ##############################################################################
		// Your code here
		let ante_wei = ante * 10 ** 18;
		console.log("place_bet");
		console.log(ante_wei);
		Battleship.methods.store_bid().send({from: this.my_addr, value: ante_wei, gas: 3141592});

		//console.log("Not implemented");
	}

  /* initialize_board
    \brief
      sets class varible my_board and creates a commitment to the board, which is returned
      and sent to the opponent
    \params:
      initialize_board - [[bool]] - array of arrays where true represents a ship's presense
      callback - callback to call with commitment as argument
  */
  async initialize_board(initial_board) {
    this.my_board = initial_board;

		// Store the positions of your two ships locally, so you can prove it if you win
    this.my_ships = [];
		for (var i = 0; i < BOARD_LEN; i++) {
			for (var j = 0; j < BOARD_LEN; j++) {
				if (this.my_board[i][j]) {
					this.my_ships.push([i,j]);
				}
			}
		}

    // set nonces to build our commitment with
	  this.nonces = get_nonces(); // get_nonces defined in util.js
	  // build commitment to our board
	  const commit = build_board_commitment(this.my_board, this.nonces); // build_board_commitment defined in util.js
	  // sign this commitment
	  const sig = sign_msg(commit, this.my_addr);

	  // ##############################################################################
	  //    TODO store the board commitment in the contract
	  // ##############################################################################
	  // Your code here
	  console.log("store_board_commitment");
	  console.log(commit);
	  Battleship.methods.store_board_commitment(commit).send({from: this.my_addr, gas: 3141592});
	  return [commit, sig];
  }

  /* receive_initial_board_commit
    \brief
      called with the returned commitment from initialize_board() as argument
    \params:
      commitment - a commitment to an initial board state received from opponent
      signature - opponeng signature on commitment
  */
  receive_initial_board_commit(commitment, signature) {
    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //    DONE this function has been completed for you.
    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if (!check_signature(commitment, signature, this.opp_addr)) {
      throw "received an invalid signature from opponent as initial board commit";
    }
    this.opponent_commit = commitment;
    this.opponent_commit_sig = signature;
  }

  /* build_guess
    \brief:
      build a guess to be sent to the opponent
    \params
      i - int - the row of the guessed board square
      j - int - the column of the guessed board square
    \return:
      signature - Promise - a signature on [i, j]
  */
  build_guess(i, j) {
    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //    DONE this function has been completed for you.
    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // Sends signed guess to opponent off-chain
    return sign_msg(JSON.stringify([i, j]), this.my_addr); // sign_msg defined in util.js
  }


  /* respond_to_guess
    \brief:
      called when the opponent guesses a board squaure (i, j)
    \params:
      i - int - the row of the guessed board square
      j - int - the column of the guessed board square
      signature - signature that proves the opponent is guessing (i, j)
    \return:
      hit (opening)   - bool   	- did the guess hit one of your ships?
      nonce 					- bytes32 - nonce for square [i, j]
      proof 					- object 	- proof that the guess hit or missed a ship
  */
  respond_to_guess(i, j, signature) {
    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //    DONE this function has been completed for you.
    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // Check first that the guess is signed, if not, we don't respond
    if (!check_signature(JSON.stringify([i, j]), signature, this.opp_addr)) { //check_signature defined in util.js
      throw "received an invalid signature from opponent as initial board commit";
    }
    // get truth value for this cell along with the associated nonce
    const opening = this.my_board[i][j], nonce = this.nonces[i][j];
    // write proof for this opening
    const proof = get_proof_for_board_guess(this.my_board, this.nonces, [i, j]);
    // return to opponent
    return [opening, nonce, proof];
  }

  /* receive_response_to_guess
    \brief:
      called with the response from respond_to_guess()
    \params:
      response - [hit, proof] - the object returned from respond_to_guess()
  */
  receive_response_to_guess(i, j, response) {

    // unpack response
    let [opening, nonce, proof] = response;
    // verify that opponent responded to the query
    if (!verify_opening(opening, nonce, proof, this.opponent_commit, [i, j])) {
      throw "opponent's response is not an opening of the square I asked for";
    }

	// ##############################################################################
    // TODO store local state as needed to prove your winning moves in claim_win
	// Hint: What arguments do you need to pass to the contract to check a ship?
    // ##############################################################################
		// Your code here
    if(this.opponent_board[i][j] != 0){
      console.log("This position in the opponent's board has been hit before");
      return;
    }
    
	this.last_received_response = response;
	this.last_guest_leaf_index = i * BOARD_LEN + j;

    //check if I can check a ship
    if(opening == true) {//hit the ship
		//call the contract to check a ship
		var opening_nonce = web3.utils.fromAscii(JSON.stringify(opening) + JSON.stringify(nonce));
		let index_of_guess_in_leaves = i * BOARD_LEN + j;

		console.log("check_one_ship");
		console.log(opening_nonce);
		console.log(proof);
		console.log(index_of_guess_in_leaves);
		console.log(this.opp_addr);
		var check_ship_promise = Battleship.methods.check_one_ship(
			opening_nonce,
			proof,
			index_of_guess_in_leaves,
			this.opp_addr).send({from: this.my_addr, gas: 3141592});

		// var check_ship_promise = new Promise(function(){});

		check_ship_promise.then(() => {
			this.opponent_board[i][j] = 2;
		});
      
    }else{//miss the target ship
      this.opponent_board[i][j] = 1;
    }

  }


  async accuse_timeout() {
	  // ##############################################################################
	  //    TODO implement accusing the opponent of a timeout
	  //	  - Called when you press "Accuse Timeout"
	  // ##############################################################################
	  // Your code here
	  console.log("claim_opponent_left");
	  console.log(this.opp_addr);
	  Battleship.methods.claim_opponent_left(this.opp_addr)
		  .send({from: this.my_addr, gas: 3141592});


  }

	async handle_timeout_accusation() {
		// ##############################################################################
		//    TODO implement addressing of a timeout accusation by the opponent
		//		- Called when you press "Respond to Accusation"
		// 		- Returns true if the game is over
		// ##############################################################################
		// Your code here
		console.log("handle_timeout");
		console.log(this.opp_addr);
		var timeout_promise = Battleship.methods.handle_timeout(this.opp_addr)
			.send({from: this.my_addr, gas: 3141592});
		console.log("is_game_over");
		return timeout_promise.then(Battleship.methods.is_game_over().send({from: this.my_addr}));
	}

	/* claim_timeout
    \brief:
      called when BattleshipPlayer believes the opponent has timed-out
      BattleshipPlayer should touch the solidity contract to enforce a
      timelimit for the move
  */
	async claim_timout_winnings() {
		// ##############################################################################
		//    TODO implement claim of rewards if opponent times out
		//		- Called when you press "Claim Timeout Winnings"
		// 		- Returns true if game is over
		// ##############################################################################
		// Your code here
		console.log("claim_timeout_winnings");
		console.log(this.opp_addr);
		console.log(this.my_addr);
		var timeout_promise = Battleship.methods.claim_timeout_winnings(this.opp_addr)
			.send({from: this.my_addr, gas: 3141592});
		console.log("is_game_over");
		return timeout_promise.then(Battleship.methods.is_game_over().send({from: this.my_addr}));
	}

	/*
	accuse_cheating
	*/
	async accuse_cheating() {
		// ##############################################################################
    //    TODO implement claim of a cheat (the opponent lied about a guess)
		//		- Called when you press "Accuse Cheating"
		//		- This function checks if the last response from the opponent was a lie
		//		- Note that this is already checked in receive_response_to_guess
		//		- This function should verify the proof using the contract instead.
		//		- For this project, the proof should always verify (the opponent will never lie).
		// ##############################################################################
		// Your code here
		// unpack response
		let [opening, nonce, proof] = this.last_received_response;
		var opening_nonce = web3.utils.fromAscii(JSON.stringify(opening) + JSON.stringify(nonce));
		let index_of_guess_in_leaves = this.last_guest_leaf_index;

		console.log("accuse_cheating");
		console.log(opening_nonce);
		console.log(proof);
		console.log(index_of_guess_in_leaves);
		console.log(this.opp_addr);
		var accuse_cheating_promise = Battleship.methods.accuse_cheating(
			opening_nonce,
			proof,
			index_of_guess_in_leaves,
			this.opp_addr).send({from: this.my_addr, gas: 3141592});
	}

	/*
	 	\brief:
			Claim that you won the game - submit proofs to the contract to get the reward.
	*/
	async claim_win() {
		// ##############################################################################
		//    TODO implement claim of a win
		//		- Check the placements of two hits you have made on the opponent's board.
		//		- Check (verify with contract) that your board has 2 ships.
		//		- Claim the win to end the game.
		//		Hint: you can convert an opening and a nonce into a bytes memory like this:
		//			web3.utils.fromAscii(JSON.stringify(opening) + JSON.stringify(nonce))
		// ##############################################################################
		// Your code here
		console.log("claim_win");
		console.log(this.my_addr);
		Battleship.methods.claim_win().send({from: this.my_addr, gas: 3141592})
			.on('transactionHash', function (hash) {
				console.log("transactionHash");
				console.log(hash);
				alert("提交成功！交易Hash:" + hash);
			})
			.on('confirmation', function (confirmationNumber, receipt) {
				console.log("confirmation");
				console.log(confirmationNumber);
				console.log(receipt);
			})
			.on('receipt', function (receipt) {
				// receipt example
				console.log("receipt");
				console.log(receipt);
			})
			.on('error', function (error, receipt) {
				// If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
				console.log("error");
				console.log(error);
				console.log(receipt);
				alert("您未获胜，错误：" + error);
			});
		var retrieve = await Battleship.methods.is_game_over().call();
		console.log(retrieve)
	}

	/*
		\brief:
			Forfeit the game - sends the opponent the entire reward.
	*/
	async forfeit_game() {
		// ##############################################################################
		//    TODO forfeit the battleship game
		//		- Call solidity to give up your bid to the other player and end the game.
		// ##############################################################################
		// Your code here
		console.log("forfeit");
		console.log(this.opp_addr);
		Battleship.methods.forfeit(this.opp_addr).send({from: this.my_addr, gas: 3141592});
	}
}
