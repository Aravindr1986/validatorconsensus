pragma solidity ^0.4.17;
contract Datastore{

    mapping (address=>int)validators;   
    mapping(int=>uint)dataitemcnt;

    address[] vaddress;
    uint  sessionVcount;

    uint sessionStartTime;

    event DataCommit(int data,uint time);
    event message(string text);
  
    constructor(address[] _validators) public
    {
        vaddress=_validators;
        sessionStartTime=now;
        for( uint i=0 ; i<vaddress.length ; i++ )   //setting the inital validator set to -1
        {
            validators[vaddress[i]] = -1;
        }
    }
    function resetPolling()  public //resetting the polling for the next session
    {
        if(sessionVcount == vaddress.length )
        {
            sessionVcount = 0;
            for( uint i=0 ; i<vaddress.length ; i++ )
            {
                dataitemcnt[validators[vaddress[i]]] = 0;
                validators[vaddress[i]] = -1;
            }
        }
    }
    function submitValue (int val) public
    {
        if(validators[msg.sender]==-1 && now > sessionStartTime) //if the validator has not submitted a value for the current day
        {
            validators[msg.sender] = val;
            dataitemcnt[val] += 1;   //keeping the no of validators who have voted for this value
            sessionVcount += 1;    //number of voters
            if(dataitemcnt[val] >=(vaddress.length/2)+1)    //consensus reached for the day. reset session and start time to next day
            {
                emit DataCommit(val,now);
                sessionStartTime = sessionStartTime + 1 days;
                emit message("Consensus reached");
                resetPolling();
            }
        }
        if(sessionVcount == vaddress.length)  //everybody voted their number and a consensus has not been reached in this session
        {
            emit message("Consensus not reached");
            resetPolling();            
        }
    }
        
}