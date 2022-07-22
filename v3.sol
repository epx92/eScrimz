pragma solidity ^0.8.13;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

//libraries

struct User {
    uint256 startDate;
    uint256 divs;
    uint256 refBonus;
    uint256 totalInits;
    uint256 totalWiths;
    uint256 totalAccrued;
    uint256 lastWith;
    uint256 timesCmpd;
    uint256 keyCounter;
}

struct Depo {
    uint256 key;
    uint256 depoTime;
    uint256 amt;
    address reffy;
    uint256 divsAccrued;
    bool initialWithdrawn;
}

struct Main {
    uint256 ovrTotalDeps;
    uint256 ovrTotalWiths;
    uint256 users;
}

struct DivPercs{
    uint256 amtofDays;
    uint256 amtofDivs;
}

struct FeesPercs{
    uint256 amtxdays;
    uint256 amtxfees;
}

contract v3 {
    using SafeMath for uint256;

    uint256 constant launch = 1849839043;
    uint256 constant percentdiv = 1000;
    uint256 refPercentage = 50;
    uint256 devPercentage = 50;
    address public owner;

    mapping (address => mapping(uint256 => Depo)) public DeposMap;
    mapping (address => User) public UsersKey;
    mapping (uint256 => DivPercs) public PercsKey;
    mapping (uint256 => FeesPercs) public FeesKey;
    mapping (uint256 => Main) public MainKey;

    //ui stats?
    //things to display

    constructor() {

            owner = msg.sender;
            
            uint256 divPerc = 10;
            for (uint256 daysB = 10; daysB <= 50; daysB + 10){
                PercsKey[daysB] = DivPercs(daysB, divPerc);
                divPerc += 10;
            }

            uint256 feePerc = 10;
            for(uint256 daysC = 10; daysC <= 30; daysC + 10){
                FeesKey[daysC] = FeesPercs(daysC, feePerc);
                feePerc = feePerc.div(2);
            }
    }

    function dep(uint256 amtx, address ref) public {

        User storage user = UsersKey[msg.sender];
        User storage user2 = UsersKey[ref];
        Main storage main = MainKey[1];

        if (user.lastWith == 0){
            user.lastWith = block.timestamp;
        }

        user.totalInits += amtx;

        uint256 refAmtx = amtx.mul(50).div(percentdiv);
        user2.refBonus += refAmtx;
        user.refBonus += refAmtx;

        DeposMap[msg.sender][user.keyCounter].key = user.keyCounter;
        DeposMap[msg.sender][user.keyCounter].depoTime = block.timestamp;
        DeposMap[msg.sender][user.keyCounter].amt = amtx;
        DeposMap[msg.sender][user.keyCounter].reffy = ref;
        DeposMap[msg.sender][user.keyCounter].divsAccrued = 0;
        DeposMap[msg.sender][user.keyCounter].initialWithdrawn = false;

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        main.users += 1;

    }

    function withdrawDivs() public {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        
        uint256 x = calcdiv();

        main.ovrTotalWiths += x;
        user.lastWith = block.timestamp;

        payable(msg.sender).transfer(x);

    }

    function withdrawInitial(uint256 keyy) public {

        User storage user = UsersKey[msg.sender];
        uint256 initialAmt = DeposMap[msg.sender][keyy].amt;
        uint256 currDays =  DeposMap[msg.sender][keyy].depoTime - block.timestamp;
        uint256 transferAmt;

        for (uint256 z = 10; z <= 30; z + 10){
            if (currDays <= FeesKey[z].amtxdays){
                uint256 minusAmt = initialAmt.mul(FeesKey[z].amtxfees).div(percentdiv);
                transferAmt = initialAmt - minusAmt;
            }
        }

        DeposMap[msg.sender][keyy].amt = 0;
        user.lastWith = block.timestamp;
        payable(msg.sender).transfer(transferAmt);

    }

    function withdrawRefBonus() public {

        User storage user = UsersKey[msg.sender];
        uint256 amtz = user.refBonus;
        user.refBonus = 0;
        payable(msg.sender).transfer(amtz);

    }

    function calcdiv() public view returns (uint256 totalWithdrawable){

        User storage user = UsersKey[msg.sender];
        uint256 rn = block.timestamp;
        uint256 placeHolder;

        for (uint256 i = 0; i <= user.keyCounter; i++){
            if (DeposMap[msg.sender][i].initialWithdrawn == false){
                uint256 divDays = user.lastWith - rn;
                for (uint256 y = 20; y <= 50; y + 10){
                    if (divDays <= PercsKey[y].amtofDays){
                        uint256 randInt = PercsKey[y].amtofDivs;
                        uint256 perDay = DeposMap[msg.sender][i].amt.mul(randInt).div(percentdiv);
                        placeHolder += perDay.mul(divDays);
                    }
                }
            }
        }

        return placeHolder;

    }

    function BonusTime(uint256 dayss, uint256 percentage) public{
        require (msg.sender == owner);
        PercsKey[dayss] = DivPercs(dayss, percentage);
    }

    //change divPerentages

    }


    //deposit fee/sus fee
    //wdfee/susfee


    // function doSomething(uint256 bricks, uint256 ladder, heightList[])
        
    //     for (uint256 i = 0, i < heightList.length, i++){
    //         if heightList[i] < heightList[i+1]

    //     }

       //
            // struct DivPercs[10]{
            //     uint256 10;
            //     uint256 10;
            // }
            
            // struct DivPercs[20]{
            //     uint256 20;
            //     uint256 2
            // }

            //struct DivPercs[30]{
            //     uint256 30;
            //     uint256 3;
            // }   
            


            // struct FeesPercs{
            //     uint256 amtxdays;
            //     uint256 amtxfees;
            // }
