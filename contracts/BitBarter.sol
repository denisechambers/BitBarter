// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract BitBarter {
    enum State {
        Opened,
        Created,
        Completed,
        Cancelled
    }

    struct Job {
        string title;
        string description;
        uint256 price;
        address payable provider;
        address payable customer;
        State state;
    }

    Job job;

    modifier condition(bool condition_) {
        require(condition_);
        _;
    }

    /// Only the customer can call this function.
    error OnlyCustomer();
    /// Only the provider can call this function.
    error OnlyProvider();
    /// The function cannot be called at the current state.
    error InvalidState();

    modifier onlyCustomer() {
        if (msg.sender != job.customer) revert OnlyCustomer();
        _;
    }

    modifier onlyProvider() {
        if (msg.sender != job.provider) revert OnlyProvider();
        _;
    }

    modifier inState(State state_) {
        if (job.state != state_) revert InvalidState();
        _;
    }

    event Accepted();
    event Opened();
    event Aborted();

    event JobIsDone();
    event CustomerRefunded();

    receive() external payable {}
    fallback() external payable {}

    function openJob(
        string memory title,
        string memory description
    ) external payable returns (Job memory) {
        require(msg.value > 0);

        if (msg.value > msg.sender.balance) {
            revert();
        }
        job = Job(
            title,
            description,
            msg.value,
            payable(address(0)),
            payable(msg.sender),
            State.Opened
        );
        //Transfer ETH to contract
        payable(address(this)).transfer(msg.value);

        emit Opened();
        return job;
    }

    function openJobForProvider(
        string memory title,
        string memory description,
        address providerAccount
    ) external payable returns (Job memory) {
        require(msg.value > 0);

        if (msg.value > msg.sender.balance) {
            revert();
        }
        job = Job(
            title,
            description,
            msg.value,
            payable(providerAccount),
            payable(msg.sender),
            State.Opened
        );
        //Transfer ETH to contract
        payable(address(this)).transfer(msg.value);

        emit Opened();
        return job;
    }

    function sendViaCall(address payable _to) external payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function acceptJob()
        external onlyProvider
        inState(State.Opened)
        returns (Job memory)
    {
        job.provider = payable(msg.sender);
        job.state = State.Created;

        emit Accepted();
        return job;
    }

    /// Cancel the job and reclaim the ether.
    function abort() external payable onlyCustomer inState(State.Opened) {
        emit Aborted();
        job.state = State.Cancelled;
        // We use transfer here directly. It is
        // reentrancy-safe, because it is the
        // last call in this function and we
        // already changed the state.
        job.customer.transfer(address(this).balance);
    }

    /// Confirm that you (the customer) received the work
    /// This will release the locked ether.
    function jobIsDone()
        external
        payable
        onlyCustomer
        inState(State.Created)
    {
        emit JobIsDone();

        job.state = State.Completed;
        job.provider.transfer(job.price);

    }

}
