// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract DecentralizedLotteryService {
    struct Contribution {
        address participant;
        uint256 amount;
        uint256 timestamp;
    }

    struct WinRecord {
        address winner;
        uint256 winningAmount;
        uint256 resultDeclaredAt;
    }

    struct Lottery {
        string name;
        Contribution[] contributions;
        uint256 value;
        uint256 resultEligibilityTimestamp;
        WinRecord winRecord;
    }
    
    mapping(uint256 => Lottery) private _lotteries;
    uint256 private _totalLotteries;

    mapping(string => uint256) private _lotteryIndexPlus1;

    mapping(address => uint256[]) private _participatedLotteries;
    mapping(address => mapping(uint256 => uint256)) private _participantContributionHistory;
    mapping(address => uint256[]) private _participantWinningHistory;

    uint256 public constant MIN_RESULT_DECLARATION_TIMESTAMP_DIFF = 20 * 60;     // minutes(s) * secondsPerMinute

    address private _owner;
    uint256 private _ownerProfits;

    constructor () {
        _owner = msg.sender;
        _totalLotteries = 0;
        _ownerProfits = 0;
    }

    receive() external payable {}
    fallback() external payable {}


    /**
     * @dev Service owner can change the ownership
     * @param newOwner: The new owner to transfer transfer the service control to
     */
    function changeOwner(address newOwner) public {
        require(msg.sender == _owner, "Only owner is allowed to make this change");
        require(newOwner != _owner, "Please provide a different owner");
        _owner = newOwner;
    }

    /**
     * @dev Only owner should be allowed to spend the Service (only) Profits
     * @param amount: the amount to be spent from ownerProfits
     * @param recipient: the recipient to send the spent amount to
     */
    function spendProfits(uint256 amount, address recipient) public {
        require(msg.sender == _owner, "Only owner is allowed to spend the profits");
        require(amount <= _ownerProfits, "Not enough profits left to spend");
        
        _ownerProfits -= amount;
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Failed to send amount to recipient");
    }

    /**
     * @dev Check unspent ownerProfits
     */
    function checkProfits() public view returns (uint256) {
        return _ownerProfits;
    }

    function getBlockTimestamp()  public view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @dev Check if the given name is available to be assigned for a new Lottery
     * @param name: to check availability for
     */
    function isLotteryNameAvailable(string memory name) public view returns (bool) {
        return (_lotteryIndexPlus1[name] == 0)  &&  (bytes(name).length != 0);
    }
    
    /**
     * @dev Check if a lottery with the given name exists
     * @param name: to check the lottery existence for
     */
    function _doesLotteryExist(string memory name) private view returns (bool) {
        return (_lotteryIndexPlus1[name] != 0);
    }

    /**
     * @dev Add a new lottery (with first contribution from the creator himself/herself)
     * @param name: to identify the lottery by
     * @param resultEligibilityTimestamp: the timestamp,
     *                                      a. Post which, no new participations should be accepted
     *                                      b. Until which, the result cannot be declared
     */
    function addLottery(string memory name, uint256 resultEligibilityTimestamp) public payable {
        require(isLotteryNameAvailable(name), "Please choose a unique (non-empty) name for the lottery");
        require(resultEligibilityTimestamp > block.timestamp + MIN_RESULT_DECLARATION_TIMESTAMP_DIFF,
                string.concat("Result-Eligibility-Timestamp must be atleast ", Strings.toString(MIN_RESULT_DECLARATION_TIMESTAMP_DIFF), " seconds in the future."));

        Lottery storage lottery = _lotteries[_totalLotteries];
        lottery.name = name;
        lottery.value = 0;
        lottery.resultEligibilityTimestamp = resultEligibilityTimestamp;
        lottery.winRecord.winner = address(0);
        lottery.winRecord.winningAmount = 0;
        lottery.winRecord.resultDeclaredAt = 0;

        _totalLotteries++;
        _lotteryIndexPlus1[name] = _totalLotteries;
        
        participateInLottery(name);
    }

    /**
     * @dev Any one can participate in a lottery (at most once per user/lottery) till the set deadline
     * @param name: to identify the lottery by
     */
    function participateInLottery(string memory name) public payable {
        require(msg.value > 0, "Participant's contribution must be positive");
        require(_doesLotteryExist(name), string.concat("Lottery with name ",  name," does not exist"));

        uint256 lotteryIndex = _lotteryIndexPlus1[name] - 1;
        require(block.timestamp < _lotteries[lotteryIndex].resultEligibilityTimestamp, string.concat("Missed the deadline to participate in Lottery"));
        require(_participantContributionHistory[msg.sender][lotteryIndex] == 0, string.concat("The sender had already participated in this lottery (not allowed more than once)"));

        _lotteries[lotteryIndex].contributions.push(Contribution(msg.sender, msg.value, block.timestamp));
        _lotteries[lotteryIndex].value += msg.value;

        _participatedLotteries[msg.sender].push(lotteryIndex);
        _participantContributionHistory[msg.sender][lotteryIndex] = _lotteries[lotteryIndex].contributions.length;
    }
    
    /**
     * @dev Lottery results can be declared only after the lottery-specific-deadline has passed
     *      a. Winner is randomly decided
     *      b. `winningAmount = MIN(lottery.totalValue, 2 * winnerContribution)` is transferred to the winner
     *      c. +ve difference left, is added to owner's profit
     * @param name: to identify the lottery by
     */
    function declareLotteryResults(string memory name) public returns (address) {
        require(_doesLotteryExist(name),
                string.concat("Lottery with name ",  name," does not exist"));

        uint256 lotteryIndex = _lotteryIndexPlus1[name] - 1;
        require(_lotteries[lotteryIndex].winRecord.winner == address(0),
                string.concat("Winner already declared to be ", Strings.toHexString(_lotteries[lotteryIndex].winRecord.winner)));
        require(block.timestamp >= _lotteries[lotteryIndex].resultEligibilityTimestamp,
                string.concat("Not allowed to declare winner before timestamp ", Strings.toString(_lotteries[lotteryIndex].resultEligibilityTimestamp)));

        uint256 winnerIndex = _getRandomNumber(_lotteries[lotteryIndex].contributions.length);

        uint256 winningAmount = 2 * _lotteries[lotteryIndex].contributions[winnerIndex].amount;
        if (_lotteries[lotteryIndex].value < winningAmount) {
            winningAmount = _lotteries[lotteryIndex].value;
        }
        
        _lotteries[lotteryIndex].winRecord.winner = _lotteries[lotteryIndex].contributions[winnerIndex].participant;
        _lotteries[lotteryIndex].winRecord.winningAmount = winningAmount;
        _lotteries[lotteryIndex].winRecord.resultDeclaredAt = block.timestamp;

        _ownerProfits += (_lotteries[lotteryIndex].value - winningAmount);
        (bool success, ) = _lotteries[lotteryIndex].winRecord.winner.call{value: winningAmount}("");
        require(success, "Failed to send the winning amount to Winner-Address");
        
        _participantWinningHistory[_lotteries[lotteryIndex].winRecord.winner].push(lotteryIndex);
        return _lotteries[lotteryIndex].winRecord.winner;
    }

    /**
     * @dev Generated a random number in the range [0, max_plus_1 - 1]
     * @param max_plus_1: to be used as exclusive upper-bound
     */
    function _getRandomNumber(uint256 max_plus_1) private view returns (uint256) {
        require(max_plus_1 > 0, "Max must be greater than 0");

        uint random = uint(
            keccak256(
                abi.encodePacked(
                    block.prevrandao,
                    block.timestamp,
                    msg.sender
                )
            )
        );

        return random % max_plus_1;
    }

    /**
     * @dev if already available:     returns winner for the specified lottery
     *      else if deadline passed:  declares the result & returns the winner
     *      otherwise:                errors out
     * @param name: to identify the lottery by
     */
    function getOrDeclareLotteryWinner(string memory name) public returns (address) {
        require(_doesLotteryExist(name),
                string.concat("Lottery with name ",  name," does not exist"));
        
        uint256 lotteryIndex = _lotteryIndexPlus1[name] - 1;
        if (_lotteries[lotteryIndex].winRecord.winner != address(0)) {
            return _lotteries[lotteryIndex].winRecord.winner;
        }

        return declareLotteryResults(name);
    }
    
    /**
     * @dev returns relavant information about the specified lottery, such as:
     *              a. name, value
     *              b. if winner available/possible_to declare:  winner, winningAmount, resultDeclaredAt
     *                 otherwise:                                when results can be declared 
     * @param name: to identify the lottery by
     */
    function getLotteryInfo(string memory name)  public returns (string memory) {
        require(_doesLotteryExist(name),
                string.concat("Lottery with name ",  name," does not exist"));

        uint256 lotteryIndex = _lotteryIndexPlus1[name] - 1;
        if (_lotteries[lotteryIndex].resultEligibilityTimestamp <= block.timestamp
                &&  _lotteries[lotteryIndex].winRecord.winner == address(0)) {
            declareLotteryResults(name);
        }

        string memory basicInfo = string.concat("Name: ", _lotteries[lotteryIndex].name, "  --  ",
                                                "Value: ", Strings.toString(_lotteries[lotteryIndex].value));
        if (_lotteries[lotteryIndex].resultEligibilityTimestamp > block.timestamp) {
            return string.concat(basicInfo, "  --  ",
                                "Result_Eligibility_Timestamp:", Strings.toString(_lotteries[lotteryIndex].resultEligibilityTimestamp));
        }

        return string.concat(basicInfo, "  --  ",
                            "Winner:", Strings.toHexString(_lotteries[lotteryIndex].winRecord.winner), "  --  ",
                            "Winning_Amount:", Strings.toHexString(_lotteries[lotteryIndex].winRecord.winningAmount), "  --  ",
                            "Result_Declared_At_Timestamp", Strings.toString(_lotteries[lotteryIndex].winRecord.resultDeclaredAt));
    }

    /**
     * @dev returns relavant information about participant's lottery history, such as:
     *              a. Lotteries participated in
     *              b. Lotteries won (if any)
     *          with their specifics
     * @param participant: to return the history for
     */
    function getParticipantHistory(address participant)  public view returns (string memory) {
        uint256 totalLotteriesParticipatedIn = _participatedLotteries[participant].length;
        require(totalLotteriesParticipatedIn > 0, "Participant has no history");

        string memory result = "Participation_History:";
        for (uint i = 0; i < totalLotteriesParticipatedIn; i++) {
            uint256 lotteryIndex = _participatedLotteries[participant][i];
            uint256 contributionIndex = _participantContributionHistory[participant][lotteryIndex] - 1;
            Contribution storage contribution = _lotteries[lotteryIndex].contributions[contributionIndex];
            
            result = string.concat(result, "  --  ",
                                   "  < Timestamp = ", Strings.toString(contribution.timestamp), ", ",
                                        "Amount = ", Strings.toString(contribution.amount), ", ",
                                        "Lottery = ", _lotteries[lotteryIndex].name,
                                    " >");
        }

        result = string.concat(result, "  --  ",
                                "Winning_History:");
        if (_participantWinningHistory[participant].length == 0) {
            result = string.concat(result, "  --  ",
                                   "  None");
        } else {
            for (uint i = 0; i < _participantWinningHistory[participant].length; i++) {
                Lottery storage winningLottery = _lotteries[_participantWinningHistory[participant][i]];
                result = string.concat(result, "  --  ",
                                    "  < Winning Amount = ", Strings.toString(winningLottery.winRecord.winningAmount), ", ", "Lottery = ", winningLottery.name, " >");
            }
        }
        
        return result;
    }
}

