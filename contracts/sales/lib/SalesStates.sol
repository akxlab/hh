// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

abstract contract SalesStates {

    StateFlags public currentState;
    address public stateOperator;
    StateFlags public nextState;
    StateFlags public prevState;

    enum StateFlags {
        PAUSED,
        STARTED,
        PENDING,
        RESUMED,
        CLOSED,
        CANCELLED
    }

    struct SaleStates {
        StateFlags state;
        StateFlags nextState;
        StateFlags prevState;
    }

    struct State {
        StateFlags _val;
    }

    constructor(address _stateOperator, bool startPaused) {
        stateOperator = _stateOperator;
        if(startPaused == true) {
            PauseContract();
        }
    }

    function _setState(StateFlags state, StateFlags _nextState, StateFlags  _prevState) internal pure returns(State memory) {

        SalesStates.SaleStates memory  ss =  SaleStates(state, _nextState, _prevState);
        State memory s = State(ss.state);
        return s;
    }

    function _triggerNextState(SaleStates memory states) internal view  {
        require(currentState != states.nextState, "state already triggered");
        require(states.prevState == currentState, "invalid current state.");
        _setState(states.state, states.prevState, states.nextState);

    }

    function _currentState() internal view returns(StateFlags) {
        return currentState;
    }

    function moveStateForward(SalesStates.SaleStates memory states) public view onlyStateOperator(msg.sender) {
        _triggerNextState(states);
    }

    function _emergencyPause() internal virtual  {
        require(currentState != StateFlags.PAUSED, "akx-states/already-paused");
        SalesStates.SaleStates memory ss =  SaleStates(StateFlags.PAUSED, StateFlags.RESUMED, currentState);
        _setState(ss.state, ss.prevState, ss.nextState);
    }

    function _isPaused() internal view returns(bool) {
        if(currentState != StateFlags.PAUSED) {
            return false;
        }
        return true;
    }

    function PauseContract() public onlyStateOperator(msg.sender) {
        _emergencyPause();
    }

    function isPaused() public view returns(bool) {
        return _isPaused();
    }

    function UnPauseContract() public view onlyStateOperator(msg.sender) {
        require(currentState == StateFlags.PAUSED, "akx-states/not-paused");
        _setState(StateFlags.RESUMED, prevState, StateFlags.PAUSED);
    }

    modifier onlyStateOperator(address sender) {
        require(sender == stateOperator, "akx-states/denied-set-state");
        _;
    }

}